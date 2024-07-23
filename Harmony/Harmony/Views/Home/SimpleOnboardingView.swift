import SwiftUI


struct SimpleOnboardingView: View {
    @Binding var isAuth: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    saveUserData(permission: "v")
                    isAuth = true
                } label: {
                    Text("VIP")
                }
                .padding()
                .background(Color.mainGreen)
                
                Button {
                    saveUserData(permission: "m")
                    isAuth = true
                } label: {
                    Text("Member")
                }
                .padding()
                .background(Color.gray1)
            }
            .font(.pretendardBold(size: 24))
            .padding()
        }
    }
    
    func saveUserData(permission: String) {
        let userData: UserData
        
        if permission == "v" {
            userData = UserData(
                userId: "yeojeong@naver.com",
                nick: "윤여정",
                permissionId: "v",
                groupId: 1,
                alias: "할머니 윤여정",
                deviceToken: "token123"
            )
        } else {
            userData = UserData(
                userId: "user2@example.com",
                nick: "최우식",
                permissionId: "m",
                groupId: 1,
                alias: "손자 최우식",
                deviceToken: "token456"
            )
        }
        
        UserDefaultsManager.shared.saveUserData(userData)
    }
}

#Preview {
    SimpleOnboardingView(isAuth: .constant(false))
}
