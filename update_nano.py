#!/usr/bin/python3

import hashlib
import requests

from datetime import datetime
from subprocess import run
from subprocess import PIPE

if __name__ == "__main__":

    if datetime.now().month == 11:
        # Grab the NaNoWriMo secret key
        with open("/home/the-hawk/.nanocount", 'r') as secret:
            key = secret.read().strip().encode('utf-8')

        name = b'the-hawk'
        # Run word count on the NaNo repo
        count = run(['/home/the-hawk/nanowrimo/build', 'wc'],
                    stdout=PIPE).stdout.strip()

        print(f'NaNoWriMo is in session. Reporting {int(count)} words.')

        h = hashlib.sha1()
        h.update(key + name + count)

        payload = {'hash': h.hexdigest(),
                   'name': name.decode('utf-8'),
                   'wordcount': int(count)}

        response = requests.put("https://nanowrimo.org/api/wordcount",
                                data=payload)
        print(f'Response: {response.text}')
    else:
        print("NaNoWriMo not in session. Skipping word count update.")
