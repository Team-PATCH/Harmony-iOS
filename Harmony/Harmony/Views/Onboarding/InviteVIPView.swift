//
//  InviteVIPView.swift
//  Harmony
//
//  Created by 한수빈 on 7/25/24.
//

import SwiftUI

struct InviteVIPView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var path: [String]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("윤여정 할머니를")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("초대해주세요.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text("할머니를 초대해야\n하모니를 시작할 수 있어요.")
                    .font(.system(size: 18, weight: .medium))
                    .lineSpacing(4)
                    .foregroundColor(.gray5)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                Button {
                    viewModel.createGroup()
                } label:
                {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .padding()
                        Text("초대 링크 공유")
                    }
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(.wh)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.trailing, 30)
                    .background(Color.mainGreen)
                    .cornerRadius(10)
                }
                
                Spacer()
                
            }
            .padding()
            .background(Color.wh)
        }
    }
}

//#Preview{
//    InviteVIPView(path: .constant([]))
//    
//}
