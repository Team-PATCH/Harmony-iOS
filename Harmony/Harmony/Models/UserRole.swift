//
//  UserRole.swift
//  Harmony
//
//  Created by Ji Hye PARK on 8/6/24.
//

import Foundation

enum UserRole: String {
    case member = "M"
    case vip = "V"
    
    var name: String {
        switch self {
        case .member:
            return "Member"
        case .vip:
            return "VIP"
        }
    }
}
