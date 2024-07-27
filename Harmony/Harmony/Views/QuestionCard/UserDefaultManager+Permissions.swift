//
//  UserDefaultManager+Permissions.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/26/24.
//

import Foundation

extension UserDefaultsManager {
    func isVIP() -> Bool {
        return getPermissionId() == "v"
    }

    func isMember() -> Bool {
        return getPermissionId() == "m"
    }

    func isAdmin() -> Bool {
        return getPermissionId() == "a"
    }

}
