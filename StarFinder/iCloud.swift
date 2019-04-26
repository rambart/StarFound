//
//  iCloud.swift
//  StarFound
//
//  Created by Tom on 4/23/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


func createPC(from string: String, portrait: UIImage? = nil) {
    
    guard let path = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
    }
    
    let saveFileURL = path.appendingPathComponent("/backup.char")
    
    do {
        try (string as String).write(to: saveFileURL, atomically: true, encoding: .utf8)
    } catch {
        print("could not save")
    }
    
    importPC(from: saveFileURL, portrait: portrait )
    
    
    do {
        try FileManager.default.removeItem(at: saveFileURL)
    } catch {
        print("could not delete")
    }
}
