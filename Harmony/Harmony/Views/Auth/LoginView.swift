import SwiftUI
import KakaoSDKUser
import AuthenticationServices

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center, spacing: 22) {
                Text("가족과 함께 만드는 소중한 추억")
                    .foregroundColor(.gray5)
                    .font(.pretendardMedium(size: 18))
                Image("harmony-logo")
            }
            
            Spacer()
            // TODO: - 최근 로그인했던 방식 저장하는 로직 필요
            VStack() {
#if DEBUG
                DebugLoginButtons(
                    handleVIPEntry: handleVIPEntry,
                    handleMemberEntry: handleMemberEntry
                )
#endif

                AppleSignInButton(completion: { appleIDCredential in authViewModel.loginWithApple(appleIDCredential: appleIDCredential)})
                    .padding(.horizontal)
                    .frame(height: 60)
  
                Button {
                    authViewModel.loginWithKakao()
                } label: {
                    HStack {
                        KakaoLogoView(size: 20)
                        Text("카카오로 계속하기")
                            .font(.pretendardMedium(size: 20))
                            .foregroundStyle(Color(white: 0, opacity: 85))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color.init(hex: "FEE500"))
                .cornerRadius(8, corners: .allCorners)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .background(Color.gray1)
    }
}

struct KakaoLogoView: View {
    var size: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let scale = size.width / 36
            
            let clipPath = Path { path in
                path.addRect(CGRect(x: 0, y: 0, width: 36 * scale, height: 36 * scale))
            }
            
            let logoPath = Path { path in
                path.move(to: CGPoint(x: 18 * scale, y: 1.2 * scale))
                path.addCurve(
                    to: CGPoint(x: 0, y: 15.1046 * scale),
                    control1: CGPoint(x: 8.05835 * scale, y: 1.2 * scale),
                    control2: CGPoint(x: 0, y: 7.42593 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 7.86305 * scale, y: 26.5939 * scale),
                    control1: CGPoint(x: 0, y: 19.8801 * scale),
                    control2: CGPoint(x: 3.11681 * scale, y: 24.09 * scale)
                )
                path.addLine(to: CGPoint(x: 5.86606 * scale, y: 33.889 * scale))
                path.addCurve(
                    to: CGPoint(x: 6.99293 * scale, y: 34.6739 * scale),
                    control1: CGPoint(x: 5.68962 * scale, y: 34.5336 * scale),
                    control2: CGPoint(x: 6.42683 * scale, y: 35.0474 * scale)
                )
                path.addLine(to: CGPoint(x: 15.7467 * scale, y: 28.8964 * scale))
                path.addCurve(
                    to: CGPoint(x: 18 * scale, y: 29.0093 * scale),
                    control1: CGPoint(x: 16.4854 * scale, y: 28.9677 * scale),
                    control2: CGPoint(x: 17.2362 * scale, y: 29.0093 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 35.9999 * scale, y: 15.1046 * scale),
                    control1: CGPoint(x: 27.9409 * scale, y: 29.0093 * scale),
                    control2: CGPoint(x: 35.9999 * scale, y: 22.7836 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 18 * scale, y: 1.2 * scale),
                    control1: CGPoint(x: 35.9999 * scale, y: 7.42593 * scale),
                    control2: CGPoint(x: 27.9409 * scale, y: 1.2 * scale)
                )
                path.closeSubpath()
            }
            
            context.clip(to: clipPath)
            context.fill(logoPath, with: .color(.black))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
