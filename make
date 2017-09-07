#!/usr/bin/env python

import argparse
import subprocess
import os
import shutil
import webbrowser

parser = argparse.ArgumentParser(description="Build the Game")
parser.add_argument('command',
                    choices=['build', 'clean', 'run'])
parser.add_argument('--config',
                    choices=['debug', 'release-compatabilty', 'release-performance'],
                    default='debug',
                    help='Configuration to build')

args = parser.parse_args()

lovejs = os.environ.get('LOVEJS', os.path.abspath('../love.js/'))
out_dir = os.path.join('dist', args.config)
in_dir = 'src'


# ---

if args.command == 'build':
    if not os.path.exists(out_dir):
        orig_path = os.path.join(lovejs, args.config)
        shutil.copytree(orig_path, out_dir)

    cline = ['python',
             os.path.join(lovejs, 'emscripten/tools/file_packager.py'),
             os.path.join(out_dir, 'game.data'),
             '--preload',
             os.path.join(in_dir, '@/'),
             '--js-output=' + os.path.join(out_dir, 'game.js')]

    print('>' + ' '.join(cline))

    subprocess.call(cline)


if args.command == 'clean':
    shutil.rmtree(out_dir)

if args.command == 'run':
    os.chdir(out_dir)

    cline = ['python',
            '-m', 'SimpleHTTPServer',
            '8000']

    print('>' + ' '.join(cline))

    webbrowser.open('http://localhost:8000', new=2)
    subprocess.call(cline)

