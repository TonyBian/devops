# 安装部署Jenkins

## shell脚本

```bash
#!/bin/sh

MODE=$1
MODULE_NAME=$2

PORT=80
JNLP_PORT=50000
JENKINS_HOME=/data/jenkins_home

run()
{
if [ "$MODULE_NAME" = 'jenkins' ]; then
docker run -it \
    --publish ${PORT}:8080 \
    --publish ${JNLP_PORT}:50000 \
    --name jenkins \
    --restart always \
    --volume ${JENKINS_HOME}:/var/jenkins_home \
    --volume /etc/localtime:/etc/localtime \
    --env JAVA_OPTS="-Dhudson.model.LoadStatistics.clock=2 \
                     -Dhudson.slaves.NodeProvisioner.recurrencePeriod=3 \
                     -Dhudson.slaves.NodeProvisioner.recurrencePeriod=0.1 \
                     -Dhudson.slaves.NodeProvisioner.initialDelay=0 \
                     -Dhudson.slaves.NodeProvisioner.MARGIN=50 \
                     -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85" \
    -d jenkins/jenkins:lts
fi
}

rm()
{
docker rm ${MODULE_NAME}
}

start()
{
docker start ${MODULE_NAME}
}

stop()
{
docker stop ${MODULE_NAME}
}

status()
{
docker ps | grep ${MODULE_NAME}
}

case "${MODE}" in
    run)
        run
        sleep 2s
        status
        ;;
    rm)
        rm
        ;;
    start)
        start
        sleep 2s
        status
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 2s
        start
        sleep 2s
        status
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {run|rm|start|stop|restart|status} {jenkins}"
esac
```

## 系统管理

### 安装插件

+ Blue Ocean Pipeline Editor
+ Build Timestamp
+ Config API for Blue Ocean
+ Dashboard for Blue Ocean
+ Display URL for Blue Ocean
+ Events API for Blue Ocean
+ Git Pipeline for Blue Ocean
+ GitHub Pipeline for Blue Ocean
+ GitLab
+ i18n for Blue Ocean
+ JIRA Integration for Blue Ocean
+ JIRA Pipeline Steps
+ Kubernetes :: Pipeline :: DevOps Steps
+ Kubernetes :: Pipeline :: Kubernetes Steps
+ Nested View
+ Personalization for Blue Ocean
+ Pipeline Utility Steps
+ Pipeline: Multibranch with defaults
+ Role-based Authorization Strategy
+ Simple Build DSL for Pipeline
+ Simple Travis Pipeline Runner
+ SonarQube Scanner
+ SSH Slaves
+ Travis YML
+ user build vars
+ Workspace Cleanup

### 安全配置

[配置文档](./index/安全配置.pdf)

参考: https://blog.csdn.net/u013066244/article/details/53407985

### 系统配置

+ 取消Usage Statistics
+ Jenkins Location
