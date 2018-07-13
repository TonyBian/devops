#!/usr/bin/env python
# -*- coding: utf-8 -*-

from jinja2 import Environment, FileSystemLoader
import os
import sys
import subprocess
import ConfigParser
import datetime


def chk_dir(dir_name):
    if not os.path.isdir(dir_name):
        os.makedirs(dir_name)


def get_env_from_conf(conf_file, env_name, env_section='env'):
    env_name = env_name.lower()
    with open(conf_file, 'r') as conf:
        cfg = ConfigParser.ConfigParser()
        cfg.readfp(conf)
    env_dict = dict(cfg.items(env_section))
    env_value = env_dict.get(env_name)
    if env_name == "all_envs":
        return env_dict
    else:
        return env_value


def render_to_file(var_dict, templates_dir, outputs_dir):
    env = Environment(loader=FileSystemLoader(
        templates_dir), keep_trailing_newline=True)
    tpl_list = os.listdir(templates_dir)
    # 渲染tpl目录下的所有模板
    for tpl in tpl_list:
        template = env.get_template(tpl)
        file_name = '.'.join(tpl.split('.')[:-1])
        output = template.render(**var_dict)
        with open(os.path.join(outputs_dir, file_name), 'w') as file:
            file.write(output)


def exec_kubectl_command(
    kubectl_command,
    workspace,
    ca_dir,
    kubectl_image,
    kube_apiserver,
    client_cert,
    client_key,
    ca_cert,
):
    kubectl = subprocess.Popen(
        'docker run --rm \
        -v {0}:{0} \
        -v {1}:{1} \
        {2} \
        {3} \
        --server {4} \
        --client-certificate {5} \
        --client-key {6} \
        --certificate-authority {7} \
        '.format(
            workspace,
            ca_dir,
            kubectl_image,
            kubectl_command,
            kube_apiserver,
            client_cert,
            client_key,
            ca_cert,
        ),
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stderr_info = kubectl.stderr.read().replace('\n', '; ')
    stdout_info = kubectl.stdout.read().replace('\n', '; ')
    return_code = kubectl.returncode
    with open(os.path.join(workspace, 'deploy.log'), 'a') as log:
        # print("[%s] [%s] [%s]" % (return_code, stdout_info, stderr_info), file=log)
        print >> log, "[%s] [%s] [%s] [%s]" % (
            datetime.datetime.now(), return_code, stdout_info, stderr_info)
    return (stdout_info, return_code)


def create_resource(kubenv_dict, yaml_name, record=''):
    create_resource_command = "kubectl apply -f {} {}".format(
        yaml_name, record)
    exec_kubectl_command(create_resource_command, **kubenv_dict)


# DEV环境清理reserve数量以外的资源，先进先出原则
# def get_global_resource(resource_type, ns_name):
#     get_resource_command = "kubectl get %s -n %s -o=jsonpath=$'{range .items[*]}{@.metadata.name}\n{end}'" % (
#         resource_type, ns_name)
#     global_resource_list = exec_kubectl_command(
#         get_resource_command, **kubenv_dict)[0].split('\n')[:-1]
#     return global_resource_list


# def get_user_resource(build_user_id, global_resource_list):
#     user_resource_list = []
#     for resource_name in global_resource_list:
#         # 获取resource_name中可能的user_id
#         likely_user_id = resource_name[-len(build_user_id):]
#         # 获取resource_name中可能的commit_id长度
#         likely_commit_id = len(
#             resource_name[:(-len(build_user_id) - 1)].split('-')[-1])

#         # 同时满足以下两个条件时，说明已存在由build_user_id创建的资源
#         if (build_user_id == likely_user_id) and (likely_commit_id == 7):
#             user_resource_list.append(resource_name)
#     return user_resource_list


# def clean_resource(resource_type, resource_list, ns_name, reserve):
#     while len(resource_list) >= int(reserve):
#         resource_name = resource_list.pop(-1)
#         delete_resource_command = "kubectl delete %s %s -n %s" % (
#             resource_type, resource_name, ns_name)
#         exec_kubectl_command(delete_resource_command, **kubenv_dict)


if __name__ == "__main__":
    get_env = os.environ.get

    # 检查模板输出目录
    workspace = get_env('WORKSPACE')
    tag_name = get_env('TAG_NAME')
    outputs_dir = os.path.join(workspace, tag_name)

    chk_dir(outputs_dir)

    # 指定env.conf文件
    conf_file = os.path.join(outputs_dir, 'env.conf')

    # 渲染yaml模板
    var_dict = get_env_from_conf(conf_file, 'all_envs')
    build_user_id = var_dict.get('build_user_id')

    env_name = var_dict.get('env_name')
    group_name = var_dict.get('group_name')

    if env_name == 'dev':
        # deploy_name = tag_name
        # svc_name = tag_name
        ns_name = '-'.join([group_name, env_name, build_user_id])
    else:
        ns_name = '-'.join([group_name, env_name])

    var_dict['ns_name'] = ns_name
    var_dict['po_name'] = var_dict.get('project')
    var_dict['po_lable'] = var_dict.get('project')
    var_dict['deploy_name'] = '{}-deploy'.format(var_dict.get('po_name'))

    templates_dir = os.path.join(
        workspace, 'devops/kubernetes/manifests/templates', env_name)

    render_to_file(var_dict, templates_dir, outputs_dir)

    # 部署Kubernetes

    # 配置kubernetes连接信息
    kubenv_dict = {
        'workspace': workspace,
        'ca_dir': var_dict.get('ca_dir'),
        'kubectl_image': var_dict.get('kubectl_image'),
        'kube_apiserver': var_dict.get('kube_apiserver'),
        'client_cert': var_dict.get('client_cert'),
        'client_key': var_dict.get('client_key'),
        'ca_cert': var_dict.get('ca_cert'),
    }

    # 构造k8s资源模板名称
    ns_yaml_name = os.path.join(outputs_dir, 'namespace.yaml')
    # limitrange_yaml_name = os.path.join(outputs_dir, 'limit-range.yaml')
    endpoint_rbac_yaml_name = os.path.join(
        outputs_dir, 'endpoints-reader-rbac.yaml')
    svc_yaml_name = os.path.join(outputs_dir, 'service.yaml')
    deploy_yaml_name = os.path.join(outputs_dir, 'deployment.yaml')
    ingress_yaml_name = os.path.join(outputs_dir, 'ingress.yaml')

    # 获取DEV环境resource_reverse
    # dev_user_resource_reverse = get_env_from_conf(conf_file, 'DEV_USER_RESOURCE_REVERSE')
    # if dev_user_resource_reverse is None:
    #     dev_user_resource_reverse = 1

    # dev_all_resource_reverse = get_env_from_conf(conf_file, 'DEV_ALL_RESOURCE_REVERSE')
    # if dev_all_resource_reverse is None:
    #     dev_all_resource_reverse = 10

    # 获取指定命名空间指定资源列表
    ns_list = get_global_resource('ns', ns_name)
    # deploy_list = get_global_resource('deploy', ns_name)
    # svc_list = get_global_resource('svc', ns_name)
    # ingress_list = get_global_resource('ingress', ns_name)

    # 获取指定用户指定资源列表
    # user_deploy_list = get_user_resource(build_user_id, deploy_list)
    # user_svc_list = get_user_resource(build_user_id, svc_list)
    # user_ingress_list = get_user_resource(build_user_id, ingress_list)

    # 部署
    if ns_name not in ns_list:
        create_resource(kubenv_dict, ns_yaml_name)
    # create_resource(limitrange_yaml_name)
    create_resource(kubenv_dict, endpoint_rbac_yaml_name)
    create_resource(kubenv_dict, svc_yaml_name)
    create_resource(kubenv_dict, deploy_yaml_name, '--record')
    create_resource(kubenv_dict, ingress_yaml_name)

    # if env_name == 'dev':
    # DEV环境资源清理
    # clean_resource('ingress', user_ingress_list, ns_name, dev_user_resource_reverse)
    # clean_resource('svc', user_svc_list, ns_name, dev_user_resource_reverse)
    # clean_resource('deploy', user_deploy_list, ns_name, dev_user_resource_reverse)
    #
    # clean_resource('ingress', ingress_list, ns_name, dev_all_resource_reverse)
    # clean_resource('svc', svc_list, ns_name, dev_all_resource_reverse)
    # clean_resource('deploy', deploy_list, ns_name, dev_all_resource_reverse)
