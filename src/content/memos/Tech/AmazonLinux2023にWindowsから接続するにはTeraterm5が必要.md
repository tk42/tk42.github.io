---
title: AmazonLinux2023にWindowsから接続するにはTeraterm5が必要
feed: show
date: 2024-05-09
tags: 004/7,004/78,004/78/1,004/78/11,004/78/11/2
publish: true
---
> Amazon Linux 2023 と Amazon Linux 2 の違いは、[こちらの Document](https://docs.aws.amazon.com/linux/al2023/ug/compare-with-al2.html) に記載されています。**特に Windows で Teraterm を使っているユーザーに影響があるのが、デフォルトで SSH の `ssh-rsa` 署名が無効になったことです。
> `ssh-rsa` の危険性について、OpenSSH のリリースノートに書かれているのですが、USD$50K より少ない金額で、SHA-1 アルゴリズムに対する選択プレフィックス攻撃が出来る問題があります。つまり、セキュリティ上の問題で、`ssh-rsa` は使わない方が良いということです。
> Teraterm についてのお話に移ります。
 SSH を接続するときに、接続元のクライアントと接続先サーバー間で「自分はこのアルゴリズムを使えるよ」と互いに送りあい、利用する暗号方式を決めていきます。今回のアップデートで、Amazon Linux 2023 の SSH サーバー側は、 `ssh-rsa` 署名がデフォルトで使えなくなりました。接続元のクライアント側は、代わりに `rsa-sha2-256` および `rsa-sha2-512` プロトコルや、ed25519 キーを使用した `ssh-ed25519` を利用する必要があります。
 Teraterm では 5.0 beta 1 のバージョンから、 `rsa-sha2-256` および `rsa-sha2-512` プロトコルがサポートされました。 5.0 beta 1 のバージョンのダウンロードや Changelog は以下の URL から確認できます。
 表現を変えると、Teraterm 5.0 beta 1 よりも古いバージョンを使っている場合は、 `rsa-sha2-256` および `rsa-sha2-512` プロトコルが使えません。そのため、Amazon Linux 2023 に接続するときに、今まで使っていた Teraterm で接続できないことが有りえます。(何らかの意識をしていない限り、基本的には Teraterm 5.0 beta 1 よりも古いバージョンでは接続できません)

[Amazon Linux 2023 に Teraterm から SSH 接続してみた : ssh-rsa 署名無効化対応 #AWS - Qiita](https://qiita.com/sugimount-a/items/78b5c02d4c286b7c266b)