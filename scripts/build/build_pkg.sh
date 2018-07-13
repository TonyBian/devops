#!/bin/bash

set -eux
set -o pipefail

docker pull ${PKG_BUILD_IMAGE}
docker run --rm \
    -v "${WORKSPACE}${SRC_PATH}":/usr/src/mybuilding \
    -w /usr/src/mybuilding \
    ${PKG_BUILD_IMAGE} \
    ${PKG_BUILD_COMMAND}
