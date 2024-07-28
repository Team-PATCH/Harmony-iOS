//
//  Bundle+Extensions.swift
//  Harmony
//
//  Created by 한수빈 on 7/28/24.
//

import Foundation

extension Bundle {
    var nativeAppKey: String? {
        return infoDictionary?["NATIVE_APP_KEY"] as? String
    }
}
