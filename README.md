# WoundGenius SDK Sample App

This repository contains the WoundGenius SDK Sample App, the purpose of which is to demonstrate the available features of WoundGenius SDK.
The Sample App is also to be used as a reference app for an iOS team integrating the WoundGenius SDK into their project.

## Initial Setup
To launch the Sample App, perform the following actions:
1. Request the WoundGenius SDK license and request access to the WoundGenius SDK repository for your iOS Developers. Follow the instructions listed here to do that: https://support.imito.io/portal/en/kb/articles/licence-key (You'll need to Sign Up, provide the Bundle Ids you are planning to use, GitHub username of the developers).
2. Download/Pull this Sample app to your machine.
3. In Mac OS Terminal navigate to Sample app folder. To the level where Sample.xcodeproj & Podfile is located.
4. In Mac OS Terminal call **pod install**. TensorFlowLiteTaskVision pod should get installed.
5. In Mac OS Terminal call **open .**.
6. Run the **Sample.xcworkspace** file (Xcode should be installed).
5. Pull the WoundGenius SDK to your machine. Follow the **"Import WoundGenius SDK as a Swift Package"** Section, integrate the WoundGenius SDK into the Sample app. https://github.com/imitoag/woundgenius-ios-sdk/ (Make sure the branch/version matches the Sample App version).
6. While requesting the license, you provided the Bundle Identifiers to be whitelisted. Change the Sample application Bundle Identifier to one of your whitelisted Bundle Identifiers. Also, pick your Apple Development Team in order to be able to launch the Sample application on a real device.
7. Run the application on an iPhone or iPad. (To run the app on Simulator - switch the Target to "SampleSimulator", it won't be possible to test the camera-related features and wound auto-detection features on Simulator.)
8. After you launch the application, go to Settings and paste the license key you've received at Step 1.

<img src="README/settings_button.jpg" width="200">  <img src="README/license_key.jpg" width="200"> 

7. Navigate back from Settings Screen. Click Start Capturing. Grant permission for the app to access the Camera.

