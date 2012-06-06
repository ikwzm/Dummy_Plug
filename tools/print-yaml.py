#!/usr/bin/env python

import sys
import yaml

file_name_list = sys.argv[1:]

for file_name in file_name_list:
  string = open(file_name).read()
  string = string.decode('utf8')
  for data in yaml.load_all(string):
    print repr(data)

