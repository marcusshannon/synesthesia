//
//  LoadingViewController.swift
//  synesthesia
//
//  Created by Marcus Shannon on 2/4/17.
//  Copyright © 2017 Marcus Shannon. All rights reserved.
//

import UIKit
import SwiftyHue

class LoadingViewController: UIViewController, BridgeFinderDelegate {

    func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
        print(bridges)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bridgeFinder = BridgeFinder()
        bridgeFinder.delegate = self;
        bridgeFinder.start()
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
