//
//  FirstViewController.swift
//  Show Cues Swift
//
//  Created by Carl Andrews on 9/22/19.
//  Copyright © 2019 Carl R Andrews, Inc. All rights reserved.
//

import UIKit
import MediaPlayer
import MediaToolbox

extension UIView {
    func fadeTo(_ alpha: CGFloat, duration: TimeInterval = 0.3) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration) {
                self.alpha = alpha
            }
        }
    }
    
    func fadeIn(_ duration: TimeInterval = 0.3) {
        fadeTo(1.0, duration: duration)
    }
    
    func fadeOut(_ duration: TimeInterval = 0.3) {
        fadeTo(0.0, duration: duration)
    }
}

class FirstViewController: UIViewController {
    
    @IBOutlet var fadeCurtain: UIImageView!
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        UITabBar.appearance().barTintColor = UIColor.black

        //keep tab bar visible while scrolling tableview
        UITabBar.appearance().isTranslucent = false
        
        let songsSelected = false
        defaults.set(songsSelected, forKey: "songsSelected")
        
        fadeCurtain.alpha = 1
        fadeCurtain.fadeOut(2.5) // uses custom duration
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        label.alpha = 0
        label.fadeIn(3.5)
        label.text = "App Version: \(appVersion)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}

