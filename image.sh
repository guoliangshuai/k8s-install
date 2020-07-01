#! /bin/bash

if [ $# -ne 1 ];then
    echo "参数：请指明K8S版本, 例如v1.16.3"
    exit 1
fi

version="$1"
echo "你指定的K8S版本时: $version"
echo

# 阿里云镜像
aliyunRegistry="registry.cn-hangzhou.aliyuncs.com/google_containers"


for i in `kubeadm config images list --kubernetes-version="$version"`
do
    aliyunImage=${i/k8s.gcr.io/$aliyunRegistry}
    echo "原始镜像: $i"
    echo "替换为阿里云镜像: $aliyunImage"
    docker pull "$aliyunImage" && docker tag "$aliyunImage" "$i"
done
