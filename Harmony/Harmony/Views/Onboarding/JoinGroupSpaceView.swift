//
//  JoinGroupSpaceView.swift
//  Harmony
//
//  Created by 한수빈 on 8/1/24.
//

import SwiftUI

struct JoinGroupSpaceView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isConfirmButtonEnabled = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                Text("초대코드를\n입력해주세요.")
                    .font(.pretendardBold(size: 28))
                    .foregroundColor(.black)
                
                Text("가족 매니저가 전송한\n5자리 코드를 입력해주세요.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.gray5)
                    .padding(.bottom, 20)
                
                TextField("", text: $viewModel.inviteCode)
                    .focused($isFocused)
                
                    .onChange(of: viewModel.inviteCode) { newValue in
                        if newValue.count > 5 {
                            viewModel.inviteCode = String(newValue.prefix(5))
                            isConfirmButtonEnabled = true
                        }
                    }
                    .onTapGesture {
                        isFocused = true
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.9)
                    .multilineTextAlignment(.center)
                    .background(Color.gray1)
                    .font(.pretendardBold(size: 27))
                    .cornerRadius(10)

                Spacer()
                
                Button {
                    viewModel.joinGroup()
                } label: {
                    Text("확인")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isConfirmButtonEnabled ? Color.green : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .disabled(!isConfirmButtonEnabled)
            }
            .padding()
            .background(Color.wh)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { _ in
                if viewModel.inviteCode.count == 5 {
                    isConfirmButtonEnabled = true
                } else {
                    isConfirmButtonEnabled = false
                    
                }
            }
        }
    }
}
//#Preview {
//    JoinGroupSpaceView()
//}
