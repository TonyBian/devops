#!/bin/bash

ES_IP=$(kubectl get pod --all-namespaces -o wide | grep elasticsearch-logging- | awk '{print $7}')

# 获取当前日志索引列表
for IP in ${ES_IP}; do
    curl -XGET 'http://'"$IP"':9200/_cat/indices/?v'
done

#指定日期(3天前)

DATA=$(date -d "3 days ago" +%Y.%m.%d)

#当前日期
time=$(date)

#删除3天前的日志
for IP in ${ES_IP}; do
    curl -XDELETE http://$IP:9200/*-${DATA}
done

if [ $? -eq 0 ]; then
    echo $time"-->del $DATA log success.." >>/tmp/es-index-clear.log
else
    echo $time"-->del $DATA log fail.." >>/tmp/es-index-clear.log
fi
