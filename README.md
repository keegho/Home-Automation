# Home-Automation
Playing with some Arduino UNO boards and opening and closing lamps using the iOS app and the Arduino attached relays.
Im using Arduino UNO with ethernet sheild that is connected to 4 relays on 4 different pins.

![gif](https://github.com/keegho/Home-Automation/blob/master/automationIoT.gif)

## What you will need?
1. Arduino UNO
2. Ethernet Sheild
3. Wiring cables and pins
4. LED's (optional)
5. LAN cable from your ethernet shield to your router
6. Breadboard (optional)
7. 4 Channel 10A Relay (30A is much more powerfull if you need to power up A/C or Heaters)
8. Resistors (optional)
9. USB Cable to power up Arduino board


## Setup Arduino
1. Go to [Teleduino](https://www.teleduino.org) and make an account and put your secret key in plist file you will create in your project folder "Karsian Home" called in file ApiKeys.plist and the `Key = "TeleduinoKey" Value= "Your Secret Key"`
2. Download their C++ library and their examples. Use the proxy example and uploaded it to your Arduino.
3. Make all your wirings from the Arduino to the relays. "Im using digital pins 4,5,6,7"
4. Don't forget to attach the GND and the VCC of course.

## Setup Pods
Using the terminal go to your project folder.
Create this podfile: "pod init" ----> "vim podfile"

 `platform :ios, '9.0'`

`target 'Karsian Home' do`
 ` use_frameworks!`
 ` pod 'Alamofire', '~> 4.0'`
 ` pod 'SwiftyJSON'`
 ` pod 'SwiftSpinner'`
`end`

2. ESC then save using ":x!" command. Then install the pod file: "pod install"

3. Open the `.xworkspace` extenstion and play the code.

![img](http://i.imgur.com/UsdzSb4.png)



