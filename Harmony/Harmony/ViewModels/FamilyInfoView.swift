//
//  FamilyInfoView.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/31/24.
//

import SwiftUI

struct FamilyInfoView: View {
    @StateObject var viewModel: FamilyInfoViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ProfileBox(viewModel: viewModel)
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        .background(Color.gray1)
                    
                    FamilyMembersSection(viewModel: viewModel)
                }
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("가족정보")
                        .font(.pretendardBold(size: 20))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

struct ProfileBox: View {
    @ObservedObject var viewModel: FamilyInfoViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Text(viewModel.currentUser.nick)
                .font(.pretendardSemiBold(size: 24))
            Button("프로필 수정") {
                viewModel.isEditingProfile = true
            }
            .font(.pretendardSemiBold(size: 18))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.mainGreen)
            .foregroundColor(.wh)
            .cornerRadius(999)
        }
        .padding()
        .background(Color.wh)
        .cornerRadius(10)
        .sheet(isPresented: $viewModel.isEditingProfile) {
            ProfileEditView(viewModel: viewModel)
        }
    }
}

struct FamilyMembersSection: View {
    @ObservedObject var viewModel: FamilyInfoViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("우리가족")
                Text("\(viewModel.familyMembers.count)")
                    .foregroundStyle(Color.mainGreen)
            }
            .font(.pretendardMedium(size: 22))
            .padding(.top)
            .padding(.horizontal)
            
            ForEach(viewModel.familyMembers) { member in
                MemberBox(member: member, viewModel: viewModel)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.inviteFamily()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("   가족 초대하기")
                }
            }
            .font(.pretendardSemiBold(size: 24))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.mainGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
        .background(Color.wh)
    }
}

struct MemberBox: View {
    let member: FamilyMember
    @ObservedObject var viewModel: FamilyInfoViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(member.user.nick)
                    .font(.pretendardSemiBold(size: 20))
            }
            Spacer()
            viewModel.getPermissionIcon(for: member)
            Text(viewModel.getPermissionName(for: member))
                .font(.pretendardSemiBold(size: 15))
        }
        .padding()
        .background(Color.gray1)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}



#Preview("Family Info View") {
    FamilyInfoView(viewModel: FamilyInfoViewModel.previewModel())
}
