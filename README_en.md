# Orphe Piano

![image](https://cloud.githubusercontent.com/assets/1403143/24952100/7999bdde-1fb1-11e7-8345-6b9aa233ca07.gif)

Orphe Piano is completely new music application. This application is compatible with smart footwear Orphe. Music will be generated from your toes direction, walking speed, and every motion you can get by wearing Orphe.
You can download this app on [App Store](https://itunes.apple.com/ph/app/orphe-piano/id1218248232) for free.

## Requirements
- Xcode 8.3 or later
- Swift 3.1
- Orphe-SDK-Swift-1.1.0 
- and your Orphe!

You can get Orphe-SDK-Swift-1.1.0 by registering [Orphe Developers](https://sites.google.com/view/orphe-developers).


## Used libraries
- libpd (pd-for-ios)
- C4
- SCProgressHUD

## Setup
- Clone this repo. (If you download zip file, you have to setup libpd by yourself.)
- Run `pod update` on terminal.
- Drag and drop Orphe.framework to `TARGETS-> General-> Embedded Binaries`.

![unnamed](https://cloud.githubusercontent.com/assets/1403143/24959370/8eb19022-1fcd-11e7-8ce6-c505cea6c736.png)

- Check `Copy items if needed` and click Finish to complete.

![unnamed 1](https://cloud.githubusercontent.com/assets/1403143/24959394/9ce237f0-1fcd-11e7-91f1-36ee59c1b585.png)

- Open `.xcworkspace` instead of `.xcodeproj` file.