//
//  OnboardingViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/31/24.
//

import Combine
import Alamofire
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    private let apiService: OnboardingService
    
    @Published var groupId: Int? {
        didSet { logStateChange("groupId", oldValue, groupId) }
    }
    
    @Published var groupName: String? {
        didSet { logStateChange("groupName", oldValue, groupName) }
    }
    
    @Published var vipAlias = "선택해주세요" {
        didSet { logStateChange("vipCategory", oldValue, vipAlias) }
    }
    @Published var vipName = "" {
        didSet { logStateChange("vipName", oldValue, vipName) }
    }
    @Published var alias = "" {
        didSet { logStateChange("alias", oldValue, alias) }
    }
    @Published var userName: String = "" {
        didSet { logStateChange("userName", oldValue, userName) }
    }
    @Published var profile: String = "" {
        didSet { logStateChange("profile", oldValue, profile) }
    }
    @Published var inviteCode = "" {
        didSet { logStateChange("inviteCode", oldValue, inviteCode) }
    }
    @Published var isLoading = false {
        didSet { logStateChange("isLoading", oldValue, isLoading) }
    }
    @Published var errorMessage: String? {
        didSet { logStateChange("errorMessage", oldValue, errorMessage) }
    }
    @Published var currentGroup: HarmonyGroup? {
        didSet { logStateChange("currentGroup", oldValue, currentGroup) }
    }
    @Published var currentUserGroup: UserGroup? {
        didSet { logStateChange("currentUserGroup", oldValue, currentUserGroup) }
    }
    
    @Published var navigationPath: NavigationPath = NavigationPath() {
        didSet { logStateChange("navigationPath", oldValue, navigationPath)}
    }
    
    @Published var isOnboardingEnd: Bool {
        didSet { logStateChange("isOnboardingEnd", oldValue, isOnboardingEnd) }
    }
    
    @Published var permission = "" {
        didSet { logStateChange("permission", oldValue, permission) }
    }
    
    init(apiService: OnboardingService = OnboardingService()) {
        self.apiService = apiService
        self.isOnboardingEnd = UserDefaults.standard.bool(forKey: "isOnboardingEnd")
        print("OnboardingViewModel initialized")
    }
    
    private func logStateChange<T>(_ propertyName: String, _ oldValue: T, _ newValue: T) {
        print("[\(propertyName)] 변경: \(oldValue) -> \(newValue)")
    }
    
    func createGroup() {
        guard !vipName.isEmpty && !vipAlias.isEmpty else {
            errorMessage = "그룹 이름을 입력해주세요."
            print("Error: \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        print("Creating group with - userId: \(userId), deviceToken: \(deviceToken)")
        
        Task {
            do {
                let (groupId, groupName, inviteUrl, vipInviteUrl) = try await apiService.createGroup(name: "\(vipAlias) \(vipName)", userId: userId, deviceToken: deviceToken)
                
                DispatchQueue.main.async {
                    self.groupId = groupId
                    self.groupName = groupName
                    self.inviteCode = vipInviteUrl
                    // TODO: - member invitecode도 처리해줘야함
                    self.isLoading = false
                    self.navigateTo(.inviteVIP)
                    print("Group created successfully - groupId: \(self.groupId), groupName: \(self.groupName), vipInviteUrl: \(self.inviteCode)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "그룹 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error creating group: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func joinGroup() {
        guard !inviteCode.isEmpty else {
            errorMessage = "초대 코드를 입력해주세요."
            print("Error: \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        print("Joining group with - userId: \(userId), deviceToken: \(deviceToken), inviteCode: \(inviteCode)")
        
        Task {
            do {
                let groupRes = try await apiService.joinGroup(userId: userId, inviteCode: inviteCode, deviceToken: deviceToken)
                
                DispatchQueue.main.async {
                    self.currentGroup = groupRes.group
                    self.groupId = groupRes.group.groupId
                    self.groupName = groupRes.group.name
                    self.vipName = groupRes.group.name.components(separatedBy: " ")[1]
                    self.vipAlias = groupRes.group.name.components(separatedBy: " ")[0]
                    self.isLoading = false
                    self.navigateTo(.enterGroup)
                    self.permission = groupRes.permission
                    print("Successfully joined group - groupId: \(groupRes.group.groupId)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "그룹 참여 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error joining group: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateOnboardingInfo() {
        guard let groupId = self.groupId else {
            errorMessage = "현재 그룹 정보가 없습니다."
            print("Error: \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        print("Updating onboarding info - userId: \(userId), groupId: \(groupId), alias: \(alias)")
        
        Task {
            do {
                let response = try await apiService.updateOnboardingInfo(groupId: groupId, userId: userId, alias: self.alias, userName: self.userName, profile: self.profile, deviceToken: deviceToken)
                
                DispatchQueue.main.async {
                    self.currentUserGroup = response.userGroup
                    self.isLoading = false
                    print("Onboarding info updated successfully - userId: \(response.userGroup.userId), groupId: \(response.userGroup.groupId)")
                    UserDefaults.standard.setValue(true, forKey: "isOnboardingEnd")
                    self.isOnboardingEnd = true
                    self.navigateToRoot()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "온보딩 정보 업데이트 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error updating onboarding info: \(error.localizedDescription)")
                }
            }
        }
    }
    func navigateTo(_ destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}


@frozen enum NavigationDestination: Hashable {
    case createGroup
    case inputVIPInfo
    case inputUserInfo
    case inviteVIP
    case registerProfile
    case joinGroup
    case enterGroup
    // 필요한 만큼 케이스 추가
}
