#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {dev|test|prod}"
    exit 1
fi

APP=orange
DOMAIN=lc.com
SERVICE_URL="$APP-$1.$DOMAIN"
MANAGEMENT_URL="$APP-ui-$1.$DOMAIN"
#API_URL="$APP-api-$1.$DOMAIN"

read -p `echo -e "请输入orange_DB_IP(必须为ip)[\033[34m127.0.0.1\033[0m]："` ORANGE_IP

if [ "$ORANGE_HOST" = "" ]; then
    ORANGE_HOST=127.0.0.1
fi

read -p `echo -e "请输入orange_DB_Port[\033[34m3306\033[0m]："` ORANGE_PORT

if [ "$ORANGE_PORT" = "" ]; then
    ORANGE_PORT=3306
fi

read -p `echo -e "请输入orange_DB名称[\033[34morange\033[0m]："` ORANGE_DATABASE

if [ "$ORANGE_DATABASE" = "" ]; then
    ORANGE_DATABASE=orange
fi

read -p "请输入orange_DB用户名称：" ORANGE_USER

while [ "$ORANGE_USER" = "" ]; do
    read -p "用户名不可为空，请重新输入：" ORANGE_USER
done

read -s -p "请输入orange_DB用户密码：" ORANGE_PWD

while [ "$ORANGE_PWD" = "" ]; do
    read -p "密码不可为空，请重新输入：" ORANGE_PWD
done

echo

read -p `echo -e "是否需要初始化数据库[\033[34\yes/NO\033[0m]："` DB_MIGRATE

while [ "$DB_MIGRATE" = "" ]; do
    DB_MIGRATE=NO
done

if [ "$DB_MIGRATE" = "yes" ]; then
# 导入数据
docker run \
    --rm \
    -v $PWD:/mysqldump \
    --entrypoint /import.sh \
    -e DB_NAME=${ORANGE_DATABASE} \
    -e DB_HOST=${ORANGE_IP} \
    -e DB_USER=${ORANGE_USER} \
    -e DB_PASS=${ORANGE_PWD} \
    tonybian/mysqldump
fi

# secret准备
ORANGE_PWD=$(echo -n "${ORANGE_PWD}" | base64)

echo "创建orange..."
/usr/bin/cp -f template/*.yaml ./
sed -i "s#\${SERVICE_URL}#${SERVICE_URL}#g" *.yaml
sed -i "s#\${MANAGEMENT_URL}#${MANAGEMENT_URL}#g" *.yaml
sed -i "s#\${API_URL}#${API_URL}#g" *.yaml
sed -i "s#\${ORANGE_IP}#${ORANGE_IP}#g" *.yaml
sed -i "s#\${ORANGE_PORT}#${ORANGE_PORT}#g" *.yaml
sed -i "s#\${ORANGE_DATABASE}#${ORANGE_DATABASE}#g" *.yaml
sed -i "s#\${ORANGE_USER}#${ORANGE_USER}#g" *.yaml
sed -i "s#\${ORANGE_PWD}#${ORANGE_PWD}#g" *.yaml

kubectl create -f .

# 清理文件
rm -f *.yaml

echo "orange service访问地址："
echo ${SERVICE_URL}
echo
#echo "orange api访问地址："
#echo ${API_URL}
#echo
echo "orange management访问地址："
echo ${MANAGEMENT_URL}
echo
echo "orange management访问用户："
echo admin
echo orange_admin
