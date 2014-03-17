#! /usr/bin/env python

import os
import requests
import subprocess
import sys

from bs4 import BeautifulSoup

HOST = "https://fedorahosted.org"


def write_original(link, out_dir):
    r = requests.get("%s?format=txt" % link)
    filename = r.headers['content-disposition'].split('=')[1]
    filename = os.path.join(out_dir, filename)
    with open(filename, "w") as f:
        f.write(r.text.encode('utf8'))
    subprocess.call(['dos2unix', filename])


def main():
    if sys.argv > 1:
        out_dir = sys.argv[1]
    else:
        out_dir = "."

    r = requests.get("%s/candlepin/wiki/TitleIndex" % HOST)
    html = BeautifulSoup(r.text)

    url_list = html.select("div.titleindex")[0]
    # Tokens in pages that we don't want
    blacklist = ["Trac", "Wiki"]
    for link in url_list.find_all("a"):
        relative_url = link.get('href')
        if not any(x in relative_url for x in blacklist):
            write_original("%s%s" % (HOST, relative_url), out_dir)


if __name__ == "__main__":
    main()
