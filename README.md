
# Deploy TrustGraph in an AWS EC2 using Pulumi

## Overview

This is a simplified installation of TrustGraph for analysis or
experimentation purposes.  It deploys a single AWS EC2 instance configured to
run Podman, and deploys from a podman-compose file.  For production
purposes, this is a questionable configuration as, for resilience there
is a single EC2 instance which is a single point of failure.

The deployed instance has a role setup so that it can access AWS Bedrock,
which means no credential passing-around is needed.

You would consider container engines such as EKS or ECS to use operationally.

## How it works

This uses Pulumi which is a deployment framework, similar to Terraform
but:
- Pulumi has an open source licence
- Pulumi uses general-purposes programming languages, particularly useful
  because you can use test frameworks to test the infrastructure.

Roadmap to deploy is:
- Install Pulumi
- Setup Pulumi
- Configure your environment with AWS credentials
- Modify the local configuration to do what you want
- Deploy
- Use the system

# Deploy

## Deploy Pulumi

Navigate to the Pulumi directory:

```
cd pulumi
```

Then:

```
npm install
```

## Setup Pulumi

You need to tell Pulumi which state to use.  You can store this in an S3
bucket, but for experimentation, you can just use local state:

```
pulumi login --local
```

Pulumi operates in stacks, each stack is a separate deployment.  The
git repo contains the configuration for a single stack `analysis`, so you
could:

```
pulumi stack init analysis
```

and it will use the configuration in `Pulumi.analysis.yaml`.

## Configure your environment with AWS credentials

Standard AWS client configuration is used e.g. set `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` or `AWS_PROFILE`.

## Modify the local configuration to do what you want

You can edit:
- settings in `Pulumi.analysis.yaml`
- change `docker-compose.yaml` with whatever you want to deploy, or
- change the version number in `init-script.sh` to match the version
  you are deploying

The docker-compose.yaml file was created using the TrustGraph config portal,
so you can re-generate your own.  The only change was to delete the
AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY references in the config
file.  These aren't needed as this is running in an AWS instance, AWS
metadata is used to configure credentials.

## Deploy

```
pulumi up
```

Just say yes.

If everything works, a file, `ssh-private.key` will contain a secret SSH
login key, and the system will show you the IP address allocated to the
instance.

## Use the system

If everything launches OK, you can login to the deployed instance.

The secret key `ssh-private.key` may not have the right permissions, which
SSH doesn't like, so you can change:

```
chmod 600 ssh-private.key
```

and then you can login to the IP address you have been given:

```
ssh -i ssh-private.key ubuntu@w.x.y.z
```
where w.x.y.z is to be replaced with the IP address you have been given.

There will be a bunch of containers running in Podman, which you can view:

```
sudo podman ps -a
```

To use the TrustGraph CLI:

```
. /usr/local/trustgraph/env/bin/activate
```

Interesting post numbers are 3000 (Grafana) and 8888 (Workbench).

You can logout of SSH and login with port forwarding:

```
ssh -L 3000:localhost:3000 -L 8888:localhost:8888 \
    -i ssh-private.key ubuntu@w.x.y.z
```

This will allow you to access Grafana and the Workbench UI from your local
browser using `http://localhost:3000` and `http://localhost:8888`
respectively.

## How the config was built

```
rm -rf env
python3 -m venv env
. env/bin/activate
pip install --upgrade git+https://github.com/trustgraph-ai/trustgraph-templates@8f3b2bb0
tg-configurator -t 1.6 -v 1.6.5 --platform docker-compose -R > docker-compose.yaml
tg-configurator -t 1.6 -v 1.6.5 -O > tg-config.json
```

