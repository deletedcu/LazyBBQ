# LazyBBQ
<p align="center">
 <img width="100px" src="https://res.cloudinary.com/anuraghazra/image/upload/v1594908242/logo_ccswme.svg" align="center" alt="GitHub Readme Stats" />
 <h2 align="center">GitHub Readme Stats</h2>
 <p align="center">Get dynamically generated GitHub stats on your readmes!</p>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Supported%20by-VS%20Code%20Power%20User%20%E2%86%92-gray.svg?colorA=655BE1&colorB=4F44D6&style=for-the-badge"/>
</p>

## package install

1. Goto the root directory
2. run `npm i` (if already exists the node_modules folder, run `npm run newclear` instead of `npm i`)
3. run `cd ios`
4. run `pod install`
5. run `cd ..`
6. run `react-native link`

Once you do the above process successfully you don't need to the 'package install' process again in the next time.
Only reply above step when `package.json` is updated.


## iOS build (development)
1. run `npm run ios:debug`
2. run XCode by clicking TREBOW.xcworkspace
3. run the app in the XCode


## Android build (development)
1. run `npm run android:debug`
2. run `react-native run-android`


## iOS release
1. run `npm run ios:release`
2. Open XCode and go to the `Product/Scheme/Edit Scheme...` in the menu
3. Select `Run` in the left bar and select the `info` tap in the right side
4. Set the 'Build configuration' as `Release` and click the `Close` button
5. Build the iOS release version


## Android release
1. run `npm run android:release`
2. Change the `Build Variants` as `release`. In Android Studio there is the `Build Variants` tab in the left bottom side.
3. Open the Android Studio and select the `Build/Generate Signed Build/APK...` in the menu
4. Prompt the `Generate Signed APK Wizard`
5. Choose the `keystore path` - project root directory/android/keystores/release.keystore
6. Input the `Key store password`, `Key alias`, `Key password`. You can find these information in the project root directory/android/gradle.properties file
7. Click `Next` button
8. In the next screen select the `Build variants` as `release` and check the `Signature versions` as `v1` and `v2`.
9. Click the `Finish` button


## 🌱 Technologies and Frameworks
<p>
    <!-- React -->
    <img src="https://img.shields.io/badge/React-61dafb?flat=plastic&logo=react&logoColor=black" height="32" alt="React" />
    &nbsp;
    <!-- Redux -->
    <img src="https://img.shields.io/badge/Redux-764abc?flat=plastic&logo=redux&logoColor=white" height="32" alt="Redux" />
    &nbsp;
    <!-- Redux-Saga -->
    <img src="https://img.shields.io/badge/Redux%20Saga-999999?flat=plastic&logo=redux-saga&logoColor=white" height="32" alt="Redux-Saga" />
    &nbsp;
    <!-- React Router -->
    <img src="https://img.shields.io/badge/React%20Router-ca4245?flat=plastic&logo=react%20router&logoColor=white" height="32" alt="React Router" />
    &nbsp;
    <!-- Babel -->
    <img src="https://img.shields.io/badge/Babel-f9dc3e?flat=plastic&logo=Babel&logoColor=black" height="32" alt="Babel" />
    &nbsp;
    <!-- Jest -->
    <img src="https://img.shields.io/badge/Jest-c21325?flat=plastic&logo=jest&logoColor=white" height="32" alt="Jest" />
    &nbsp;
    <!-- npm -->
    <img src="https://img.shields.io/badge/npm-cb3837?flat=plastic&logo=npm&logoColor=white" height="32" alt="npm" />
    &nbsp;
    <!-- CocoaPods -->
    <img src="https://img.shields.io/badge/CocoaPods-ee3322?flat=plastic&logo=cocoapods&logoColor=white" height="32" alt="CocoaPods" />
    &nbsp;
    <!-- Gradle -->
    <img src="https://img.shields.io/badge/Gradle-02303a?flat=plastic&logo=gradle&logoColor=white" height="32" alt="Gradle" />
    &nbsp;
    <!-- Bluetooth -->
    <img src="https://img.shields.io/badge/Bluetooth-0082fc?flat=plastic&logo=bluetooth&logoColor=white" height="32" alt="Bluetooth" />
    &nbsp;
    <!-- Xcode -->
    <img src="https://img.shields.io/badge/Xcode-147efb?flat=plastic&logo=xcode&logoColor=white" height="32" alt="Xcode" />
    &nbsp;
    <!-- Android Studio -->
    <img src="https://img.shields.io/badge/Android%20Studio-3ddc84?flat=plastic&logo=android%20studio&logoColor=white" height="32" alt="Android Studio" />
    &nbsp;
</p>
