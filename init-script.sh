#!/bin/bash

exec >/tmp/output 2>&1
set -x

version="%VERSION%"
trustgraph=/usr/local/trustgraph

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade

apt install -y python3 python3-pip unzip python3-venv
pip install --break-system-packages awscli

apt install -y podman-docker podman-compose

apt install -y wget

# Turn off docker warning
touch /etc/containers/nodocker

# install docker-compose.yaml
# grafana
# prometheus

mkdir -p ${trustgraph}/deploy

python3 -m venv ${trustgraph}/env
. ${trustgraph}/env/bin/activate

pip install trustgraph-cli==${version}

bucket="%BUCKET%"
deploy_key="%DEPLOY_KEY%"

cd ${trustgraph}/deploy

export AWS_DEFAULT_REGION="%REGION%"

aws s3 cp "s3://${bucket}/${deploy_key}" output.zip
unzip -q output.zip
rm output.zip

chcon -Rt svirt_sandbox_file_t ${trustgraph}/deploy

podman-compose -f docker-compose.yaml pull

podman-compose -f docker-compose.yaml up -d

