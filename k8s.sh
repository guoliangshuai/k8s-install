#! /bin/bash

set -e
set -x

# 前提是已经安装了Docker

swapoff -a

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

setenforce 0 || echo

# 指定版本  否则默认安装最新版本
yum install -y kubelet-1.16.3 kubeadm-1.16.3 --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

# 下载镜像
# bash image.sh v1.16.3

# 初始化集群
# cidr选择需要与docker0匹配 本示例docker0为172.17.0.1/16
kubeadm init --kubernetes-version=1.16.3 --pod-network-cidr=172.17.12.0/24 --service-cidr=172.17.11.129/25 --service-dns-domain=cluster.local

# 把kube config文件拷贝到默认目录
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# 安装CNI网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

systemctl restart kubelet && sleep 1

# 默认情况下master节点不部署pod 因此这里去掉污点 使得master能够部署pod
kubectl taint nodes --all node-role.kubernetes.io/master-
