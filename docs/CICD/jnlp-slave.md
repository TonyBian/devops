# jnlp-slave

Jenkins通过`jnlp`协议与后端的slave节点通信及分配任务和获取结果。传统方式下，slave使用物理机或虚拟机，并需要进行大量配置。当构建任务并发量非常大时，slave节点的管理是很大的难题。容器云时代，Jenkins结合Kubernetes实现了动态分配slave，slave的生命周期由构建任务决定，极大的提高了灵活性、可维护性和资源利用率。

## 配置

#### 1.Kubernetes配置

按照规划，jnlp-slave使用`default` namespace，使用`basic auth`方式进行Kubernetes集群外部认证

+ kube-apiserver开启`--basic-auth-file`参数
+ 创建保存用户名及密码的csv文件, 此处复用初始化集群时创建的admin用户
+ 创建`Role`及`RoleBinding`授权admin用户对default namespace的`pod`管理权限

```bash
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pods-admin
rules:
- apiGroups: [""] # "" indicates the core API group
  resources:
  - pods
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pods-admin-binding
  namespace: default
subjects:
- kind: User
  name: admin # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pods-admin # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

+ 验证admin权限

```bash
docker run -it --rm \
    harbor.corp.lc.com/library/kubectl:v1.10.2 \
    kubectl get pod --namespace default \
    --server https://10.1.10.170:8443 \
    --username admin \
    --password <passwd> \
    --insecure-skip-tls-verify
```

#### 2.Jenkins配置

+ 安装`Kubernetes`插件: Jenkins -> 系统管理 -> 管理插件 -> 可选插件 -> Kubernetes
+ 创建`Credentials`: Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> Add Credentials
+ 配置Jenkins与Kubernetes集成: Jenkins -> 系统管理 -> 云 -> Kubernetes
  + 配置Kubernetes连接
  + 配置jnlp-slave的pod模板

[配置文档](./index/jenkins-k8s.pdf)

#### 3.jnlp-slave调度控制

有时出于安全、性能等方面的考虑，需要把jnlp-slave调度到指定的某几个Kubernetes集群`node`上，同时又要阻止一些pod调度到这些node上。可以配合使用`lable`、`taint`及`tolerations`来实现。

+ 给指定node配置`lable`及`taint`

```bash

JNLP_NODE="<node_ip1> <node_ip2> ..."

for IP in $JNLP_NODE; do
    kubectl lable node $IP node-role=jnlp
    kubectl taint node $IP node-role=jnlp:NoSchedule
done
```

+ 给jnlp-slave的Pod配置`tolerations`

Jenkins -> 系统管理 -> 云 -> Kubernetes -> Kubernetes Pod Template -> Raw yaml for the Pod

```bash
spec:
  nodeSelector:
    node-role: jnlp
  tolerations:
  - effect: NoSchedule
    key: node-role
    operator: Equal
    value: jnlp
```

## jnlp-slave镜像制作

由于采用了`Docker in Docker`技术，所有的构建工具都是插件式调用的，所以jnlp-slave的镜像仅封装`jnlp-slave`包、`docker`客户端、`python with jinja2`、以及访问gitlab用到的证书。

+ `Dockerfile`

```bash
FROM jenkins/slave:3.19-1-alpine

USER root

RUN set -eux; \
    apk add --update --no-cache docker py-pip \
    && pip install --upgrade pip \
    && pip install jinja2

COPY jenkins-slave /usr/bin/jenkins-slave

RUN chmod 755 /usr/bin/jenkins-slave

COPY slave.jar /usr/share/jenkins/slave.jar

COPY id_rsa* /root/.ssh/

RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

VOLUME /var/run/docker.sock
```
