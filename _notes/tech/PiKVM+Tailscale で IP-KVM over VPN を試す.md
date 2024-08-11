## KVM

KVMとは Keyboard・Video・Mouse の略で，サーバやPCのキーボード，モニター，マウスを管理するための制御技術やデバイスのことです．

![](https://assets.st-note.com/img/1705277680873-KRbVgh9qdB.jpg?width=1200)

複数のPCを１セットのモニタ，キーボード，マウスで制御するために必要なのが，KVMスイッチです．あなたの職場にもあるのではないでしょうか．これにより，モニタ，キーボード，マウスでごちゃごちゃすることを防ぐことができます．

## IP-KVM (KVM over IP)

このKVMスイッチに，各信号をIP化したIP-KVM (KVM over IP）という技術があります．IP-KVM はネットワークを通じた遠隔管理が可能になるという点で大きく異なります．

一般的なKVMは遠隔での管理・操作ができませんが，IP-KVMであればネットワークを通じて遠隔でサーバに接続することができ，物理的にアクセスが難しい場合であっても，遠隔で接続して制御することができます．

OSが立ち上がっている状況であれば，TeamsやGoogle Meet，[Google Chromeでのリモートデスクトップ](https://support.google.com/chrome/answer/1649523?hl=ja&co=GENIE.Platform%3DDesktop)での画面操作が利用できますが，例えば専用OSでの遠隔操作を実現したい場合はIP-KVMが選択肢となってきます．

## PiKVM

安価なラズパイ本体とHDMIのビデオキャプチャデバイスがあれば，このIP-KVMを実現できるオープンソースソフトウェアが，PiKVM です．
実際にはソフトウェアというよりも，OSのように振る舞います．
PiKVMのイメージを書き込んだMicroSDカードでラズパイを起動し，ラズパイがDHCPで取得したIPアドレスを調べた後，の標準のOSとは異なる

## KVM-A3

KVM-A3 はPiKVM

## 参考文献
[KVMとは？利用メリットとオススメIP-KVMのご紹介｜RSUPPORT株式会社 | アールサポート](https://note.com/rsupport/n/nb7fc5f665602)

[リモートKVMをラズパイで実現する「PiKVM」を試した - RemoteRoom](https://remoteroom.jp/diary/2021-12-19/)
