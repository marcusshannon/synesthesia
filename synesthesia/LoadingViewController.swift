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
        let prefs = UserDefaults.standard
        if let bridgeId = prefs.string(forKey: "bridgeId"), let user = prefs.string(forKey: "user") {
            for bridge in bridges {
                if (bridge.serialNumber == bridgeId) {
                    Alamofire.request("http://\(bridge.ip)/api/\(user)").validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            if json[0]["error"].string != nil {
                                self.performSegue(withIdentifier: "foundBridges", sender: bridges)
                            } else {
                                UserDefaults.standard.set(bridge.ip, forKey: "ip")
                                let bridgeAccessConfig = BridgeAccessConfig(bridgeId: bridgeId, ipAddress: bridge.ip, username: user)
                                self.performSegue(withIdentifier: "foundBridge", sender: bridgeAccessConfig)
                            }
                        case .failure:
                            self.performSegue(withIdentifier: "foundBridges", sender: bridges)
                        }
                    }
                }
            }
        }
        self.performSegue(withIdentifier: "foundBridges", sender: bridges)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bridgeFinder.delegate = self;
        
        let prefs = UserDefaults.standard
        if let bridgeId = prefs.string(forKey: "bridgeId"), let user = prefs.string(forKey: "user"), let ip = prefs.string(forKey: "ip") {
            Alamofire.request("http://\(ip)/api/\(user)").validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json[0]["error"].string != nil {
                        self.bridgeFinder.start()
                    } else {
                        let bridgeAccessConfig = BridgeAccessConfig(bridgeId: bridgeId, ipAddress: ip, username: user)
                        self.performSegue(withIdentifier: "foundBridge", sender: bridgeAccessConfig)
                    }
                case .failure:
                    self.bridgeFinder.start()
                }
            }
        }
        else {
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
        
        if let dest = segue.destination as? MicViewController {
            dest.bridgeAccessConfig = sender as? BridgeAccessConfig
        }
    }
}
