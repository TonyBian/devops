#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Author        : Tony Bian <biantonghe@gmail.com>
# Last modified : 2018-06-27 15:19
# Filename      : sync.py

import subprocess
import json
import datetime

print(datetime.datetime.now())

api_server = "127.0.0.1:7777"

plugins = subprocess.Popen(
    'curl -X GET -s %s/plugins' % (api_server),
    shell=True,
    stdout=subprocess.PIPE
)

plugins_info = json.loads(plugins.stdout.read())
plugins_dict = plugins_info['data']['plugins']

for plugin_key in plugins_dict.keys():
    subprocess.Popen(
        'curl -X POST -s %s/%s/sync\n' % (api_server, plugin_key),
        shell=True
    )
