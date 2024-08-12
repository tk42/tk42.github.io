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

ラズパイ4.0が推奨されているので，本記事ではこちらを利用します．

![](https://m.media-amazon.com/images/I/51ETv8Le3nL._AC_.jpg)
[Amazon.co.jp: 【国内正規代理店品】Raspberry Pi4 ModelB 4GB ラズベリーパイ4 技適対応品【RS・OKdo版】 : パソコン・周辺機器](https://amzn.asia/d/aBj2KvR)


## ~~KVM-A3~~ 失敗しました

このビデオキャプチャの入力信号は **HDMI 50Hz** である必要があります．
リフレッシュレートは日本とアメリカは **60Hz** , ヨーロッパが **50Hz** と言われています．
リフレッシュレートの変換設定を探しましたが私のターゲットPCには見つからず，お蔵入りとなりました．
ターゲットのPCが **50Hz** で出力できるのであれば選択肢となります．

~~KVM-A3 はPiKVMでIP-KVMを実現するためのハードウェアで，ビデオキャプチャが含まれます．~~

~~[Amazon | Geekworm KVM-A3 IP KVMリモートコントロールサーバー操作（外部PC遠隔操作）、Raspberry Pi 4適用 | Geekworm | ベアボーンPC 通販](https://amzn.asia/d/2qqM83O)
（画像にはラズパイをアタッチしてありますが，このページで買ってもラズパイは付属しません）~~

## THANKO SHDSLRVC

[一眼カメラやビデオカメラをWEBカメラに！「HDMI to USB WEBカメラアダプタ」 | 【公式】サンコー通販サイト](https://www.thanko.jp/view/item/000000003615)

![](https://m.media-amazon.com/images/I/61OzbprGOnL._AC_SX679_.jpg)
[Amazon.co.jp: サンコー(Sanko) レアモノショップ 一眼カメラやビデオカメラをWEBカメラに!「HDMI to USB WEBカメラアダプタ」 : パソコン・周辺機器](https://amzn.asia/d/4fe105g)

ビデオキャプチャデバイスはこちらを利用することにしました．

---

## ケーブル接続

ケーブルの接続先をまとめると次のようになります．

| 種別                | ターゲットPC | ケーブル            | ラズパイ       |
| :---------------- | ------- | --------------- | ---------- |
| HDMI              | HDMI出力  | THANKO SHDSLRVC | USB**2.0** |
| データ（キーボード・マウス）・給電 | USB2.0  | USB3.0オスオスケーブル  | USB-C      |
HDMI のビデオキャプチャデバイスのUSB接続先を **USB2.0** に接続しないと NO SIGNAL となりました．また今回試したいOSはLinuxだったのですが最初挙動不審でした．そこでWindowsのディスプレイの設定で50Hzに設定することで動作確認をし，それからLinuxをブートするようにすると問題なく表示されるようになりました．

ラズパイはUSB給電なのでターゲットPCの電源をOFFにするとラズパイも強制切断されます．
私の場合，強制切断でも問題ないため上２段の2本構成にしていますが，これを防ぐには次の方法が取れます．
 - 別のUSB給電ケーブルを用意する
 - 給電用の線が出ているY字型のUSBケーブルを用意する

![](https://m.media-amazon.com/images/I/71z8gLK081L._AC_SX679_.jpg)
[Amazon | アイ・オー・データ USB電源補助ケーブル 電力供給 日本メーカー UPAC-UT07M ブラック | アイ・オー・データ | USBケーブル 通販](https://amzn.asia/d/36S5MOd)


---

## IP-KVM セットアップ手順

### 用意するもの
必要なものを再掲します
- ラズパイ4.0
- THANKO SHDSLRVC
- MicroSDカード（PiKVMインストール用）
- USB3.0 ケーブル
- HDMIケーブル

### PiKVMのインストール

[Flashing OS - PiKVM Handbook](https://docs.pikvm.org/flashing_os/) にあるように，デバイスとPiKVMのバージョンに合わせて適切なOSイメージをダウンロードしてMicroSDカードに書き込む必要があります．

今回の構成では， 
>- **Raspberry Pi 4**
    - [For HDMI-USB dongle](https://files.pikvm.org/images/v2-hdmiusb-rpi4-latest.img.xz)

にある `v2-hdmiusb-rpi4-latest.img.xz` を書き込むことになります．

イメージの書き込み方法は [Flashing OS - PiKVM Handbook](https://docs.pikvm.org/flashing_os/#using-linux-cli-advanced-users) を見ると良いと思います．

有線LANほど確実なものはないですが，Wifiで進めることもできます．詳細は[On-boot configuration - PiKVM Handbook](https://docs.pikvm.org/on_boot_config/)を参考

最後にMicroSDにラズパイをセットして，電源ケーブルを接続します．ラズパイのローカルIPアドレスをルータ画面や`arp -a`で得た後，そのIPアドレスにWebブラウザからアクセスすると

![[../../assets/img/Public/Screenshot 2024-08-11 at 19.52.33.png]]

と表示されます．（ローカルIPは `192.168.8.165`）


## Tailscale セットアップ手順

Tailscaleを使うことでVPNを構築できるため，通常のインターネット回線を用いて，たったいま構築したIP-KVMにアクセスすることができます．



## 参考文献
[KVMとは？利用メリットとオススメIP-KVMのご紹介｜RSUPPORT株式会社 | アールサポート](https://note.com/rsupport/n/nb7fc5f665602)

[リモートKVMをラズパイで実現する「PiKVM」を試した - RemoteRoom](https://remoteroom.jp/diary/2021-12-19/)
