#!/usr/bin/python3
from curses import A_STANDOUT, curs_set, noecho, wrapper
from os import environ, rename, walk
from os.path import basename
from re import DOTALL, search, sub
from sys import argv
from yaml import load


# Constants for the posts tuple
DRAFTS = 0
PUBLISHED = 1

# The blog path passed in via argument
blog_path = f'{environ["HOME"]}/blog'


# Will throw an exception if there is no valid YAML
def get_yaml(path):

    with open(path, "r") as pf:
        post = pf.read()

    fms = search(r"---(.+?)---", post, flags=DOTALL)
    return load(fms.group(1))


def get_published(path):
    post_list = []
    for (directory, _, filenames) in walk(f"{path}/_posts"):
        for filename in filenames:
            # Ignore Vim swap files
            if search(".*\.swp", filename):
                continue

            path = f"{directory}/{filename}"
            # See publish() for error explanations
            try:
                get_yaml(path)
                post_list.append(path)
            except (AttributeError, KeyError, TypeError):
                post_list.append(f"{path} (!)")

    return post_list


def get_drafts(path):
    post_list = []
    for (directory, _, filenames) in walk(f"{path}/_drafts"):
        for filename in filenames:
            # Ignore Vim swap files
            if search(".*\.swp", filename):
                continue

            path = f"{directory}/{filename}"
            # See publish() for error explanations
            try:
                get_yaml(path)
                post_list.append(path)
            except (AttributeError, KeyError, TypeError):
                post_list.append(f"{path} (!)")

    return post_list


def publish(path):
    global blog_path

    # - FileNotFoundError will happen if this file has been previously marked
    #   as having bad FrontMatter, hence why the error is ignored.
    # - KeyError and TypeError happen if the YAML doesn't have date data
    #   (depending on how the YAML is formatted).
    # - AttributeError happens if no YAML is found at all.
    try:
        frontmatter = get_yaml(path)
        date = frontmatter["date"].strftime("%Y-%m-%d")
    except (AttributeError, FileNotFoundError, KeyError, TypeError):
        return

    pub_name = f"{date}-{basename(path)}"
    rename(path, f"{blog_path}/_posts/{pub_name}")


def unpublish(path):
    global blog_path

    draft_name = sub(r"\d\d\d\d-\d\d-\d\d-", "", basename(path))
    rename(path, f"{blog_path}/_drafts/{draft_name}")


def mark_published(post, status):
    if status:
        publish(post)
    else:
        unpublish(post)


def toggle_status(posts, pos):
    global blog_path

    if pos < len(posts[DRAFTS]):
        mark_published(posts[DRAFTS][pos], True)
    else:
        mark_published(posts[PUBLISHED][pos - len(posts[DRAFTS])], False)

    drafts = get_drafts(blog_path)
    published = get_published(blog_path)

    return(drafts, published)


def print_posts(stdscr, posts, pos):
    stdscr.clear()
    stdscr.addstr(0, 0, "PUBLISHED    FILE")
    i = 1
    for p in posts[DRAFTS]:
        post = basename(p)
        if i == pos + 1:
            stdscr.addstr(i, 0, f"FALSE        {post}", A_STANDOUT)
        else:
            stdscr.addstr(i, 0, f"FALSE        {post}")
        i += 1

    for p in posts[PUBLISHED]:
        post = basename(p)
        if i == pos + 1:
            stdscr.addstr(i, 0, f"TRUE         {post}", A_STANDOUT)
        else:
            stdscr.addstr(i, 0, f"TRUE         {post}")
        i += 1

def main(stdscr, posts):
    noecho()
    curs_set(False)

    pos = 0
    while pos != -1:
        print_posts(stdscr, posts, pos)

        c = stdscr.getch()
        if c == ord("h") or c == ord("j"):
            if pos + 1 < len(posts[DRAFTS]) + len(posts[PUBLISHED]):
                pos += 1
        elif c == ord("t") or c == ord("k"):
            if pos > 0:
                pos -= 1
        elif c == ord("q"):
            pos = -1
        elif c == ord(" "):
            posts = toggle_status(posts, pos)


if __name__ == "__main__":
    try:
        drafts = get_drafts(blog_path)
        published = get_published(blog_path)
        wrapper(main, (drafts, published))
    except IndexError:
        print("")
        print("Usage:")
        print("    python3.6 publish.py")
        print("")
