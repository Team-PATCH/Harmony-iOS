//
//  OnboardingViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/31/24.
//

import Foundation
import Combine
import Alamofire

// MARK: - ViewModel

final class OnboardingViewModel: ObservableObject {
    private let apiService: OnboardingService
    
    @Published var groupName = "" {
        didSet { logStateChange("groupName", oldValue, groupName) }
    }
    @Published var alias = "" {
        didSet { logStateChange("alias", oldValue, alias) }
    }
    @Published var userName: String = "" {
        didSet { logStateChange("userName", oldValue, userName) }
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
    @Published var currentGroup: Group? {
        didSet { logStateChange("currentGroup", oldValue, currentGroup) }
    }
    @Published var currentUserGroup: UserGroup? {
        didSet { logStateChange("currentUserGroup", oldValue, currentUserGroup) }
    }
    
    init(apiService: OnboardingService = OnboardingService()) {
        self.apiService = apiService
        print("OnboardingViewModel initialized")
    }
    
    private func logStateChange<T>(_ propertyName: String, _ oldValue: T, _ newValue: T) {
        print("[\(propertyName)] 변경: \(oldValue) -> \(newValue)")
    }
    
    func createGroup() {
        guard !groupName.isEmpty, !alias.isEmpty else {
            errorMessage = "그룹 이름과 별칭을 입력해주세요."
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
                let (group, inviteUrl, vipInviteUrl) = try await apiService.createGroup(name: groupName, alias: alias, userId: userId, deviceToken: deviceToken)
                
                
                DispatchQueue.main.async {
                    self.currentGroup = group
                    self.isLoading = false
                    print("Group created successfully - groupId: \(group.groupId), inviteUrl: \(inviteUrl), vipInviteUrl: \(vipInviteUrl)")
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
        guard !inviteCode.isEmpty, !alias.isEmpty else {
            errorMessage = "초대 코드와 별칭을 입력해주세요."
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
                let group = try await apiService.joinGroup(userId: userId, inviteCode: inviteCode, deviceToken: deviceToken, alias: alias)
                
                DispatchQueue.main.async {
                    self.currentGroup = group
                    self.isLoading = false
                    print("Successfully joined group - groupId: \(group.groupId)")
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
        guard let groupId = currentGroup?.groupId else {
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
                let userGroup = try await apiService.updateOnboardingInfo(groupId: groupId, userId: userId, alias: alias, deviceToken: deviceToken)
                
                DispatchQueue.main.async {
                    self.currentUserGroup = userGroup
                    self.isLoading = false
                    print("Onboarding info updated successfully - userId: \(userGroup.userId), groupId: \(userGroup.groupId)")
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
}
