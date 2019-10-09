#!/usr/bin/python3

from glob import glob

if __name__ == "__main__":

    # Grab Markdown files
    filenames = []
    for filename in glob("*.md"):
        filenames.append(filename)

    # Read the source files
    text = ""
    for filename in filenames:
        with open(filename, 'r') as file:
            text += file.read()

    # Print the word count to the terminal
    print(len(text.split()))
