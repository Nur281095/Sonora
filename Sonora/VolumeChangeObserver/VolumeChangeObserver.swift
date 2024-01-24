//
//  VolumeChangeObserver.swift
//  Sonora
//
//  Created by Naveed ur Rehman on 24/01/2024.
//  Copyright © 2024 Carl R Andrews, Inc. All rights reserved.
//

import AVFoundation
import UIKit

protocol VolumeChangeDelegate: AnyObject {
    func volumeDidChange(newVolume: Float)
}

class VolumeChangeObserver: NSObject {
    weak var delegate: VolumeChangeDelegate?

    private let audioSession = AVAudioSession.sharedInstance()

    override init() {
        super.init()

        // Add an observer for the audio session's output volume key path
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)

        // Activate the audio session
        do {
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }

    deinit {
        // Remove the observer when the VolumeChangeObserver is deinitialized
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }

    // Observer method to detect changes in the output volume
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            if let newVolume = change?[.newKey] as? Float {
                // Notify the delegate about volume change
                delegate?.volumeDidChange(newVolume: newVolume)
            }
        }
    }
}
