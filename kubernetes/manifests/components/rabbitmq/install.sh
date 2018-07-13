#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {dev|test|prod}"
    exit 1
fi

ADMIN_USER=admin
SERVICE_URL="rabbit-$1.lc.com"
MANAGEMENT_URL="rabbit-ui-$1.lc.com"

read -p "请输入rabbit management登录密码：" PASSWD
PASSWD=$(echo -n "${PASSWD}" | base64)

COOKIE=$(echo -n "$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')" | base64)

echo "创建ingress..."
/usr/bin/cp -f template/*.yaml ./
sed -i "s#\${ADMIN_USER}#${ADMIN_USER}#g" *.yaml
sed -i "s#\${SERVICE_URL}#${SERVICE_URL}#g" *.yaml
sed -i "s#\${MANAGEMENT_URL}#${MANAGEMENT_URL}#g" *.yaml
sed -i "s#\${PASSWD}#${PASSWD}#g" *.yaml
sed -i "s#\${COOKIE}#${COOKIE}#g" *.yaml

kubectl create -f .

# 清理文件
rm -f *.yaml

echo "rabbit service访问地址："
echo ${SERVICE_URL}
echo
echo "rabbit management访问地址："
echo ${MANAGEMENT_URL}
echo
echo "rabbit management访问用户："
echo ${ADMIN_USER}
