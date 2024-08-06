import SwiftUI

struct InputVIPInfoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedRole: String = "선택해주세요"
    @State private var isDropdownOpen = false
    
    let roles = ["할머니", "할아버지"]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("누구를 위해")
                    .font(.pretendardBold(size: 28))
                    .foregroundColor(.mainGreen)
                Text("만드시나요?")
                    .font(.pretendardBold(size: 28))
                    .foregroundColor(.bl)
            }
            
            Text("할머니나 할아버지의 성함을\n입력해 주세요.")
                .font(.pretendardMedium(size: 18))
                .foregroundColor(.gray5)
                .padding(.bottom, 20)
            
            HStack(alignment: .top , spacing: 12) {
                
                CustomDropdownView(selected: $selectedRole, isOpen: $isDropdownOpen, list: roles)
                
                CustomTextFieldView(placeholder: "성함", value: Binding(
                    get: { self.viewModel.groupName },
                    set: { self.viewModel.groupName = $0 }
                ))
            }
            
            Spacer()
            
            Button{
                viewModel.createGroup()
            } label: {
                Text("다음")
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(.wh)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedRole != "선택해주세요" && !viewModel.groupName.isEmpty ? Color.mainGreen : Color.gray3)
                    .cornerRadius(10)
            }
            .disabled(selectedRole == "선택해주세요" || viewModel.groupName.isEmpty)
        }
        .padding()
        .background(Color.wh)
        
    }
}
//
//#Preview {
//    VIPInfoEntryView(path: .constant([]))
//}
