//
//  FamilyInfoViewModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/31/24.
//

import Foundation
import SwiftUI

class FamilyInfoViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var familyMembers: [FamilyMember] = []
    @Published var isEditingProfile: Bool = false
    @Published var newNick: String = ""
    @Published var newAlias: String = ""
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    init() {
        let userData = userDefaultsManager.getUserData()
        self.currentUser = User(id: userData?.userId ?? "",
                                nick: userData?.nick ?? "",
                                profile: nil)  // Assuming profile is not stored in UserDefaults
        self.newNick = currentUser.nick
        self.newAlias = userData?.alias ?? ""
        fetchFamilyMembers()
    }
    
    func fetchFamilyMembers() {
        // 가족구성원 불러오는 로직
        familyMembers = [
            FamilyMember(id: currentUser.id, user: currentUser, permissionId: userDefaultsManager.getPermissionId() ?? "", alias: userDefaultsManager.getAlias()),
            FamilyMember(id: "user2", user: User(id: "user2", nick: "손녀 이지은"), permissionId: "m", alias: "손녀"),
            FamilyMember(id: "user3", user: User(id: "user3", nick: "손자 박준호"), permissionId: "a", alias: "손자")
        ]
    }
    
    func updateProfile() {
        if var userData = userDefaultsManager.getUserData() {
            userData.nick = newNick
            userData.alias = newAlias
            userDefaultsManager.saveUserData(userData)
            
            // 사용자 닉네임 업데이트
            currentUser.nick = newNick
            
            // 가족구성원 닉네임 업데이트
            if let index = familyMembers.firstIndex(where: { $0.id == currentUser.id }) {
                familyMembers[index].user.nick = newNick
                familyMembers[index].alias = newAlias
            }
        }
        isEditingProfile = false
    }
    
    func inviteFamily() {
        // 가족초대 로직
        print("가족을 초대하는 중입니다...")
    }
    
    func isVIP() -> Bool {
        return userDefaultsManager.isVIP()
    }
    
    func isMember() -> Bool {
        return userDefaultsManager.isMember()
    }
    
    func isAdmin() -> Bool {
        return userDefaultsManager.isAdmin()
    }
    
    func getPermissionName(for member: FamilyMember) -> String {
        switch member.permissionId {
        case "v":
            return "VIP"
        case "a":
            return "관리자"
        case "m":
            return "멤버"
        default:
            return "알 수 없음"
        }
    }
    
    func getPermissionIcon(for member: FamilyMember) -> some View {
        switch member.permissionId {
        case "v":
            return AnyView(Image(systemName: "crown.fill").foregroundColor(.yellow))
        case "a":
            return AnyView(Image(systemName: "star.fill").foregroundColor(.yellow))
        case "m":
            return AnyView(EmptyView())  // 일반 멤버는 아이콘이 없습니다
        default:
            return AnyView(EmptyView())
        }
    }
}

// MARK: - Preview Helper

extension FamilyInfoViewModel {
    static func previewModel() -> FamilyInfoViewModel {
        let model = FamilyInfoViewModel()
        model.currentUser = User(id: "user1", nick: "할머니 김영희")
        model.familyMembers = [
            FamilyMember(id: "user1", user: model.currentUser, permissionId: "v", alias: "할머니"),
            FamilyMember(id: "user2", user: User(id: "user2", nick: "손녀 이지은"), permissionId: "m", alias: "손녀"),
            FamilyMember(id: "user3", user: User(id: "user3", nick: "손자 박준호"), permissionId: "a", alias: "손자")
        ]
        return model
    }
}
