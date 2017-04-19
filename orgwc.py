#!/usr/bin/python3

from sys import argv

def count(file_name):
    count = 0
    with open(file_name, "r") as org_file:
        drawer = False
        for line in org_file:
            try:
                if not drawer:
                    if (line[0] == "*" or line.strip()[0:2] == "#+"
                            or line.strip()[0:6] == "CLOSED"):
                        continue
                    elif line.strip()[0] == ":":
                        drawer = True
                        continue
                    else:
                        count += len(line.split())
                else:
                    if line.strip() == ":END:":
                        drawer = False
            except IndexError:
                pass

    print (str(count) + " words")


if __name__ == "__main__":
    if len(argv) > 1:
        count(argv[1])
    else:
        print("Usage: python3 orgwc.py [ORG-FILE]")
