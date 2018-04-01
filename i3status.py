#!/usr/bin/python3
# -*- coding: utf-8 -*-

# This script is a simple wrapper which prefixes each i3status line with custom
# information. It is a python reimplementation of:
# http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.pl
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.py
# In the 'bar' section.
#
# In its current version it will display the cpu frequency governor, but you
# are free to change it to display whatever you like, see the comment in the
# source code below.
#
# © 2012 Valentin Haenel <valentin.haenel@gmx.de>
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License (WTFPL), Version
# 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.

import sys
import json

from datetime import date, timedelta
from requests import get
from subprocess import run, PIPE
from threading import Thread
from time import sleep
from xml.etree import ElementTree

NANO_COUNT_CMD = ["make", "wc"]

current_count = None
nano_goal_date = None
nano_goal = 0


class UpdateCount(Thread):
    def run(self):
        global current_count

        while date.today().month in [4, 7, 11]:
            count_raw = run(NANO_COUNT_CMD,
                            cwd="/home/the-hawk/nanowrimo",
                            stdout=PIPE).stdout
            current_count = int(count_raw.decode('utf-8'))
            sleep(20)


def get_remote_count():
    today = str(date.today())
    r = get("https://nanowrimo.org/wordcount_api/wchistory/the-hawk")
    root = ElementTree.fromstring(r.text)
    total_count = int(root.find('user_wordcount').text)
    wcentries = root.find('wordcounts').findall('wcentry')

    for wcentry in wcentries:
        if wcentry.find('wcdate').text == today:
            today_count = int(wcentry.find('wc').text)
            return total_count - today_count


def reverse_nano(day):
    return round(-57.42 * day ** 2 + 3388.78 * day + 14.64)


def goal_to_finish(day, count):
    return round((50000 - count) / (31 - day) + count)


def set_goal():
    global current_count
    global nano_goal
    global nano_goal_date

    if current_count is None:
        return

    if nano_goal_date is None or nano_goal_date != date.today():
        try:
            remote_count = get_remote_count()
        except Exception as err:
            nano_goal_date = None
            return

        nano_goal_date = date.today()
        if nano_goal_date.day == 24:
            nano_goal = 40000
            return

        par = reverse_nano(nano_goal_date.day)

        if (par - current_count) > 4000:
            nano_goal = goal_to_finish(nano_goal_date.day, remote_count)
        else:
            nano_goal = par


def build_nano_string():
    global current_count
    global nano_goal
    global nano_goal_date

    set_goal()
    today = date.today()
    if today.month == 11:
        event = "NaNoWriMo"
    elif today.month in [4,7]:
        event = "Camp NaNoWriMo"
    else:
        event = None

    if event and nano_goal and (current_count is not None):
        remaining = nano_goal - current_count
        progress = int(round(current_count / 50000 * 100))
        nano_str = f'{event} (Day {today.day}): {current_count} / {nano_goal}'
        if remaining <= 0:
            nano_str += f' - Daily Goal Achieved! ({progress}%)'
        else:
            nano_str += f' - {remaining} remaining ({progress}%)'

        return nano_str
    else:
        return None


def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()


def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()


if __name__ == '__main__':
    counter = UpdateCount(daemon=True)
    counter.start()

    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)
        # insert information into the start of the json, but could be anywhere
        # CHANGE THIS LINE TO INSERT SOMETHING ELSE
        # j.insert(0, {'full_text' : '%s' % get_governor(), 'name' : 'gov'})

        # NaNoWriMo (Day ?): Total Written / Daily Goal (%) |
        nano_status = build_nano_string()
        if nano_status:
            j.insert(0, {'full_text' : '%s' % nano_status,
                         'name' : 'nanowrimo'})

        # and echo back new encoded json
        print_line(prefix+json.dumps(j))
