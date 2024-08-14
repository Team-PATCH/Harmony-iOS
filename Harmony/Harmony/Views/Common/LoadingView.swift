//
//  LoadingView.swift
//  Harmony
//
//  Created by 한범석 on 8/13/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack {
            Image("moni-wholebody")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            // 이 주석은 회전 애니메이션입니다.
//                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
//                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
            Text("모니가 상세 정보를 가져오고 있어요😀")
                .font(.headline)
                .padding(.top, 20)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
}
