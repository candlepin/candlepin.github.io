#! /usr/bin/env python
import argparse
import os
import re

# Courtesy http://stackoverflow.com/a/1176023
FIRST_CAP_RE = re.compile('(.)([A-Z][a-z]+)')
ALL_CAP_RE = re.compile('([a-z0-9])([A-Z])')


class Trac2Markdown(object):
    def __init__(self, text):
        self.initial = text

    def convert(self):
        text = re.sub(r'{{{(.*?)}}}', r'`\1`', self.initial)

        def codeblock(m):
            return '\n```' + m.group(1) + '\n```\n'
        text = re.sub(r'(?sm)^\s*{{{(.*?)\n\s*}}}\s*$', codeblock, text)
        text = re.sub(r'(?m)^====\s+(.*?)\s+====$', r'#### \1', text)
        text = re.sub(r'(?m)^===\s+(.*?)\s+===$', r'### \1', text)
        text = re.sub(r'(?m)^==\s+(.*?)\s+==$', r'## \1', text)
        text = re.sub(r'(?m)^=\s+(.*?)\s+=$', r'# \1', text)
        text = re.sub(r'^ * ', r'****', text)
        text = re.sub(r'^ * ', r'***', text)
        text = re.sub(r'^ * ', r'**', text)
        text = re.sub(r'^ * ', r'*', text)
        text = re.sub(r'^ \d+. ', r'1.', text)
        text = re.sub(r'(?m)\[(https?://[^\s\[\]]+)\s([^\[\]]+)\]', r'[\2](\1)', text)
        text = re.sub(r'(?m)\[(wiki:[^\s\[\]]+)\s([^\[\]]+)\]', r'[\2](/\1/)', text)
        text = re.sub(r'\!(([A-Z][a-z0-9]+){2,})', r'\1', text)
        text = re.sub(r'(?m)\'\'\'(.*?)\'\'\'', r'*\1*', text)
        text = re.sub(r'(?m)\'\'(.*?)\'\'', r'_\1_', text)
        return text


def parse_args():
    parser = argparse.ArgumentParser(description='Convert Trac wiki documents to Markdown.')
    parser.add_argument('files', metavar='FILE', nargs='+', help='files to convert')
    parser.add_argument('--destination', metavar='DIRECTORY', default=os.getcwd(),
            help='directory to output converted files to')
    args = parser.parse_args()
    return args


def decamel_case(name):
    s1 = FIRST_CAP_RE.sub(r'\1_\2', name)
    return ALL_CAP_RE.sub(r'\1_\2', s1).lower()


def main():
    args = parse_args()
    for filename in args.files:
        name = os.path.splitext(os.path.basename(filename))[0]
        outfile = "%s.md" % decamel_case(name)
        outfile = os.path.join(args.destination, outfile)

        print "Converting %s to %s" % (filename, outfile)
        with open(filename) as f:
            slurp = f.read()

            with open(outfile, "w") as out:
                out.write("---\n")
                out.write("layout: default\n")
                out.write("---\n")
                out.write(Trac2Markdown(slurp).convert())


if __name__ == "__main__":
    main()
