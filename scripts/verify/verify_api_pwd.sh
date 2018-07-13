#!/bin/bash

set -eux
set -o pipefail

NS_NAME=${ENV_NAME}

HTTP_CODE=$(docker run --rm ${CURL_IMAGE} -X GET \
${K8S_URL}/api/v1/namespaces/${NS_NAME}/services \
--basic -u ${API_USER}:${API_PWD} -k \
-w %{http_code} -o /dev/null -s)

echo "http code: $HTTP_CODE"

if [ ${HTTP_CODE} -ge 400 ]; then
    echo "密码验证失败！"
    exit 1
else
    echo "密码验证成功！"
fi
