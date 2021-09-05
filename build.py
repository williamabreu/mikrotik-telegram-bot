#!/usr/bin/python3
import os
from dotenv import load_dotenv
from pathlib import Path

# load secrets.
load_dotenv()

# transient data across view/builder.
transient_data: str


def inject(*args) -> None:
    global transient_data
    transient_data = ''.join(args)


def check_line_commented(line: str) -> bool:
    return line[0] == '#'


def check_begin_python_block(line: str) -> bool:
    if check_line_commented(line):
        tokens = line.split()
        return tokens == ['#', '>>>', 'python']
    else:
        return False


def check_end_python_block(line: str) -> str:
    if check_line_commented(line):
        tokens = line.split()
        return tokens == ['#', '<<<']
    else:
        return False
    

def load_message_html() -> str:
    with open('resources/message.html') as fp:
        return ''.join(fp.readlines())


if __name__ == '__main__':
    output_lines = []

    with open('src/template.rsc') as fp:
        line = fp.readline()
        while line != '':
            if check_begin_python_block(line):
                line = fp.readline()
                while not check_end_python_block(line):
                    exec(line)
                    output_lines.append(transient_data + '\n')
                    line = fp.readline()
            else:
                output_lines.append(line)
            line = fp.readline()

    Path('build/').mkdir(parents=True, exist_ok=True)

    with open('build/build.rsc', 'w') as fp:
        fp.writelines(output_lines)
