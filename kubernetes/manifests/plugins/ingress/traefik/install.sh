#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {dev|test|prod}"
    exit 1
fi

TRAEFIK_UI_URL=$1.k8s.io

echo "创建traefik..."
/usr/bin/cp -f template/*.yaml ./
sed -i "s#\${TRAEFIK_UI_URL}#${TRAEFIK_UI_URL}#g" *.yaml

kubectl create -f .

# 清理文件
rm -f *.yaml

echo "traefik访问地址："
echo ${TRAEFIK_UI_URL}
