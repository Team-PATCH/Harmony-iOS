//
//  FileManager+Extensions.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//

import Foundation


extension FileManager {
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
