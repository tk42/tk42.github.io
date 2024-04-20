---
title: Secret の外部管理について
feed: show
date: 2022-08-06
tags: 004/7,004/78,004/78/028/6,004/78/028/6/09,004/78/028/6/092
publish: true
---
# Secretをどこにどうやって保管するか問題
## 目的
何らかの秘匿情報をクラウド環境下で利用する場合，ソースコードと同様にVCS上に置くことはできない．もしSecret情報を公開リポジトリに保管したとすると，リポジトリにアクセスできるユーザーは誰でもSecretを参照できてしまうため．

これを防ぐ最も一般的な方法は（単一のクラウド構成であれば）各クラウドベンダーのマネージドサービスを利用して保管することとなる．
しかしこれでは秘匿情報のライフタイムサイクルがソースコードの更新と異なることになる．またマルチクラウド環境下での秘匿情報のリアルタイム共有など実施する場合には特別な機構を用意しなければならない．

（最近はGithubのAIが検知してくれるとはいえ）秘匿情報のcommitはビギナーエンジニアが犯しがち，かつミッションクリティカルな大罪であるので，導入コスト・学習コストの観点も興味がある．

実務的なツールについて網羅的に調査してみた．

---

## 秘匿情報を保管するためのツール群

> KubernetesのSecret情報を管理するプロダクトは複数開発されております。代表的なものとして、以下のものが挙げられます。

 - kubesec:
> gpg / AWS KMS / Google Cloud KMSなどの鍵情報を利用してSecretリソースを暗号化する。kubesecコマンドを実行して新規・既存のSecretリソースを作成することができる。

 - Sealed Secret:
> SealedSecret Operatorとkubesealコマンド、デプロイ時にクラスター上に作成される公開鍵・秘密鍵を組み合わせる。kubesealコマンドによってSecretリソースを暗号化したテンプレートが用意され、そのテンプレートを利用してSealedSecretリソースを作成することでSecretリソースが作成される。

 - External Secrets:
> ExternalSecrets Controllerを利用して、外部のサービスに保管された秘匿情報からSecretリソースを作成する。

 - Berglas:
 > Google Cloud Storage / Google Cloud KMS等を利用して秘匿情報を管理するツール。Kubernetes Secretリソースに対してはMutatingWebhookConfigurationを利用して、Google Cloud Secret Managerに保管した秘匿情報をDeploymentなどのリソースに渡す。


[External Secretsを試してみる](https://techstep.hatenablog.com/entry/2020/12/19/002142)

---

## 保管先
単一のクラウド構成であれば各クラウドベンダーのマネージドサービスを利用して保管するのが最も一般的

 - AWS Secrets Manager
 - Azure Key Vault
 - GCP Secret Manager
 - Alibaba Cloud KMS Secret Manager

### Hashicorp Vault
興味深いのは（Vagrant等の開発元である）Hashicorp が作成している Hashicorp Vault. 
サーバー・クライアント形式で稼働するため自前でサーバーを用意する必要がある．（クラウド上のアプリケーション側がクライアント）
なお，クラウドマネージドサービス化された[Hashicorp Vault Cloud](https://cloud.hashicorp.com/products/vault)もある．FreeTrialがあるとはいえ，こちらは有償（最安$0.03/hr ~ ）[料金体系](https://cloud.hashicorp.com/products/vault/pricing)
なお，本番モードではTLS通信をおこなうため自己証明書を作成するなど一手間必要になる．[Vault: 検証用に非 Dev モードでサーバを起動する](https://qiita.com/superbrothers/items/d1721c0eb867c2bc8aa1)

> VaultとはHashiCorp社が開発しているシークレット管理ツールです。
シークレットとは、DBなどのパスワードやAPIキー、証明書、暗号鍵などのことを指します。
Vaultはクライアントサーバーシステム形式で動作します。
主な機能としては以下が挙げられます。
> - データ保存前に暗号化してストレージに保存する機能
> - AWSやAzureなど一部のシステムに対して動的にシークレットを生成する機能
> - シークレットの更新機能
> - シークレットの無効化機能
> - アクセスポリシーによる権限操作機能

[シークレット管理サービスのVaultを使ってみた](https://qiita.com/_tsuru/items/3a72161de4838a36a23b)

> - 機密情報等をKey,Value形式で書き込むと暗号化して保存してくれる。
> - Secret Backendsという機能で、MySQL、PostgreSQL、AWS、LDAP等と連携し、Vaultを通じてユーザー情報の追加、変更、削除等を行える。このときLease（期限）を設定し、一定期間後にアカウントを自動削除したり、パスワードをRevokeさせることができる。
> - デフォルトの状態ではデータはすべて暗号化（Sealed）されており、Vault自身も復号する方法を知らない。復号には分散鍵による認証が必要になる。
> - Vaultへのアクセス方法はCLIかREST API。
> - Vaultへアクセスする際の認証はユーザーパスワード形式、GitHub連携、一時的なtokenの払い出しなどを扱える。
> - Vaultに対して行われた操作はすべて保存され、監査に対応できる。

[HashiCorp Vaultを機密情報データベースとして検証する](https://qiita.com/chroju/items/5f982bafecd3a1c36a9b)

> - Secure Secret Storage ... Vaultは機密情報をkey/valueの形で値を格納しますが、サーバのストレージに書き込む前に暗号化しています。このため、そのままストレージにアクセスしても機密情報を取得することは出来ません。
> - Dynamic Secrets ... Vaultは機密情報をオンデマンドで生成することが出来ます。例えばAWSへのアクセスキー等です。アプリケーションがAWSにアクセスする際にVaultにアクセス権を要求すると、Vaultは必要なアクセス権を持つAWSアクセスキーを生成し、アプリケーションに渡します。この動的に生成した機密情報には期間が設定され、期間が過ぎたら自動的に取り消しされます。
> - Data Encryption ... データの暗号化及び復号が出来ます。Vaultがこの処理の際にデータの保存を行いませんので、一時保存されたデータの流出を懸念する必要はありません。
> - Leasing and Renewal ... 機密情報に期限が設定出来ます。期限が過ぎた機密情報は自動的に削除されます。期限を延長することも可能です。
> - Revocation ... 機密情報をRevoke(失効)することが出来ます。Revokeは単一のkeyによる指定だけでなく、特定の機密をまとめて削除することが出来ます。Leaseとrevokeを活用することで、key rolling(機密情報の周期的な更新)を促すことが可能です。
> - Audit Log ... 認証、機密情報へのアクセス、動的生成、Revoke等、全ての処理に対し詳細な監査ログが保存出来ます。

[HashiCorp Vaultの基礎知識と導入](https://dev.classmethod.jp/articles/hashicorp-vault-basic-knowledge/)

---

## ツール比較（暗号化した秘匿情報を公開する系）

秘匿情報を暗号化したら公開レポジトリに置いても怖くないよね，的な思想．なお，鍵管理は各クラウドサービスに事前に登録しておく

### kubesec
平文のままgitにcommitすることを避けるため，Secretsを暗号化することで、VCSに他のリソースと一緒に保存するためのツール．
事前にクラウドマネージド・サービスにsecret登録が必要

[kubesecを使ってkubernetesのsecret定義を暗号化する](https://qiita.com/tmonoi/items/31cfa4313226b44232c0)

### Sealed Secrets
Secretsを暗号化するところは kubesec と同じ．Kubernetes に特化している？

> あなたのSecretをSealedSecretに暗号化し、公開リポジトリに保存しても安全です。SealedSecretはターゲットクラスタで動作するコントローラのみが解読でき、他の誰も（原作者でさえ）SealedSecretからオリジナルのSecretを取得することができません。

[bitnami-labs/sealed-secrets](https://github.com/bitnami-labs/sealed-secrets)

アーキテクチャ
![architecture](https://cdn-ak.f.st-hatena.com/images/fotolife/s/sshota0809/20200310/20200310103551.png)

[Sealed Secretsを利用したKubernetes Secretリソースのセキュアな管理](https://tech.uzabase.com/entry/2020/03/10/171733)

---

## ツール比較（暗号化した秘匿情報をクラウドサービスに保管する系）
### Berglas

GCP専用．こちらは公開レポジトリには保存せず，秘匿情報を暗号化した上でCloudStorageに保存するためのもの．鍵管理にはCloud KMSを利用する．

> AWSでは、情報を暗号化／復号化するための鍵を管理するAWS KMSというサービスと、鍵を使って情報を管理するためのAWS Systems Manager パラメータストアやAWS Secrets Managerというサービスが統合されており、それらを使うことで機密情報を管理することができ、他のAWSのサービスとも統合されているのでアプリケーションへの受け渡しも容易です。
> GCPでは、Cloud KMSという鍵を管理するためのサービスはありますが、鍵を使って情報を管理するためのサービスはないため、GCPが開発しているOSSのBerglasというツールか、HashiCorp社のOSSであるVaultを使って管理することが推奨されています。

> BerglasはGoで作られたCLIツールです。ざっくり説明してしまうと、鍵の管理にCloud KMSを使い、暗号化した情報の管理にCloud Storageを使い、それらの操作をいい感じにラップしてくれているツールです。Vaultと違って管理するサーバが無いので、容易に使うことができます。監査ログとしてはCloud KMSやCloud Storageの監査ログが使えますが、それ以上の管理機能はないので、より厳密な管理を求められる場合はVaultを使うという棲み分けになるかと思います。

[[GCP] berglasを使って機密情報を安全にアプリケーションに受け渡す](https://dev.classmethod.jp/articles/gcp-berglas/)

---

## ツール比較（暗号化した秘匿情報をクラウドサービスに依存せず保管する系）
### External Secrets

多様なバックエンド（保管先）に対応した Kubernetes専用 Secret 保管ツール．External Secretsならマルチクラウド構成でも安心そう．

> External Secrets Operatorは、AWS Secrets Manager、HashiCorp Vault、Google Secrets Manager、Azure Key Vaultなど、外部のシークレット管理システムを統合するKubernetesオペレータです。このオペレーターは、外部APIから情報を読み取り、その値をKubernetesシークレットに自動的に注入します。
[external-secrets/external-secrets](https://github.com/external-secrets/external-secrets)

![architecture_external_secret](https://github.com/external-secrets/kubernetes-external-secrets/raw/master/architecture.png)

[External Secretsを試してみる](https://techstep.hatenablog.com/entry/2020/12/19/002142)

リアルタイム共有についてもデフォルトでは10sごとのリソース更新がかかるとあり，この点でも有望

> external-secrets はデフォルト設定では 10000ms(10s) 間隔で SecretsManager を polling し、
機密情報に変更があった場合 Secret リソースを 更新します。

[external-secrets を使い任意のタイミングで Secret を更新する方法](https://qiita.com/hkame/items/f59297d945205d25e304)


---

