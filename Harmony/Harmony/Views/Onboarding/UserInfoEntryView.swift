//
//  UserInfoEntryView.swift
//  Harmony
//
//  Created by 한수빈 on 7/24/24.
//

import SwiftUI

struct UserInfoEntryView: View {
    @Binding var path: [String]
    @State private var relationship: String = ""
    @State private var name: String = ""
    
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
                    CustomTextFieldView(placeholder: "예) 손녀", value: $relationship)
                    Text("이름")
                        .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 0))
                        .font(.pretendardMedium(size: 18))
                    CustomTextFieldView(placeholder: "이름을 입력해주세요.", value: $name)
                    
                }
                .padding(.top, 20)
                
                Spacer()
                
                NavigationLink(destination: UserInfoEntryView(path: $path)) {
                    Text("다음")
                        .font(.pretendardSemiBold(size: 18))
                        .foregroundColor(.wh)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!relationship.isEmpty && !name.isEmpty ? Color.mainGreen : Color.gray3)
                        .cornerRadius(10)
                }
                .disabled(relationship.isEmpty || name.isEmpty)
            }
            .padding()
            .background(Color.wh)
        }
    }
}

#Preview{
    UserInfoEntryView(path: .constant([]))
    
}
