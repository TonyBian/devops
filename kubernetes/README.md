# `api`

## `ca`证书

```bash
K8S_URL="https://10.1.10.170:8443"
CA_DIR=/etc/kubernetes/ssl
curl ${K8S_URL} --cacert ${CA_DIR}/ca.pem --key ${CA_DIR}/admin-key.pem --cert ${CA_DIR}/admin.pem
```

## `Restful api`

HTTP Verb | Request Verb 
:-:|:-
POST|create
GET,HEAD|get (for individual resources), list (for collections)
PUT|update
PATCH|patch
DELETE|delete (for individual resources), deletecollection (for collections)

```bash
API_USER=readonly
API_PWD=readonly
PROJECT=greeting
# API_TOKEN=$(cat /etc/kubernetes/ssl/token.csv | grep kubelet | awk -F ',' '{print $1}')
# API_CACERT="--cacert  /etc/kubernetes/ssl/ca.pem"
K8S_URL="https://10.1.10.170:8443"
CA_DIR=/etc/kubernetes/ssl
NS_NAME=dev
RSRC_TYPE=services
RSRC_NAME=${PROJECT}-service

# `GET`
docker run -it --rm \
-v ${CA_DIR}:${CA_DIR} \
harbor.corp.lc.com/library/curl -X GET \
${K8S_URL}/api/v1/namespaces/default/services \
--cacert ${CA_DIR}/ca.pem \
--key ${CA_DIR}/admin-key.pem \
--cert ${CA_DIR}/admin.pem

curl -X GET \
${K8S_URL}/api/v1/namespaces/${NS_NAME}/${RSRC_TYPE}/${RSRC_NAME} \
--basic --user ${API_USER}:${API_PWD} --insecure
# -H "Authorization: Bearer ${API_TOKEN}" ${API_CACERT}

# POST
curl -X POST \
${K8S_URL}/api/v1/namespaces/${NS_NAME}/${RSRC_TYPE} \
-H "content-Type: application/yaml" \
-d "$(cat name.yaml)" \
--basic --user ${API_USER}:${API_PWD} --insecure
# -H "Authorization: Bearer ${API_TOKEN}" ${API_CACERT}

# PUT
curl -X PUT \
${K8S_URL}/api/v1/namespaces/${NS_NAME}/${RSRC_TYPE}/${RSRC_NAME} \
-H "content-Type: application/yaml" \
-d "$(cat name.yaml)" \
--basic --user ${API_USER}:${API_PWD} --insecure
# -H "Authorization: Bearer ${API_TOKEN}" ${API_CACERT}

```
