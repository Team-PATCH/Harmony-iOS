import SwiftUI

struct AllowNotificationView: View {
    let userInfo: UserInfo?
    @State var path: [String] = []
    @State private var isNotificationEnabled = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 0) {
                    // 말풍선 내용
                    VStack(alignment: .center, spacing: 10) {
                        
                        Image(systemName: "bell.and.waves.left.and.right")
                            .foregroundColor(.mainGreen)
                        
                        Text("알림을 허용해 주세요.")
                            .font(.pretendardBold(size: 24))
                            .foregroundColor(.bl)
                        
                        Text("하모니는 가족들이 보내는 알림을 통해\n진행되는 서비스에요.\n가족들과 함께 소중한 추억을 공유해봐요.")
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
                
                // 캐릭터 이미지
                Image("moni-wholebody")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height * 0.35)
                
                Spacer()
                
                // 버튼
                Button {
                    NotificationManager.shared.requestAuthorization { granted in
                        self.isNotificationEnabled = granted
                    }
                } label: {
                    Text("dasdfasdf")
                }

                NavigationLink{
                    CreateGroupSpaceView(path: $path)
                } label: {
                    Text("하모니 시작하기")
                        .font(.pretendardSemiBold(size: 24))
                        .foregroundColor(.wh)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .frame(width: geometry.size.width)
            .background(Color.gray1)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {

        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

//#Preview {
//    AllowNotificationView(path: .constant(["1","2"]))
//}
