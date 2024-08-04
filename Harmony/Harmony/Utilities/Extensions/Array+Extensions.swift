//
//  Array+Extensions.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
