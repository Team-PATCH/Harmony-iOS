//
//  SettingsView.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/31/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            Section(header: Text("권한 및 정보")){
                NavigationLink("알림 설정", destination: Text("알림 설정"))
                NavigationLink("개인정보처리방침", destination: Text("개인정보처리방침"))
                NavigationLink("이용 약관", destination: Text("이용 약관"))
            }
            .font(.pretendardBold(size: 18))
            
            Section(header: Text("계정 관리")) {
                Button("로그아웃") {
                    // 로그아웃 로직
                }
                .foregroundColor(.red)
                NavigationLink("가족 탈퇴", destination: Text("가족 탈퇴"))
                NavigationLink("회원 탈퇴", destination: Text("회원 탈퇴"))
            }
            .font(.pretendardBold(size: 18))
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("설정", displayMode: .inline)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(.black)
            }
        }
    }
}


#Preview("Settings View") {
    NavigationView {
        SettingsView()
    }
}
