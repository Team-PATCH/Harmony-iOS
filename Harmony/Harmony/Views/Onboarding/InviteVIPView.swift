//
//  InviteVIPView.swift
//  Harmony
//
//  Created by 한수빈 on 7/25/24.
//

import SwiftUI

struct InviteVIPView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var hasShared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(viewModel.vipName) \(viewModel.vipAlias)를")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.green)
                Text("초대해주세요.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text("\(viewModel.vipAlias)를 초대해야\n하모니를 시작할 수 있어요.")
                .font(.system(size: 18, weight: .medium))
                .lineSpacing(4)
                .foregroundColor(.gray5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            CustomShareButton(message: "\(viewModel.vipAlias) \(viewModel.vipName)님을 '하모니' 앱에 초대했어요. 앱을 다운로드 받고, 아래 코드를 입력하세요.\n 입장 코드: [\(viewModel.inviteCode)] 입니다.",
                              hasShared: $hasShared,
                              shareURL: URL(string: "https://apps.apple.com/kr/app/")!,
                              inviteCode: viewModel.inviteCode
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
                .background(hasShared ? Color.gray : Color.mainGreen)
                .cornerRadius(10)
            }
            
            Spacer()
            
            if hasShared {
                Button(action: {
                    viewModel.navigateTo(.inputUserInfo) // 적절한 네비게이션 대상으로 변경해주세요
                }) {
                    Text("다음")
                        .font(.pretendardSemiBold(size: 24))
                        .foregroundColor(.wh)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
        }
        .padding()
        .background(Color.wh)
    }
}

struct CustomShareButton<Content: View>: View {
    let message: String
    @Binding var hasShared: Bool
    let shareURL: URL
    let inviteCode: String
    let content: Content
    
    init(message: String, hasShared: Binding<Bool>, shareURL: URL, inviteCode: String, @ViewBuilder content: () -> Content) {
        self.message = message
        self._hasShared = hasShared
        self.shareURL = shareURL
        self.inviteCode = inviteCode
        self.content = content()
    }
    
    var body: some View {
        content
            .onTapGesture {
                shareContent()
            }
    }
    
    func shareContent() {
        let activityVC = UIActivityViewController(activityItems: [shareURL, message], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.completionWithItemsHandler = { (_, completed, _, _) in
                if completed {
                    hasShared = true
                }
            }
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
