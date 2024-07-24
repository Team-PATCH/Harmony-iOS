import SwiftUI

struct VIPInfoEntryView: View {
    @Binding var path: [String]
    @State private var selectedRole: String = "선택해주세요"
    @State private var vipName: String = ""
    @State private var isDropdownOpen = false
    
    let roles = ["할머니", "할아버지"]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("누구를 위해")
                        .font(.pretendardBold(size: 28))
                        .foregroundColor(.mainGreen)
                    Text("만드시나요?")
                        .font(.pretendardBold(size: 28))
                        .foregroundColor(.black)
                }
                
                Text("할머니나 할아버지의 성함을\n입력해 주세요.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.gray5)
                    .padding(.bottom, 20)
                
                HStack(alignment: .top , spacing: 12) {
                    
                    DropdownView(selectedRole: $selectedRole, isOpen: $isDropdownOpen, roles: roles)
                    
                    NameInputView(vipName: $vipName)
                }
                
                Spacer()
                
                NavigationLink(destination: NextView()) {
                    Text("다음")
                        .font(.pretendardSemiBold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedRole != "선택해주세요" && !vipName.isEmpty ? Color.mainGreen : Color.gray3)
                        .cornerRadius(10)
                }
                .disabled(selectedRole == "선택해주세요" || vipName.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
    }
}

struct DropdownView: View {
    @Binding var selectedRole: String
    @Binding var isOpen: Bool
    let roles: [String]
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isOpen.toggle()
                }
            }) {
                HStack {
                    Text(selectedRole)
                        .font(.pretendardSemiBold(size: 18))
                    Spacer()
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.black)
                .padding()
                .background(Color.gray1)
                .cornerRadius(10)
            }
            
            if isOpen {
                VStack(spacing: 0) {
                    ForEach(roles, id: \.self) { role in
                        Button(action: {
                            selectedRole = role
                            isOpen = false
                        }) {
                            Text(role)
                                .font(.pretendardSemiBold(size: 18))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(role == selectedRole ? Color.gray2 : Color.gray1)
                        }
                    }
                }
                .background(Color.gray1)
                .cornerRadius(10)
                .offset(y: -10)
            }
        }
    }
}

struct NameInputView: View {
    @Binding var vipName: String
    
    var body: some View {
        TextField("성함", text: $vipName)
            .font(.pretendardSemiBold(size: 18))
            .padding()
            .background(Color.gray1)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(vipName.isEmpty ? Color.clear : Color.mainGreen, lineWidth: 2)
            )
    }
}

struct NextView: View {
    var body: some View {
        Text("다음 화면")
    }
}

#Preview {
    VIPInfoEntryView(path: .constant([]))
}
