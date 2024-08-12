## KVM

KVMとは Keyboard・Video・Mouse の略で，サーバやPCのキーボード，モニター，マウスを管理するための制御技術やデバイスのことです．

![](https://assets.st-note.com/img/1705277680873-KRbVgh9qdB.jpg?width=1200)

複数のPCを１セットのモニタ，キーボード，マウスで制御するために必要なのが，KVMスイッチです．あなたの職場にもあるのではないでしょうか．これにより，モニタ，キーボード，マウスでごちゃごちゃすることを防ぐことができます．

## IP-KVM (KVM over IP)

このKVMスイッチに，各信号をIP化したIP-KVM (KVM over IP）という技術があります．IP-KVM はネットワークを通じた遠隔管理が可能になるという点で大きく異なります．

一般的なKVMは遠隔での管理・操作ができませんが，IP-KVMであればネットワークを通じて遠隔でサーバに接続することができ，物理的にアクセスが難しい場合であっても，遠隔で接続して制御することができます．

OSが立ち上がっている状況であれば，TeamsやGoogle Meet，[Google Chromeでのリモートデスクトップ](https://support.google.com/chrome/answer/1649523?hl=ja&co=GENIE.Platform%3DDesktop)での画面操作が利用できますが，例えば専用OSでの遠隔操作を実現したい場合はIP-KVMが選択肢となってきます．

## PiKVM

安価なラズパイ本体とHDMIのビデオキャプチャデバイスがあれば，このIP-KVMを実現できるオープンソースソフトウェアが，PiKVM です．ラズパイの上で稼働する専用OSのようなイメージです．

[Flashing OS - PiKVM Handbook](https://docs.pikvm.org/flashing_os/) にあるように，デバイスとPiKVMのバージョンに合わせて適切なOSイメージをダウンロードしてMicroSDカードに書き込む必要があります．

## ~~KVM-A3~~ 失敗しました

このビデオキャプチャの入力信号は **HDMI 50Hz** である必要があります．
リフレッシュレートは日本とアメリカは **60Hz** , ヨーロッパが **50Hz** と言われています．変換器
リフレッシュレートの変換設定を探しましたが私のターゲットPCには見つからず，お蔵入りとなりました．
ターゲットのPCが **50Hz** で出力できるのであれば選択肢となります．

~~KVM-A3 はPiKVMでIP-KVMを実現するためのハードウェアで，ビデオキャプチャが含まれます．~~

![](https://m.media-amazon.com/images/I/61HnM25rSLL._AC_SX679_.jpg)
~~[Amazon | Geekworm KVM-A3 IP KVMリモートコントロールサーバー操作（外部PC遠隔操作）、Raspberry Pi 4適用 | Geekworm | ベアボーンPC 通販](https://amzn.asia/d/2qqM83O)
（画像にはラズパイをアタッチしてありますが，このページで買ってもラズパイは付属しません）~~

---

ラズパイ4が推奨されているので，これを手に入れます．他にKVM-A3，PiKVMインストール用のMicroSDカード，ケーブル類を手に入れます．

PiKVMをインストールした後，`pikvm.txt` を編集して，家のWifiパスワードを入れておくとスムーズです．
```
FIRST_BOOT=1
WIFI_ESSID='mynet' WIFI_PASSWD='p@s$$w0rd'
```

[On-boot configuration - PiKVM Handbook](https://docs.pikvm.org/on_boot_config/)



## 参考文献
[KVMとは？利用メリットとオススメIP-KVMのご紹介｜RSUPPORT株式会社 | アールサポート](https://note.com/rsupport/n/nb7fc5f665602)

[リモートKVMをラズパイで実現する「PiKVM」を試した - RemoteRoom](https://remoteroom.jp/diary/2021-12-19/)
