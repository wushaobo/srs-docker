#!/usr/bin/env python
import fnmatch
import os
import re
from os.path import abspath, dirname, join

from jinja2 import Environment, FileSystemLoader

current_dir = dirname(abspath(__file__))

output_dir = join(current_dir, '..', 'output')
templates_dir = join(current_dir, '..', 'templates')
templates_env = Environment(loader=FileSystemLoader(templates_dir))


def main():
    setup_output_dir()

    template_file_names = list_template_file_names()
    context = collect_context()

    for filename in template_file_names:
        content = render_template(filename, context)
        write_to_output(content, filename)


def setup_output_dir():
    os.system('mkdir -p %s' % output_dir)
    os.system('rm -rf %s/*' % output_dir)


def render_template(template_file_name, context):
    return templates_env.get_template(template_file_name).render(context)


def write_to_output(content, template_file_name):
    output_file_path = join(output_dir, re.sub(r"\.j2$", '', template_file_name))
    
    with open(output_file_path, 'w') as f:
        f.write(content)


def collect_context():
    return {key: val for key, val in os.environ.items()}


def list_template_file_names():
    matches = []

    for root, dir_names, file_names in os.walk(templates_dir):
        if len(dir_names) > 0:
            print("Do not support sub folder in templates folder.")
            exit(1)
        matches.extend(fnmatch.filter(file_names, '*.j2'))

    return matches


if __name__ == "__main__":
    main()
