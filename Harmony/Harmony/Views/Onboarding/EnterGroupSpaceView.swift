//
//  EnterGroupSpaceView.swift
//  Harmony
//
//  Created by 한수빈 on 8/6/24.
//

import SwiftUI

struct EnterGroupSpaceView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.groupName ?? "당신을")")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("을 위한 가족공간이에요.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.gray2)
                            .frame(width: 200, height: 200)
                        
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray4)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                VStack(spacing: 0) {
                    // 말풍선 내용
                    VStack(alignment: .center, spacing: 10) {
                        
                        
                        Text("가족과 함께 소중한 추억을 기록해볼까요?")
                            .font(.pretendardMedium(size: 18))
                            .lineSpacing(4)
                            .foregroundColor(.gray5)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                    .background(Color.wh)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray3, lineWidth: 2)
                    )
                    //                .shadow(color: .gray2, radius: 5, x: 0, y: 2)
                    
                    // 말풍선 꼬리
                    Triangle()
                        .fill(Color.wh)
                        .frame(width: 20, height: 10)
                        .offset(y: -1)
                        .overlay(
                            Triangle()
                                .stroke(Color.gray3, lineWidth: 2)
                        )
                }
                
                Button {
                    if user
                    viewModel.navigateTo(.inputUserInfo)
                } label: {
                    
                    Text("가족 공간 입장하기")
                        .font(.pretendardSemiBold(size: 24))
                        .foregroundColor(.wh)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.wh)
            
        }
}

//    }

//#Preview {
//    EnterGroupSpaceView(viewModel: OnboardingViewModel(), path: .constant(NavigationPath()))
//}
