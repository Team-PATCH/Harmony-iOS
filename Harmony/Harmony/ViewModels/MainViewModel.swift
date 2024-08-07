//
//  MainViewModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 8/6/24.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var currentUser: FamilyMember?
    @Published var familyMembers: [FamilyMember] = []
    
    let memoryCardViewModel = MemoryCardViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // 필요한 경우 MemoryCardViewModel과의 바인딩을 여기에 추가할 수 있습니다.
    }
    
    func loadCurrentUser(role: UserRole) {
        // 실제 API 호출 로직으로 대체해야 합니다.
        let dummyUser = User(id: "user1", nick: "John Doe")
        currentUser = FamilyMember(id: "member1", user: dummyUser, permissionId: role, groupId: 1)
    }
    
    func loadFamilyMembers() {
        // 실제 API 호출 로직으로 대체해야 합니다.
        let dummyVIP = User(id: "user2", nick: "Jane Doe")
        let vipMember = FamilyMember(id: "member2", user: dummyVIP, permissionId: .vip, groupId: 1)
        familyMembers = [vipMember]
    }
    
    // MARK: - Preview Helpers
    static func mockMember() -> MainViewModel {
        let viewModel = MainViewModel()
        viewModel.currentUser = FamilyMember(id: "member1", user: User(id: "user1", nick: "멤버"), permissionId: .member, groupId: 1)
        return viewModel
    }
    
    static func mockVIP() -> MainViewModel {
        let viewModel = MainViewModel()
        viewModel.currentUser = FamilyMember(id: "vip1", user: User(id: "user2", nick: "VIP"), permissionId: .vip, groupId: 1)
        return viewModel
    }
}
