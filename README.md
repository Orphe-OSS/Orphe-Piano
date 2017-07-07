# Orphe Piano

![image](https://cloud.githubusercontent.com/assets/1403143/24952100/7999bdde-1fb1-11e7-8345-6b9aa233ca07.gif)

[ < README in English > ](/README_en.md)

Orphe PianoはスマートフットウェアOrphe対応のまったく新しい音楽演奏アプリケーションです。
Orpheを履いて歩くことで、つま先の向き・歩きの速さといった足の動きからあなただけの楽曲が生成され、演奏できます。
本アプリケーションは[App Store](https://itunes.apple.com/ph/app/orphe-piano/id1218248232)にて無料で配信しています。

## 要件
- Xcode 8.3
- Swift 3.1
- Orphe-SDK-Swift-1.1.0 
- and your Orphe!

Orphe-SDK-Swift-1.1.0はFacebookグループの[Orphe Developers Community](https://www.facebook.com/groups/1757831034527899/)に参加いただくことでダウンロードすることが出来ます。


## 使用ライブラリ
- libpd (pd-for-ios)
- C4
- SCProgressHUD

libpdはサブモジュールとして、C4 と SCProgressHUD は CocoaPods で管理しています。

## 導入方法
- gitでクローンしてください。(zipでダウンロードした場合、libpdを手動で導入する必要があります。)
- CocoaPodsの環境を設定した後 `pod update` でライブラリを導入。
- Orphe.framework 1.1.0を`TARGETS->General->Embedded Binaries`にドラッグ・アンド・ドロップする。

![unnamed](https://cloud.githubusercontent.com/assets/1403143/24959370/8eb19022-1fcd-11e7-8ce6-c505cea6c736.png)

- `Copy items if needed`をチェックしてFinishで完了。

![unnamed 1](https://cloud.githubusercontent.com/assets/1403143/24959394/9ce237f0-1fcd-11e7-91f1-36ee59c1b585.png)

- `.xcodeproj`ではなく`.xcworkspace`を開きます。
