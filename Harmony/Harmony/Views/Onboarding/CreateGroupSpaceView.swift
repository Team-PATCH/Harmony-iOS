//
//  CreateGroupSpaceView.swift
//  Harmony
//
//  Created by 한수빈 on 7/24/24.
//

import SwiftUI

struct CreateGroupSpaceView: View {
    
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var path: [String]
    
    var body: some View {
        
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 20) {
                
                
                Text("먼저 가족 공간을\n만들어 주세요.")
                    .font(.pretendardBold(size: 28))
                    .foregroundColor(.black)
                
                Text("가족 공간을 만든 사람이\n우리 가족의 매니저가 돼요.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.gray5)
                    .padding(.bottom, 20)
                
                VStack(spacing: 12) {
                    NavigationLink {
                        VIPInfoEntryView(viewModel: viewModel, path: $path)
                    } label: {
                        HStack {
                            Image("create-group-icon")
                                .padding()
                            VStack(alignment: .leading) {
                                Text("아직 가족 공간이 없다면,")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(.gray4)
                                Text("가족 공간 만들기")
                                    .font(.pretendardSemiBold(size: 24))
                                    .foregroundColor(.black)
                                
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray1)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // 가족 공간 입장하기 액션
                    }) {
                        HStack {
                            Image("invite-icon")
                                .padding()
                            VStack(alignment: .leading) {
                                Text("이미 가족 공간이 있다면,")
                                    .font(.pretendardMedium(size: 18))
                                    .foregroundColor(.gray4)
                                Text("가족 공간 입장하기")
                                    .font(.pretendardSemiBold(size: 24))
                                    .foregroundColor(.black)
                                
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray1)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.wh)
        }
    }
}

//#Preview {
//    CreateGroupSpaceView(path: .constant([]))
//}
