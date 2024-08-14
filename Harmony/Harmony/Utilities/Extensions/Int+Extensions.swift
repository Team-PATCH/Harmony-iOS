//
//  Int+Extensions.swift
//  Harmony
//
//  Created by 한범석 on 8/13/24.
//

import Foundation

// MARK: - VIP의 홈 뷰에서 추억카드 확인하기 버튼을 클릭했을 때의 명확한 상태 추적을 위한 Identifiable 프로토콜을 Int에 확장

extension Int: Identifiable {
    public var id: Int { self }
}
