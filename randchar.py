from random import choices


def rand_nonalpha_chars():
    chars = [chr(x) for x in range(0x21, 0x30)]
    chars += [chr(x) for x in range(0x3A, 0x41)]
    chars += [chr(x) for x in range(0x5B, 0x61)]
    chars += [chr(x) for x in range(0x7A, 0x7E)]

    return choices(chars, k=2)


if __name__ == '__main__':
    print(rand_nonalpha_chars())
