//
//  InviteVIPView.swift
//  Harmony
//
//  Created by 한수빈 on 7/25/24.
//

import SwiftUI

struct InviteVIPView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
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
            
            ShareLink(
                item: URL(string: "https://apps.apple.com/kr/app/instagram/id389801252")!
                ,subject: Text("하모니 앱을 다운로드")
                ,message: Text("손녀 조다은님이 할머니 윤여정님을 '하모니' 앱에 초대했어요. 앱을 다운로드 받고, 아래 코드를 입력하세요.\n 입장 코드: [\(viewModel.currentGroup?.vipInviteUrl ?? "")] 입니다.")

            ) {
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

//#Preview{
//    InviteVIPView(path: .constant([]))
//    
//}
