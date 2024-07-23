//
//  WaveFormView.swift
//  Harmony
//
//  Created by 한범석 on 7/23/24.
//

import SwiftUI

struct WaveFormView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height / 2
                let amplitude = height / 4

                path.move(to: CGPoint(x: 0, y: midHeight))

                for x in stride(from: 0, through: width, by: 5) {
                    let relativeX = x / width
                    let sine = sin(relativeX * 2 * .pi + phase)
                    let y = midHeight + amplitude * sine

                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.mainGreen, lineWidth: 2)
            .onAppear {
                withAnimation(Animation.linear(duration: 0.05).repeatForever(autoreverses: false)) {
                    phase += .pi / 2
                }
            }
        }
    }
}

#Preview {
    WaveFormView()
}
