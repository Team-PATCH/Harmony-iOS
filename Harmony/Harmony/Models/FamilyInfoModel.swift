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
    let permissionId: String
    var alias: String?
}
