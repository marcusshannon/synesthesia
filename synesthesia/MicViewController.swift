//
//  MicViewController.swift
//  synesthesia
//
//  Created by Marcus Shannon on 2/6/17.
//  Copyright © 2017 Marcus Shannon. All rights reserved.
//

import UIKit
import SwiftyHue
import AudioKit
import Alamofire
import SwiftyJSON

class MicViewController: UIViewController, BridgeFinderDelegate, BridgeAuthenticatorDelegate {
    
    var mic: AKMicrophone!
    var tracker: AKAmplitudeTracker!
    var silence: AKBooster!
    
    var lights: [(name: String, index: String)]?
    var selectedLight = 1

    var light: Int?
    var bridge: HueBridge?
    let bridgeFinder = BridgeFinder()
    var alert: UIAlertController?
    var bridgeConfig: (ip: String, user: String)?

    @IBOutlet weak var micSwitch: UISwitch!
    
    @IBAction func micSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            AudioKit.output = silence
            AudioKit.start()
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateLights), userInfo: nil, repeats: true)
        } else {
            AudioKit.stop()
        }
    }
    
    func updateLights() {
        let bri = min(Int(tracker.amplitude * 255 * (self.sensitivity.value + 1)), 254)
        
        let parameters: Parameters = [
            "bri": bri,
            "transitiontime": 1
        ]
        
        Alamofire.request("http://\(bridgeConfig!.ip)/api/\(bridgeConfig!.user)/lights/\(self.selectedLight)/state", method: .put, parameters: parameters, encoding: JSONEncoding(options: []))
            .response { res in
        }
    }
    
    
    
    @IBOutlet weak var sensitivity: UISlider!
    
    @IBOutlet weak var maximum: UISlider!
    
    @IBOutlet weak var minimum: UISlider!

    
    @IBAction func sensitivityChanged(_ sender: UISlider) {
        
    }
    
    @IBAction func maximumChanged(_ sender: UISlider) {
        sender.value = max(sender.value, 0.2)
        minimum.value = min(sender.value - 0.2, minimum.value)
    }
    
    @IBAction func minimumChanged(_ sender: UISlider) {
        sender.value = min(sender.value, 0.8)
        maximum.value = max(sender.value + 0.2, maximum.value)
    }
    

    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFinishAuthentication username: String) {
        UserDefaults.standard.set(username, forKey: "user")
        UserDefaults.standard.set(bridge!.ip, forKey: "ip")
        bridgeConfig = (bridge!.ip, username)
        alert!.dismiss(animated: true)
        self.micSwitch.isEnabled = true
    }
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFailWithError error: NSError) {
        self.alert?.title = "Error"
        self.alert?.message = "Error"
        exit(1)
    }
    
    func bridgeAuthenticatorRequiresLinkButtonPress(_ authenticator: BridgeAuthenticator, secondsLeft: TimeInterval) {
        
    }
    
    func bridgeAuthenticatorDidTimeout(_ authenticator: BridgeAuthenticator) {
        self.authorizeBridge()
    }
    
    
    func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
        if bridges.isEmpty {
            self.alert!.title = "Could not find bridge"
            self.alert!.message = ""
        }
        self.bridge = bridges[0]
        let prefs = UserDefaults.standard
        if let user = prefs.string(forKey: "user") {
            Alamofire.request("http://\(bridge!.ip)/api/\(user)/lights").validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json[0]["error"].string != nil {
                        self.authorizeBridge()
                    } else {
                        self.lights = []
                        for (key,subJson):(String, JSON) in json {
                            self.lights!.append((name: subJson["name"].string!, index: key))
                        }
                        UserDefaults.standard.set(self.bridge!.ip, forKey: "ip")
                        self.bridgeConfig = (self.bridge!.ip, user)
                        self.micSwitch.isEnabled = true
                    }
                case .failure:
                    self.authorizeBridge()
                }
            }
        }
        else {
            self.authorizeBridge()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKAmplitudeTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    func lookForBridge() {
        self.alert = UIAlertController(title: "Looking for bridge", message: "", preferredStyle: .alert)
        self.present(self.alert!, animated: true)
        self.bridgeFinder.delegate = self
        self.bridgeFinder.start()
    }
    
    func authorizeBridge() {
        let bridgeAuthenticator = BridgeAuthenticator(bridge: self.bridge!, uniqueIdentifier: "swiftyhue#\(UIDevice.current.name)")
        bridgeAuthenticator.delegate = self
        bridgeAuthenticator.start()
        self.alert?.title = "Link bridge"
        self.alert?.message = "Press button on bridge"
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Get prefs
        let prefs = UserDefaults.standard
        if let user = prefs.string(forKey: "user"), let ip = prefs.string(forKey: "ip") {
            //Send request to bridge
            Alamofire.request("http://\(ip)/api/\(user)/lights").validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //Check if user is authorized
                    if json[0]["error"].string != nil {
                        self.lookForBridge()
                    }
                    else {
                        self.lights = []
                        for (key,subJson):(String, JSON) in json {
                            self.lights!.append((name: subJson["name"].string!, index: key))
                        }
                        self.bridgeConfig = (ip, user)
                        self.micSwitch.isEnabled = true
                    }
                case .failure:
                    self.lookForBridge()
                }
            }
        }
        else {
            self.lookForBridge()
        }
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        print("switching")
     }
    
    
}
