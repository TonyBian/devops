#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {dev|test|prod}"
    exit 1
fi

ADMIN_USER=admin
APP_NAME=weave
NS_NAME=weave
HOST_NAME=$1.k8s.io
HOST_URL=${APP_NAME}.${HOST_NAME}
BASIC_AUTH_FILE=${APP_NAME}-basic-auth
BASIC_AUTH_SEC=${APP_NAME}-basic-secret
#TLS_SEC=${APP_NAME}-tls-secret

#mkdir -p cert

command -v htpasswd
if [ $? -ne 0 ]; then
    yum -y install httpd
fi

echo "部署weave scope..."
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "创建weave admin用户静态密码文件..."
htpasswd -c ${BASIC_AUTH_FILE} ${ADMIN_USER}

echo "创建weave admin secret..."
kubectl create secret generic ${BASIC_AUTH_SEC} --from-file ${BASIC_AUTH_FILE} -n ${NS_NAME}

#echo "配置TLS证书..."
#openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout cert/tls.key -out cert/tls.crt -subj "/CN=${HOST_URL}"
#kubectl create secret tls ${TLS_SEC} --key cert/tls.key --cert cert/tls.crt -n ${NS_NAME}

echo "创建ingress..."
/usr/bin/cp -f template/ingress.yaml ingress.yaml
sed -i "s#\${HOST_URL}#${HOST_URL}#g" ingress.yaml
sed -i "s#\${BASIC_AUTH_SEC}#${BASIC_AUTH_SEC}#g" ingress.yaml
sed -i "s#\${TLS_SEC}#${TLS_SEC}#g" ingress.yaml
kubectl apply -f ingress.yaml

echo "文件清理..."
rm -f ./${BASIC_AUTH_FILE}
rm -f ./ingress.yaml
rm -f ./cert/*

echo "weave scope访问地址："
echo ${HOST_URL}
echo
echo "weave scope访问用户："
echo ${ADMIN_USER}
