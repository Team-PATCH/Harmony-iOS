import SwiftUI
import KakaoSDKUser


struct LoginView: View {
    @State var path: [String] = []
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 22) {
                        Text("가족과 함께 만드는 소중한 추억")
                            .foregroundColor(.gray5)
                            .font(.pretendardMedium(size: 18))
                        Image("harmony-logo")
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        NavigationLink {
                            AllowNotificationView(userInfo: authViewModel.userInfo, path: $path)
                        } label: {
                            Text("Apple로 계속하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.bl)
                                .foregroundColor(.wh)
                                .cornerRadius(10)
                        }
                        .frame(width: geometry.size.width * 0.9)
                        
                        Button {
                            authViewModel.loginWithKakao()
                        } label: {
                            Text("카카오로 계속하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.yellow)
                                .foregroundColor(.bl)
                                .cornerRadius(10)
                        }
                        .frame(width: geometry.size.width * 0.9)
                    }
                    .padding(.bottom, 30)
                }
                .frame(width: geometry.size.width)
                .font(.pretendardBold(size: 24))
            }
            .background(Color.gray1)
            .onChange(of: authViewModel.isLoggedIn) { newValue in
                if newValue {
                    path.append("AllowNotificationView")
                }
            }
            .navigationDestination(for: String.self) { view in
                if view == "AllowNotificationView" {
                    AllowNotificationView(userInfo: authViewModel.userInfo, path: $path)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
