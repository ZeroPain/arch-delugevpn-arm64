import sys
import re
import site
import os
from os import path, rename, listdir
from os.path import isfile


plugins_path = path.join(site.getsitepackages()[0], 'deluge', 'plugins')
version = f'{sys.version_info.major}.{sys.version_info.minor}'
regex = r"(?<=py)(\d.\d)(?=\.egg)"

for dirpath, _, filenames in os.walk(plugins_path):
    for f in filenames:
        abs_file = os.path.abspath(os.path.join(dirpath, f))
        if not isfile(abs_file):
            continue

        new_file = re.sub(regex, version, f)
        rename(abs_file, os.path.abspath(os.path.join(dirpath, new_file)))
