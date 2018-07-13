#!/bin/bash

set -eux
set -o pipefail

BRANCH_NAME=$1

BRANCH_COMMIT_ID=$(echo $(git ls-remote -h ${PROJECT_GITLAB_URL} ${BRANCH_NAME} | awk '{print $1}'))

echo ${BRANCH_COMMIT_ID:0:7}
