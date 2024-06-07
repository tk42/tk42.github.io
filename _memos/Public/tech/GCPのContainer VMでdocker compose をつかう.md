---
title: GCPのContainer VMでdocker compose をつかう
feed: show
date: 2024-06-07
tags: 004/6,681/3,004/678/1,681/31
publish: true
---
信じられないことだが，Container VMで docker は入っていても docker compose は有効でない．

そして，Container VMはPackageManagerが入っていないため，何かインストールすることが通常は難しい．

```docker compose``` コマンドのインストール方法が下記にのっていた．

```
sudo curl -sSL \
https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 \
  -o /var/lib/google/docker-compose
sudo chmod o+x /var/lib/google/docker-compose
mkdir -p ~/.docker/cli-plugins
ln -sf /var/lib/google/docker-compose \
  ~/.docker/cli-plugins/docker-compose
docker compose version
```

[Installing docker/compose-bin plugin on Google's Container Optimized OS - Server Fault](https://serverfault.com/questions/1131479/installing-docker-compose-bin-plugin-on-googles-container-optimized-os)