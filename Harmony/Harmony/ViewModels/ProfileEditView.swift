//
//  ProfileEditView.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/31/24.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: FamilyInfoViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .overlay( //실제 사진을 추가할 수 있는 로직 작성
                        Image(systemName: "camera")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding(5),
                        alignment: .bottomTrailing
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("관계")
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.bl)
                    TextField("예) 손녀", text: $viewModel.newNick)
                        .font(.pretendardBold(size: 20))
                        .padding()
                        .background(Color.gray1)
                        .cornerRadius(10)
                    
                    Text("이름")
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.bl)
                        .padding(.top, 10)
                    TextField("이름을 입력해 주세요", text: $viewModel.newAlias)
                        .font(.pretendardBold(size: 20))
                        .padding()
                        .background(Color.gray1)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                
                Spacer()
                
                Button("수정하기") {
                    viewModel.updateProfile()
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.pretendardSemiBold(size: 24))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.mainGreen)
                .foregroundColor(.wh)
                .cornerRadius(10)
                .padding(.bottom)
            }
            .padding()
            .navigationBarTitle("프로필 수정", displayMode: .inline)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
            })
            .background(Color.wh)
        }
    }
}

#Preview("Profile Edit View") {
    ProfileEditView(viewModel: FamilyInfoViewModel.previewModel())
}
