//
//  FamilyInfoModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/31/24.
//

import Foundation

struct User: Identifiable {
    let id: String
    var nick: String
    var profile: String?
}

struct FamilyMember: Identifiable {
    let id: String
    var user: User
    let permissionId: UserRole
    var alias: String?
    var groupId: Int
    var deviceToken: String?
}

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
