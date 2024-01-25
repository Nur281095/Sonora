//
//  MediaItemManager.swift
//  Sonora
//
//  Created by Naveed ur Rehman on 25/01/2024.
//  Copyright © 2024 Carl R Andrews, Inc. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaItemManager {
    static let shared = MediaItemManager()

    private let userDefaults = UserDefaults.standard
    private let savedMediaItemCollectionKey = "savedMediaItemCollection"

    // Save MPMediaItemCollection
    func saveMediaItemCollection(_ mediaItemCollection: MPMediaItemCollection) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: mediaItemCollection, requiringSecureCoding: false)
            userDefaults.set(data, forKey: savedMediaItemCollectionKey)
        } catch {
            print("Error archiving MPMediaItemCollection: \(error.localizedDescription)")
        }
    }

    // Retrieve MPMediaItemCollection
    func getMediaItemCollection() -> MPMediaItemCollection? {
        if let data = userDefaults.data(forKey: savedMediaItemCollectionKey) {
            do {
                if let collection = try NSKeyedUnarchiver.unarchivedObject(ofClass: MPMediaItemCollection.self, from: data) {
                    return collection
                }
            } catch {
                print("Error unarchiving MPMediaItemCollection: \(error.localizedDescription)")
            }
        }
        return nil
    }

}
