import SwiftUI

struct LoginView: View {
    @State var path: [String] = []
    
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
                            AllowNotificationView(path: $path)
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
                            // 카카오 로그인 액션
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
        }
    }
}

#Preview {
    LoginView()
}
