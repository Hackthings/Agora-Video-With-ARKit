# Agora Video With ARKit

*其他语言版本： [简体中文](README.zhCN.md)*

The Agora-Video-With-ARKit sample app is an open-source demo that will help you get live video chat integrated into your iOS ARKit applications using the Agora Video SDK.

With this sample app, you can:

- Send captured image from ARFrame to live video channel
- Render video frames of remote user to SCNNodes in ARSession

## Running the App
First, create a developer account at [Agora.io](https://dashboard.agora.io/signin/), and obtain an App ID. Update "ViewController.swift" with your App ID.

Next, download the **Agora Video SDK** from [Agora.io SDK](https://www.agora.io/en/blog/download/). Unzip the downloaded SDK package and copy the **libs/AgoraRtcEngineKit.framework** to the "Agora-Video-With-ARKit" folder in project.

> Custom media device protocols are provided from 2.1.0

Finally, Open Agora-Video-With-ARKit.xcodeproj, connect your iPhone／iPad device, setup your development signing and run.

## Usage
1. Move device to find a horizontal plane, there will be a red plane flashing
2. Touch the plane on screen, will add a virtual display screen
3. Run [OpenLive](https://github.com/AgoraIO/OpenLive-iOS) with same AppId, join "agoraar" as broadcaster
4. Video from remote user will be displayed on virtual screen in ARSession

## Developer Environment Requirements
* Xcode 9.0 +
* Real devices (iPhone or iPad) with ARKit supported
* iOS simulator is NOT supported

## Connect Us

- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can file bugs about this demo at [issue](https://github.com/AgoraIO/Agora-Video-With-ARKit/issues)

## License

The MIT License (MIT).
