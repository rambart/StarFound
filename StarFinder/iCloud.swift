//
//  iCloud.swift
//  StarFound
//
//  Created by Tom on 4/23/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import CloudKit


func createPC(from string: String) {
    
    guard let path = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
    }
    
    let saveFileURL = path.appendingPathComponent("/jilia.char")
    
    do {
        try (string as String).write(to: saveFileURL, atomically: true, encoding: .utf8)
    } catch {
        print("could not save")
    }
    
    importPC(from: saveFileURL)
    
    
    do {
        try FileManager.default.removeItem(at: saveFileURL)
    } catch {
        print("could not delete")
    }
}
