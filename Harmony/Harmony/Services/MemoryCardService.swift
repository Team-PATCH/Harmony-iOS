//
//  MemoryCardService.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import Foundation
import Alamofire

class MemoryCardService {
    static let shared = MemoryCardService()
    private let baseURL = "http://localhost:3000/mc"
    
    func fetchMemoryCards(completion: @escaping ([MemoryCard]?) -> Void) {
        AF.request(baseURL).responseDecodable(of: MemoryCardList.self) { response in
            switch response.result {
                case .success(let memoryCardList):
                    completion(memoryCardList.data)
                case .failure(let error):
                    print("추억카드 목록 불러오기 실패: \(error.localizedDescription)")
                    completion(nil)
            }
        }
    }
    
    func fetchMemoryCardDetail(id: Int, completion: @escaping (MemoryCardDetail?) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url).responseDecodable(of: MemoryCardDetail.self) { response in
            switch response.result {
                case .success(let memoryCardDetail):
                    completion(memoryCardDetail)
                case .failure(let error):
                    print("단일 추억카드 상세 불러오기 실패: \(error.localizedDescription)")
                    completion(nil)
            }
        }
    }
    
}
