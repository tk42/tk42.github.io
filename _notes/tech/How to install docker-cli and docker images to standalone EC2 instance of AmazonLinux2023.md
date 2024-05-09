---
title: How to install docker-cli and docker images to standalone EC2 instance of AmazonLinux2023
date: 2024-05-09
tags: 004/09,004/678,681/3,681/32,681/324
publish: true
feed: show
---
I'm quite not sure that this post could be useful for someone else because the other day I faced a weird situation to install docker-cli and docker images to an EC2 instance of AmazonLinux2023 which is isolated from the Internet by the VPC policy in my company.

My plan was that docker-cli and docker images were downloaded with my private PC, those binaries split were uploaded to S3, those were downloaded them in in-house PC, and finally those were transferred to the EC2 instance.

First of all, I didn't know which an architecture of this AmazonLinux2023 was used, then I found `x86_64`(`amd64`) by this command. Also I found it was composed of Fedora 34.

```
uname -a
```

The official docker document said you can find docker-cli images as follows [Index of linux/fedora/34/x86\_64/stable/Packages/](https://download.docker.com/linux/fedora/34/x86_64/stable/Packages/). But resolving the dependencies libraries was found. So you should not follow that official instruction.

To download `docker-cli`, these commands worked after creating `/bin` in the current directory. In Fedora lately, you need to use `dnf` instead of `yum`, btw.

```bash
docker run --rm -v {$PWD}/bin:/tmp -it amazonlinux:2023 bash
cd /tmp
dnf install 'dnf-command(config-manager)'
dnf install --downloadonly --downloaddir=/tmp docker
```
[centos - How to install docker-ce without internet and intranet yum repository? - Stack Overflow](https://stackoverflow.com/questions/53680374/how-to-install-docker-ce-without-internet-and-intranet-yum-repository)

You would see many `rpm`s in `/bin`.

Now I was ready to download docker images. This was easier part. Only you execute is to `docker pull`, `docker save` and `docker load`. The last two commands I didn't know earlier are quite useful to save a docker image. Say

```shell
docker pull --platform linux/amd64 python:slim
docker save python:slim > image.tar
```

Next I needed to upload the image to S3 after `split`.

```bash
split -b 10M -d image.tar split-
```

Those tiny images could be downloaded through the proxy of my company. After collecting those scattered files, I merged them by

```bash
cat split-?? > image.tar
```

After `scp`, you need to install `docker-cli`. Also you need to take care of the installing order because many `rpm`s have the order of dependencies.

After installing `docker-cli`, you can `docker load` and you'll get docker images finally.

```bash
docker load < image.tar
```

