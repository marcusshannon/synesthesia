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

class MicViewController: UIViewController {

    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    @IBOutlet var audioInputPlot: EZAudioPlot!



    var bridgeAccessConfig: BridgeAccessConfig?
    
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        
        let bri = Int(tracker.amplitude * 1000) % 255
        print(bri)
        
        let parameters: Parameters = [
            "bri": bri,
            "transitiontime": 0
        ]
        
        Alamofire.request("http://\(bridgeAccessConfig!.ipAddress)/api/\(bridgeAccessConfig!.username)/lights/1/state", method: .put, parameters: parameters, encoding: JSONEncoding(options: []))
            .response { res in
        }

        
        
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
