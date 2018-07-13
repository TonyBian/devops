#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {dev|test|prod}"
    exit 1
fi

ZKUI_URL=zkui-$1.lc.com

echo "创建zk..."
/usr/bin/cp -f template/*.yaml ./
sed -i "s#\${ZKUI_URL}#${ZKUI_URL}#g" *.yaml

kubectl create -f .

# 清理文件
rm -f *.yaml

echo "zkui访问地址："
echo ${ZKUI_URL}
