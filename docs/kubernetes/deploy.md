## 安装

https://github.com/gjmzj/kubeasz

## harbor认证

```bash
curl -sLf http://static.corp.lc.com/static/docker/harbor/prod/install.sh | bash
```

## 插件

### kubeasz项目

#### helm

```bash
ansible-playbook /etc/ansible/roles/helm/helm.yml
```

#### kubedns

```bash
kubectl create -f /etc/ansible/manifests/kubedns
kubectl scale deployment -n kube-system kube-dns --replicas=3
```

#### dashboard

+ 安装

```bash
kubectl create -f /etc/ansible/manifests/dashboard
```

+ 访问地址

https://10.1.100.201:8443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

+ 获取token

```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

#### heapster

```bash
kubectl create -f /etc/ansible/manifests/heapster
```

#### prometheus

+ 安装

```bash
cd /etc/ansible/manifests/prometheus

# 修改prom-alertsmanager.yaml中的邮箱配置

helms install \
    --name monitor \
    --namespace monitoring \
    -f prom-settings.yaml \
    -f prom-alertsmanager.yaml \
    -f prom-alertrules.yaml \
    prometheus

helms install \
    --name grafana \
    --namespace monitoring \
    -f grafana-settings.yaml \
    -f grafana-dashboards.yaml \
    grafana
```

+ 访问地址

```bash
http://10.1.100.3:39000
http://10.1.100.3:39001
http://10.1.100.3:39002
```

### devops项目

```bash
git clone http://gitlab.corp.lc.com/DevSecOps-group/devops.git
```

#### EFK

+ 安装

```bash
NODE=$(kubectl get node -o=jsonpath=$'{range .items[*]}{@.metadata.name} {end}')

for IP in $NODE; do
    kubectl label nodes $IP beta.kubernetes.io/fluentd-ds-ready=true
done

kubectl create -f devops/kubernetes/manifests/plugins/efk
kubectl create -f devops/kubernetes/manifests/plugins/efk/es-without-pv
```

+ 容量管理

```bash
echo "0 0 * * * sh /root/devops/kubernetes/manifests/plugins/efk/es_clean.sh" >> /var/spool/cron/root
```

#### ingress

+ 安装traefik

```bash
MASTER=$(kubectl get node -l kubernetes.io/role=master -o=jsonpath=$'{range .items[*]}{@.metadata.name} {end}')

for IP in $MASTER; do
    kubectl label nodes $IP edgenode=true
done

cd devops/kubernetes/manifests/plugins/ingress/traefik 
sh install.sh prod
cd -
```

+ 配置hosts

```bash
10.1.100.201 prod.k8s.io
```

+ 配置haproxy

```bash
listen traefik-ingress-lb
        bind 0.0.0.0:80
        mode tcp
        option tcplog
        balance source
        server 10.1.100.3 10.1.100.3:80  check inter 10000 fall 2 rise 2 weight 1
        server 10.1.100.4 10.1.100.4:80  check inter 10000 fall 2 rise 2 weight 1
        server 10.1.100.5 10.1.100.5:80  check inter 10000 fall 2 rise 2 weight 1
```

+ 访问地址

```bash
http://prod.k8s.io
```

#### weave scope

https://www.weave.works/docs/scope/latest/installing/#k8s

```bash
cd devops/kubernetes/manifests/plugins/ingress/weave-scope
sh install.sh prod
cd -
```

+ 配置hosts

```bash
10.1.100.201 weave.prod.k8s.io
```

+ 访问地址

```bash
http://weave.prod.k8s.io
```

#### jnlp

```bash
kubectl create -f devops/kubernetes/manifests/plugins/rbac/admin/jnlp-admin.yaml
```

## 组件

### rabbitmq

```bash
cd devops/kubernetes/manifests/components/rabbitmq
sh install.sh prod
cd -
```

### zookeeper

```bash
cd devops/kubernetes/manifests/components/zookeeper
sh install.sh prod
cd -
```