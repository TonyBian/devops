#!/bin/bash

set -eux
set -o pipefail

BRANCH_COMMIT_ID_LIST=$(git log --pretty=format:"%h")

PRINT_INFO()
{
echo "master HEAD commit id: ${MASTER_SHORT_COMMIT_ID}"
echo -e "branch commit id list: \n${BRANCH_COMMIT_ID_LIST}" | head -10
}

if [ $(echo ${MASTER_SHORT_COMMIT_ID} | wc -L) -ne 7 ]; then
    echo "master分支HEAD commit id有误！"
    echo "错误的返回值: ${MASTER_SHORT_COMMIT_ID}"
    exit 1
fi

if [[ ${BRANCH_COMMIT_ID_LIST} =~ ${MASTER_SHORT_COMMIT_ID} ]]; then  
    PRINT_INFO
    echo 
    echo "commit id 校验成功！" 
else
    PRINT_INFO
    echo
    echo -e "commit id 校验失败！\n请在${BRANCH_NAME}分支下使用git merge master命令进行合并master操作。"
    exit 1
fi
