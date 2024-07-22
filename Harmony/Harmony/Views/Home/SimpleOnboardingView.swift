//
//  SimpleOnboardingView.swift
//  Harmony
//
//  Created by 한수빈 on 7/22/24.
//

import SwiftUI

struct SimpleOnboardingView: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Text("VIP")
                    .font(.pretendardBold(size: 24))
            }
            .padding()
            .background(.mainGreen)
            .background(Color.gray1)
            Button {
                
            } label: {
                Text("Member")
                    .font(.pretendardBold(size: 24))
            }
            .padding()
            .background(.mint)
        }
        .padding()
    }
}

#Preview {
    SimpleOnboardingView()
}
