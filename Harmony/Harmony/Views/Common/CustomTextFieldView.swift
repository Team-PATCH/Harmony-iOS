//
//  CustomTextFieldView.swift
//  Harmony
//
//  Created by 한수빈 on 7/24/24.
//

import SwiftUI

struct CustomTextFieldView: View {
    let placeholder: String
    @Binding var value: String

    var body: some View {
        TextField(placeholder, text: $value)
            .font(.pretendardSemiBold(size: 18))
            .padding()
            .background(Color.gray1)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(value.isEmpty ? Color.clear : Color.mainGreen, lineWidth: 2)
            )

    }
}

#Preview {
    CustomTextFieldView(placeholder: "33", value: .constant("dd"))
}
