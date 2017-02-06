//
//  BridgePushLinkViewController.swift
//  synesthesia
//
//  Created by Marcus Shannon on 2/5/17.
//  Copyright © 2017 Marcus Shannon. All rights reserved.
//

import UIKit
import SwiftyHue

class BridgePushLinkViewController: UIViewController, BridgeAuthenticatorDelegate {
    
    var bridge: HueBridge?
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFinishAuthentication username: String) {
        UserDefaults.standard.set(username, forKey: "user")
        UserDefaults.standard.set(bridge!.serialNumber, forKey: "bridgeId")
        UserDefaults.standard.set(bridge!.ip, forKey: "ip")
        let bridgeAccessConfig = BridgeAccessConfig(bridgeId: bridge!.serialNumber, ipAddress: bridge!.ip, username: username)
        self.performSegue(withIdentifier: "authorizedBridge", sender: bridgeAccessConfig)
    }
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFailWithError error: NSError) {
    
    }
    
    func bridgeAuthenticatorRequiresLinkButtonPress(_ authenticator: BridgeAuthenticator, secondsLeft: TimeInterval) {
    
    }

    func bridgeAuthenticatorDidTimeout(_ authenticator: BridgeAuthenticator) {
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bridgeAuthenticator = BridgeAuthenticator(bridge: bridge!, uniqueIdentifier: "swiftyhue#\(UIDevice.current.name)")
        print("swiftyhue#\(UIDevice.current.name)")
        bridgeAuthenticator.delegate = self
        bridgeAuthenticator.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
