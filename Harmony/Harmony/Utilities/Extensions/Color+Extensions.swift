//
//  Color+Extensions.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import Foundation
import SwiftUI

extension Color {
    // 16진수 문자열을 사용하여 Color를 생성하는 초기화 메서드
    init(hex: String) {
        // 문자열에서 16진수 값을 추출하여 정수로 변환
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // 16진수 정수를 사용하여 Color를 생성하는 초기화 메서드
    init(hex: UInt64) {
        let a, r, g, b: UInt64
        (a, r, g, b) = (hex >> 24, hex >> 16 & 0xFF, hex >> 8 & 0xFF, hex & 0xFF)
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
