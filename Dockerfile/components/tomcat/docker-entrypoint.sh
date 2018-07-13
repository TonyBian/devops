#!/bin/bash
# -*- coding: utf-8 -*-

# Author        : Tony Bian <biantonghe@gmail.com>
# Last modified : 2018-06-24 09:25
# Filename      : docker-entrypoint.sh

set -e

# startup cron
env >>/etc/default/locale
/etc/init.d/cron start > /dev/null

exec "$@"
