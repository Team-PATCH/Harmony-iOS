//
//  WaveFormView.swift
//  Harmony
//
//  Created by 한범석 on 7/23/24.
//


/*
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
*/

import SwiftUI

struct WaveFormView: View {
    @Binding var amplitude: CGFloat
    @State private var phase: CGFloat = 0
    
    private let idleAmplitude: CGFloat = 0.01 // 기본 상태의 작은 진폭
    private let idleAmplificationFactor: CGFloat = 0.05 // 기본 상태의 증폭 계수
    private let activeAmplificationFactor: CGFloat = 0.5 // 음성 입력이 있을 때의 증폭 계수
    private let amplitudeThreshold: CGFloat = 0.01 // 음성 입력 감지 임계값
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height / 2
                let wavelength = width / 2.7

                path.move(to: CGPoint(x: 0, y: midHeight))

                for x in stride(from: 0, through: width, by: 1) {
                    let relativeX = x / wavelength
                    let sine = sin(relativeX * 2 * .pi + phase)
                    
                    let effectiveAmplitude: CGFloat
                    if amplitude > amplitudeThreshold {
                        // 음성 입력이 있을 때
                        effectiveAmplitude = amplitude * activeAmplificationFactor
                    } else {
                        // 기본 상태
                        effectiveAmplitude = idleAmplitude * idleAmplificationFactor
                    }
                    
                    let y = midHeight + CGFloat(sine) * effectiveAmplitude * height / 2

                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
        .animation(.linear(duration: 1.0 / 120.0), value: amplitude)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.0 / 120.0).repeatForever(autoreverses: false)) {
                phase -= .pi / 2
            }
        }
    }
}
