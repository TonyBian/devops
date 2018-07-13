# CI/CD

本项目致力于部署在Kubernetes中应用的持续集成（CI）和持续交付（CD），介绍`Docker`、`Kubernetes`、`Jenkins`、`Gitlab`、`Harbor`、`Nexus`六个核心组件；同时包含CI/CD代码，是自动化交付流水线的关键组成部分。

## 组件

+ Docker
+ Kubernetes
+ Jenkins
+ Gitlab
+ Harbor
+ Nexus

## 设计

### 流程图

![CICD](./docs/pics/CICD.pdf)

### 原则

+ 构建即代码：版本控制，减少配置和依赖
+ 构建插件化：保持灵活性和可维护性
+ 可靠性：完善的校验机制，确保每一次构建的必要性和正确性
+ 易用性：屏蔽细节，不让用户做主观题
+ 可复用性：参数化，一套代码完成所有构建工作
+ 安全性：合理的鉴权设计
+ 无痕性：构建结束时清理一切工作痕迹
+ 计算资源高利用率：多租户，容量管理

#### Jenkins Pipeline

传统的Jenkins使用方式是在`UI`上配置构建过程，操作繁琐、依赖性强，无法做版本控制。`Pipeline`插件使构建过程可编程，实现了构建即代码。

- [x] 构建即代码

#### 动态jnlp-slave

Jenkins集成Kubernetes实现了jnlp-slave的动态创建。jnlp-slave以容器形式在Kubernetes集群中被动态调度，当构建任务被触发时，jnlp-slave被创建；当构建任务结束时（无论成功与否），jnlp-slave被删除。

- [x] 无痕性
- [x] 计算资源高利用率

#### Docker in Docker

考虑到构建过程的高复杂度、工具的多样性，jnlp-slave的Docker镜像仅封装`jnlp-slave`、`Docker`客户端、`python with jinja2`以及gitlab证书。其他工具全部通过`Docker in Docker`的方式调用，比如`curl`、`kubectl`、`maven`、`sshpass`等。需要说明的是，jnlp-slave镜像中仅封装Docker客户端，需要通过挂载宿主机的`/var/run/docker.sock`和宿主机的`docker daemon`通信，docker相关操作还是发生在宿主机上。这一定程度的违背了`无痕性`，包括docker操作和工作目录，实现上通过自动清理来解决。带来的好处也是显而易见的，更稳定并且能够利用上Docker的缓存。

- [x] 构建插件化

参考: [Docker in Docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

#### 鉴权

+ Jenkins系统登录鉴权: LDAP认证
+ Jenkins流水线执行权限: `Manage and Assign Roles`
+ Jenkins动态创建jnlp-slave: 指定namespace，指定用户，最小权限原则；使用Jenkins Credentials保存Kubernetes集群登录认证
+ jnlp-slave访问Gitlab: jnlp-slave镜像内部封装Gitlab系统jnlp用户的ssh-key证书
+ jnlp-slave访问Harbor: 最小权限原则；使用Jenkins Credentials保存Harbor用户权限
+ jnlp-slave访问Kubernetes: 调用kubectl镜像，挂载宿主机的kubelet证书

- [x] 安全性

#### 校验

+ 发布DEV
  + 设置质量门，阻止未通过测试的发布
+ 发布UAT
  + 校验要发布的分支是否包含master分支最新提交，确保已合并master
  + 设置质量门，阻止未通过测试的发布
+ 发布PRO
  + 校验要发布的镜像版本是否为最新
  + 校验是否与master的更新有冲突

- [x] 可靠性

#### 抽象和封装

+ 抽象: 变量参数化、全局化
+ 封装: 对用户仅开放少量接口，并且仅支持列表式选择项

- [x] 可复用性
- [x] 易用性

## 任务

<table border="0">
    <tr>
        <td><strong>CI/CD</strong></td>
        <td><a href="docs/CICD/jnlp-slave.md">jnlp-slave</a></td>
        <td><a href="docs/CICD/pipeline.md">pipeline</a></td>
        <td><a href="docs/CICD/authority.md">鉴权方案</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong>Docker</strong></td>
        <td><a href="docs/docker/deploy.md">安装部署</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong>Kubernetes</strong></td>
        <td><a href="docs/kubernetes/deploy.md">安装部署</a></td>
        <td><a href="docs/kubernetes/initial.md">初始化配置</a></td>
        <td><a href="docs/kubernetes/admin.md">集群管理</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong>Jenkins</strong></td>
        <td><a href="docs/jenkins/deploy.md">安装部署</a></td>
        <td><a href="docs/jenkins/initial.md">初始化配置</a></td>
        <td><a href="docs/jenkins/plugins.md">插件配置</a></td>
        <td><a href="docs/jenkins/authority.md">权限管理</a></td>
        <td><a href="docs/jenkins/ha.md">高可用</a></td>
        <td><a href="docs/jenkins/backup.md">备份</a></td>
    </tr>
    <tr>
        <td><strong>Gitlab</strong></td>
        <td><a href="docs/gitlab/deploy.md">安装部署</a></td>
        <td><a href="docs/gitlab/initial.md">初始化配置</a></td>
        <td><a href="docs/gitlab/authority.md">权限管理</a></td>
        <td><a href="docs/gitlab/ha.md">高可用</a></td>
        <td><a href="docs/gitlab/backup.md">备份</a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong>Harbor</strong></td>
        <td><a href="docs/harbor/deploy.md">安装部署</a></td>
        <td><a href="docs/harbor/initial.md">初始化配置</a></td>
        <td><a href="docs/harbor/authority.md">权限管理</a></td>
        <td><a href="docs/harbor/ha.md">高可用</a></td>
        <td><a href="docs/harbor/backup.md">备份</a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong>Nexus</strong></td>
        <td><a href="docs/Nexus/deploy.md">安装部署</a></td>
        <td><a href="docs/Nexus/initial.md">初始化配置</a></td>
        <td><a href="docs/Nexus/authority.md">权限管理</a></td>
        <td><a href="docs/Nexus/ha.md">高可用</a></td>
        <td><a href="docs/Nexus/backup.md">备份</a></td>
        <td><a href=""></a></td>
    </tr>
</table>

## jenkins-k8s访问方式
+ [api](https://k8smeetup.github.io/docs/reference/api-overview/)
+ [kubectl]
+ [sshpass]
+ [jenkins-wrap]
+ [salt/ansible]
