//
//  ViewController.swift
//  Karsian Home
//
//  Created by Kegham Karsian on 12/12/16.
//  Copyright © 2016 appologi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SystemConfiguration
import AVFoundation

protocol Utilities {
    
}

class ViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    
    var audio: AVAudioPlayer!
    
    var key: String!
    
    let mode = (0,1)  //0 is input   1 is output
    let pin = (4,5,6,7) // pin numbers on arduino board
    let toggle = (0,1,2) //0 is off   1 is on   2 is toggleing
    var setDigitalURL: URL!
    var getDigitalURL: URL!
    var definePinModeURL:URL!
    var getAllInputsURL: URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        
        initializeSoundPlayer()
        initializeAppView()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Initializing the audio player
    func initializeSoundPlayer() {
        
        guard let fileURL = Bundle.main.url(forResource: "Click2", withExtension: "mp3") else {
            
            print("Cannot find file")
            
            return
        }
        
        do {
            audio = AVAudioPlayer()
            try audio = AVAudioPlayer(contentsOf: fileURL)
            audio.volume = 0.7
            
        } catch {
            print("Error loading music file")
        }
    }
    
    func tickSound() {
        
        if audio != nil {
            
            audio.play()
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        //Identifying button tapped from its tag number
        switch sender.tag {
            
        case 0:
            tickSound()
            callTelduino(pin: pin.0, toggle: toggle.2, key: key, sender: sender, method: .post) //4
        case 1:
            tickSound()
            callTelduino(pin: pin.1, toggle: toggle.2, key: key, sender: sender, method: .post) //5
        case 2:
            tickSound()
            callTelduino(pin: pin.2, toggle: toggle.2, key: key, sender: sender, method: .post) //6
        case 3:
            tickSound()
            callTelduino(pin: pin.3, toggle: toggle.2, key: key, sender: sender, method: .post) //7
        default:
            return

        }
    }

    
    //Observer function fires when app loads
    func didBecomeActive() {
        
        //Check if phone has internet connection and is not on flight mode.
        if currentReachabilityStatus == ReachabilityStatus.notReachable {
            alertMessage(title: "Connection Error", message: "No connection found. Please check your phone connection status.")
                    button4.isEnabled = false; button3.isEnabled = false; button2.isEnabled = false; button1.isEnabled = false
            return
            
        } else {
            
            activityIndicator.startAnimating()
            
            getAllInputValues(key: key, method: .post) { (status, newValues, msg) in
                
                if status == 200 {
                    
                    //Change button colors according to values in array
                    self.changeButtonColors(values: newValues!)
                    
                } else {
                    
                    print("Error getting pin values")
                    
                    self.alertMessage(title: "Connection Error", message: "Failed retrieving pin values")
                    return
                }
                self.activityIndicator.stopAnimating()
            }
        }

    }
    
    
    func callTelduino(pin:Int, toggle:Int, key:String, sender:UIButton, method:HTTPMethod) {
        
        activityIndicator.startAnimating()
        setDigitalURL = URL(string: "https://us01.proxy.teleduino.org/api/1.0/328.php?k=\(key)&r=setDigitalOutput&pin=\(pin)&output=\(toggle)&expire_time=0&save=1")
        
        Alamofire.request(setDigitalURL, method: method, parameters: [:], encoding: JSONEncoding.default, headers: [:])
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success( _):
                    //   print("Success \(data)")
                    self.activityIndicator.stopAnimating()
                    if sender.backgroundColor == UIColor.red {
                        sender.backgroundColor = UIColor.green
                    } else {
                        sender.backgroundColor = UIColor.red
                    }
                    
                case .failure(let err):
                    print("Error: \(err)")
                    self.alertMessage(title: "Connection Error", message: "Failed in sending request")
                }
                
            })
        
    }
    
    func getAllInputValues(key:String, method:HTTPMethod, completion:@escaping (_ status:Int, _ values:[Int]?, _ msg:String?)->())  {
        
        var theValues = [Int]()
        
        getAllInputsURL = URL(string:"https://us01.proxy.teleduino.org/api/1.0/328.php?k=\(key)&r=getAllInputs")
        
        Alamofire.request(getAllInputsURL, method: method, parameters: [:], encoding: JSONEncoding.default, headers: [:])
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let data):
                    //print("Success \(data)")
                    // print(data)
                    let json = JSON(data)
                    for (_ ,subJson):(String, JSON) in json {
                        //    print(subJson)
                        for values in subJson["values"].arrayValue {
                          //  print(values)
                            theValues.append(values.int!)
                        }
                    }
                    completion(200, theValues, "OK")
                case .failure(let err):
                    print("Error: \(err)")
                    completion(500, nil, "Failed")
                    
                }
            })
        
    }
    
    // Defining which pins are for output and which for input
    func definingPinModes(pin: [Int], mode: Int) {
        
        
        for i in pin {
            
            definePinModeURL = URL(string: "https://us01.proxy.teleduino.org/api/1.0/328.php?k=\(key!)&r=definePinMode&pin=\(i)&mode=\(mode)")
            
            Alamofire.request(definePinModeURL, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: [:])
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(_):
                        print("Success pin definition")
                        
                    case .failure(let err):
                        // SwiftSpinner.show(duration: 2.0, title: "Connection Error")
                        print("Error initialization: \(err)")

                       // self.alertMessage(title: "Connection Error", message: "Failed to initialize app")

                        return
                    }
            }
        }
        
    }
    
    func initializeAppView() {
        
        //print(currentReachabilityStatus)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        key = appDelegate.key
        
        
        button1.alpha = 0; button2.alpha = 0; button3.alpha = 0; button4.alpha = 0
        button4.isEnabled = false; button3.isEnabled = false; button2.isEnabled = false; button1.isEnabled = false
        button1.backgroundColor = UIColor.red
        button2.backgroundColor = UIColor.red
        button3.backgroundColor = UIColor.red
        button4.backgroundColor = UIColor.red
        button1.layer.cornerRadius = self.button1.frame.width/2
        button2.layer.cornerRadius = self.button1.frame.width/2
        button3.layer.cornerRadius = self.button1.frame.width/2
        button4.layer.cornerRadius = self.button1.frame.width/2
        
        // Show buttons in animation
        UIView.animate(withDuration: 2.0) {
            
            self.button1.alpha = 1; self.button2.alpha = 1; self.button3.alpha = 1; self.button4.alpha = 1
        }
        
        definingPinModes(pin: [7,6,5,4], mode: 1)
        
    }
    
    func changeButtonColors(values: [Int]) {
        
        if values[4] == 0 {
            self.button1.backgroundColor = UIColor.red
        } else {
            self.button1.backgroundColor = UIColor.green
        }
        if values[5] == 0 {
            self.button2.backgroundColor = UIColor.red
        } else {
            self.button2.backgroundColor = UIColor.green
        }
        if values[6] == 0 {
            self.button3.backgroundColor = UIColor.red
        } else {
            self.button3.backgroundColor = UIColor.green
        }
        if values[7] == 0 {
            self.button4.backgroundColor = UIColor.red
        } else {
            self.button4.backgroundColor = UIColor.green
        }
        self.button4.isEnabled = true; self.button3.isEnabled = true; self.button2.isEnabled = true; self.button1.isEnabled = true
    }
    
    //Alert error messages
    func alertMessage(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        
        self.activityIndicator.stopAnimating()
        
        if presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }else {
            self.dismiss(animated: false, completion: {
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    

    
}

// Checking reachability status using SCNetworkReachabilityFlags
extension NSObject:Utilities {
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }

}

