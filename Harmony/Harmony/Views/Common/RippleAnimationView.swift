//
//  RippleAnimationView.swift
//  Harmony
//
//  Created by 한범석 on 8/15/24.
//

import SwiftUI

struct RippleAnimationView: View {
    @Binding var amplitude: CGFloat
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // 물결 효과
            ForEach(0..<2) { i in
                Circle()
                    .stroke(Color.mainGreen.opacity(0.3), lineWidth: 2)
                    .frame(width: 90, height: 90)
                    .scaleEffect(rippleScale + CGFloat(i) * 0.3)
                    .opacity(rippleOpacity - Double(i) * 0.1)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.4),
                        value: rippleScale
                    )
            }
            

            Circle()
                .fill(Color.mainGreen.opacity(0.3))
                .frame(width: 160, height: 160)
        }
        .onAppear {
            self.rippleScale = 1.5
            self.rippleOpacity = 0.0
        }
        .onChange(of: amplitude) { newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.rippleScale = 1.5 + (newValue * 0.8)
                self.rippleOpacity = Double(0.5 + newValue * 0.5)
            }
        }
    }
}
