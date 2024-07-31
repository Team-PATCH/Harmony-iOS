//
//  UserInfoEntryView.swift
//  Harmony
//
//  Created by 한수빈 on 7/24/24.
//

import SwiftUI

struct UserInfoEntryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var path: [String]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("할머니와")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("어떤 관계인가요?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text("할머니에게 보여질\n닉네임을 입력해 주세요.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("관계")
                        .padding(.leading,10)
                        .font(.pretendardMedium(size: 18))
                    CustomTextFieldView(placeholder: "예) 손녀", value: Binding(
                        get: { self.viewModel.alias },
                        set: { self.viewModel.alias = $0 }
                    ))
                    Text("이름")
                        .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 0))
                        .font(.pretendardMedium(size: 18))
                    CustomTextFieldView(placeholder: "이름을 입력해주세요.", value: Binding(
                        get: { self.viewModel.userName },
                        set: { self.viewModel.userName = $0 }
                    ))
                }
                .padding(.top, 20)
                
                Spacer()
                
                NavigationLink(destination: ProfileRegisterView(viewModel: viewModel, path: $path)) {
                    Text("다음")
                        .font(.pretendardSemiBold(size: 24))
                        .foregroundColor(.wh)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!viewModel.alias.isEmpty && !viewModel.userName.isEmpty ? Color.mainGreen : Color.gray3)
                        .cornerRadius(10)
                }
                .disabled(viewModel.alias.isEmpty || viewModel.userName.isEmpty)
            }
            .padding()
            .background(Color.wh)
        }
    }
}
