#!/usr/bin/env bash

set -ex
set -o pipefail

SCRIPT_DIR=$(dirname "$0")
CODE_DIR=$(
    cd $SCRIPT_DIR/../..
    pwd
)
echo $CODE_DIR

if [[ "$(uname)" == "Darwin" ]]; then
    DOCKER_CMD=docker
else
    DOCKER_CMD="docker"
fi

# 构造Dockerfile

DOCKERFILE_TPL="./devops/Dockerfile/templates/Dockerfile.${PROJECT_TYPE}"

DOCKERFILE="${WORKSPACE}/${TAG_NAME}/Dockerfile"

cp -f ${DOCKERFILE_TPL} ${DOCKERFILE}

sed -i "s#\${PROD_IMAGE}#${PROD_IMAGE}#g" ${DOCKERFILE}
sed -i "s#\${PKG_PATH}#${PKG_PATH}#g" ${DOCKERFILE}
sed -i "s#\${PKG_NAME}#${PKG_NAME}#g" ${DOCKERFILE}
sed -i "s#\${INGRESS_PATH}#${INGRESS_PATH}#g" ${DOCKERFILE}

$DOCKER_CMD pull ${PROD_IMAGE}
$DOCKER_CMD build --no-cache=${DOCKER_BUILE_NO_CACHE} -t ${PROJECT_IMAGE} -f ${DOCKERFILE} .${SRC_PATH}
