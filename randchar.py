from random import choices


def rand_nonalpha_chars():
    chars = [chr(0x21), chr(0x28), chr(0x5B), chr(0x7B), chr(0x7C), chr(0x7E)]
    chars += [chr(x) for x in range(0x23, 0x27)]
    chars += [chr(x) for x in range(0x2A, 0x30)]
    chars += [chr(x) for x in range(0x3A, 0x41)]
    chars += [chr(x) for x in range(0x5E, 0x60)]

    return choices(chars, k=2)


if __name__ == '__main__':
    print(rand_nonalpha_chars())
