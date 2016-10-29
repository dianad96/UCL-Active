# UCL-Active

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
             )](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
             )](https://developer.apple.com/swift)
             
  The Android Version of the project can be found [here] (https://github.com/DianaD96/Team13-OpenMRS).
  The project documentation can be found [here] (https://docs.google.com/presentation/d/1W9dJ7MAcYTPxVVggNZBA3EXruDjht_86qOtaWUarwwA/edit?usp=sharing).
## The Project
The purpose of the project is to develop a UCL data store, to aggregate and manage fitness and lifestyle data submitted by UCL staff and students.
UCL will protect the anonymity of the contributors and will have oversight of the ways in which this growing data set will be used to further research in digital health analytics.

## Vision
+ Our vision is to improve physical and mental wellbeing by creating a community of physically active people engaged in sports, both inside and outside UCL and its partners.

+ We seek to apply UCL’s interdisciplinary approach to the Grand Challenge of Human Wellbeing to improve physical (and consequently mental) resilience among our staff and students; to encourage behavioral change in the broader community.

+ Our vision is aligned with UCL 2034 to apply our scholarly knowledge to contribute to improving the sporting performance of amateurs and elites worldwide. 

## System Components
![Components]

## Project Architecture
![Architecture]
![Arch]

[Architecture]: http://i65.tinypic.com/i2j7sk.png
[Arch]: http://i66.tinypic.com/4jvtb5.png
[Components]: http://i63.tinypic.com/2a6m6ad.png

## Installation
### Dependencies
* Install Cocoapods
```sh
$ gem install cocoapods
```
* Install Alamofire and SwiftyJSON
* To integrate Alamofire/SwiftyJSON into your Xcode project using CocoaPods, specify it in your Podfile:
```sh
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'uclactive' do
pod 'Alamofire', '~> 3.4'
pod 'SwiftyJSON'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'Google/SignIn'end
```
Then, run the following command:

```sh
pod install
```

---
License under Apache License 2.0
