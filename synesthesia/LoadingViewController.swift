//
//  LoadingViewController.swift
//  synesthesia
//
//  Created by Marcus Shannon on 2/4/17.
//  Copyright © 2017 Marcus Shannon. All rights reserved.
//

import UIKit
import SwiftyHue
import Alamofire
import SwiftyJSON

class LoadingViewController: UIViewController, BridgeFinderDelegate {
    
    let bridgeFinder = BridgeFinder()
    
    func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
        if (authBridge(bridges: bridges)) {
            return
        }
        self.performSegue(withIdentifier: "foundBridges", sender: bridges)
    }
    
    func authBridge(bridges: [HueBridge]) -> Bool {
        let prefs = UserDefaults.standard
        let bridgeId = prefs.string(forKey: "bridgeId")
        let user = prefs.string(forKey: "user")
        if (bridgeId != nil && user != nil) {
            for bridge in bridges {
                if (bridge.serialNumber == bridgeId) {
                    let bridgeAccessConfig = BridgeAccessConfig(bridgeId: bridgeId!, ipAddress: bridge.ip, username: user!)
                    self.performSegue(withIdentifier: "foundBridge", sender: bridgeAccessConfig)
                    return true
                }
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs = UserDefaults.standard
        if let bridgeId = prefs.string(forKey: "bridgeId"), let user = prefs.string(forKey: "user"), let ip = prefs.string(forKey: "ip") {
            Alamofire.request("http://\(ip)/api/\(user)")
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if json[0]["error"].string != nil {
                            self.bridgeFinder.delegate = self;
                            self.bridgeFinder.start()
                        } else {
                            let bridgeAccessConfig = BridgeAccessConfig(bridgeId: bridgeId, ipAddress: ip, username: user)
                            self.performSegue(withIdentifier: "foundBridge", sender: bridgeAccessConfig)
                        }
                    case .failure:
                        self.bridgeFinder.delegate = self
                        self.bridgeFinder.start()
                    }
            }
        }
        else {
            self.bridgeFinder.delegate = self
            self.bridgeFinder.start()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? BridgeSelectionTableViewController {
            dest.bridges = sender as? [HueBridge]
        }
    }
}
