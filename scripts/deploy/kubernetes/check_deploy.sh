#!/bin/bash
# -*- coding: utf-8 -*-

# Author        : Tony Bian <biantonghe@gmail.com>
# Last modified : 2018-06-23 22:05
# Filename      : check_deploy.sh

cat ${WORKSPACE}/deploy.log

if grep "error" ${WORKSPACE}/deploy.log; then
    exit 1
fi
