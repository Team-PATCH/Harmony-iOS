//
//  APIResponse.swift
//  Harmony
//
//  Created by 조다은 on 7/30/24.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    let status: Bool
    let data: T
    let message: String?
}
