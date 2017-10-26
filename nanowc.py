#!/usr/bin/python3

import hashlib
import requests

if __name__ == "__main__":
    with open("/home/the-hawk/.nanocount", 'r') as secret:
        key = secret.read().strip().encode('utf-8')

    name = b'the-hawk'
    count = run(['/home/the-hawk/nanowrimo/build', 'wc'],
                stdout=PIPE).stdout.strip()

    h = hashlib.sha1()
    h.update(key)
    h.update(name)
    h.update(count)

    payload = {'hash': h.hexdigest(),
               'name': name.decode('utf-8'),
               'wordcount': count.decode('utf-8')}
