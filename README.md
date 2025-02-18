# BandwidthSDK Example

This repository provides a comprehensive example of how to utilize the BandwidthSDK library within an iOS application.

## Overview

In the `SwiftSampleApp.swift` file, you'll find the essential initialization steps. We set up BandwidthUA and establish the `BandwidthSession` variable to manage the session. All session-related logic is encapsulated within the `ContentView` class.

Additionally, the core event listening functionality is implemented through the `BandwidthSessionEventListener`, which resides in the primary application class.

## Configuration Requirements

To ensure the smooth operation of the library, your application must be configured with specific background modes in the `Info.plist` file. Make sure to configure your `Info.plist` as follows:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>audio</string>
</array>
```

In addition, it's important to add the following keys and descriptions to request camera and microphone permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>The application requires camera access for full video call functionality.</string>
<key>NSMicrophoneUsageDescription</key>
<string>The application requires microphone access for full voice call functionality.</string>
```

**Why are these configurations required?**

- `<key>UIBackgroundModes</key>`: This configuration is necessary to allow the application to continue running in the background in certain modes. In this case, `voip` and `audio` modes are included to enable voice and video calls even when the application is in the background or the device is locked.

- `<key>NSCameraUsageDescription</key>`: By adding this key and its description, the application requests permission from the user to access the camera. This is essential to enable the full functionality of video calls, as the application needs access to the camera to capture and transmit video during calls.

- `<key>NSMicrophoneUsageDescription</key>`: Similarly, by adding this key and its description, the application requests permission to access the microphone. This is crucial to enable the full functionality of voice calls, as the application needs access to the microphone to capture and transmit audio during calls.

These configurations and descriptions are important to ensure that the application functions properly and transparently while respecting user privacy and security concerns. Ensuring you include these settings in the `Info.plist` file is essential to provide a seamless and complete user experience.

## Info.plist Configuration

To facilitate the handling of connection-related values, this example includes an implementation of `InfoPlistKey`. With this feature, you can easily access and manage the necessary connection parameters in your `Info.plist` file. For instance:

```xml
<key>connection.header.pass</key>
<string>********</string>
<key>connection.header.user</key>
<string>****</string>
```
## Sample configuration
```sh
connection.header.pass                # Password for fetching token
connection.header.user                # Username for fetching token
connection.token                      # URL of customer webserver to fetch token
connection.port                       # 5061
connection.domain                     # sbc.webrtc-app.bandwidth.com (for Global) or gw.webrtc-app.bandwidth.com (for US portal)
account.password                      # use some password or leave it empty
account.display-name                  # Put from number/display name here
account.username                      # put from number here
```
## Usage Considerations

Before invoking functions such as `sendDTMF`, `hold`, `muteAudio`, or `terminate`, it is crucial to ensure that the `BandwidthSession` variable is not null. This ensures that your application operates smoothly and without errors.

## Configuring Inbound Calls

- **Overview:** We have used two major capabilities to make the inbound call

    - Caller to Callee & Callback from Callee to Caller
    - Bridging the both calls to connect caller and callee in a single call

- **Sequence Diagram**
  ![InboundFLow](bandwidth-inbound-swift.drawio.svg)

## Getting Started

1. Clone this repository to your local machine.
2. Open the project in Xcode.
3. Configure your `Info.plist` with the required background modes as described above.
4. Customize the code and integrate it into your application as needed.
