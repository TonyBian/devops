FROM rabbitmq:3.6.11-management-alpine

RUN apk update && apk add ca-certificates && \
    apk add tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
    
ADD plugins/*-0.8.0.ez /opt/rabbitmq/plugins/

RUN rabbitmq-plugins enable --offline autocluster
