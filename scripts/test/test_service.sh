#!/usr/bin/env bash

set -x

if [[ "$(uname)" == "Darwin" ]]; then
    DOCKER_CMD=docker
else
    DOCKER_CMD="docker"
fi

PASS=1

echo "image name: ${PROJECT_IMAGE}"

TESTDOCKER="${GROUP}-${PROJECT}-test"

echo "test container name: ${TESTDOCKER}"

# Remove old container if exists
${DOCKER_CMD} rm -f ${TESTDOCKER} >/dev/null 2>&1

CID=$(${DOCKER_CMD} run -d --name ${TESTDOCKER} -P ${PROJECT_IMAGE})

echo "test container id: ${CID}"

${DOCKER_CMD} pull ${CURL_IMAGE}

for i in 1 2 3 4 5; do
    IP=$(${DOCKER_CMD} inspect --format='{{.NetworkSettings.IPAddress}}' ${TESTDOCKER})
    ${DOCKER_CMD} run --rm --link ${TESTDOCKER} ${CURL_IMAGE} http://${IP}:${PORT_EXPOSE} -s --head >/dev/null
    sleep 2
    if [ $? -eq "0" ]; then
        PASS=0
        break
    else
        sleep 5
    fi
done

${DOCKER_CMD} rm -f $CID >/dev/null

if [ $PASS -eq "0" ]; then
    echo "service tests passed"
else
    echo "service tests failed"
    ${DOCKER_CMD} rmi ${PROJECT_IMAGE}
fi

exit ${PASS}
