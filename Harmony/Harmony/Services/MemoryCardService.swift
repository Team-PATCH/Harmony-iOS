//
//  MemoryCardService.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//


import Alamofire

final class MemoryCardService {
    static let shared = MemoryCardService()
    private let baseURL = "https://harmony-sion.azurewebsites.net/mc"
    
    func fetchMemoryCards() async throws -> [MemoryCard]? {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(baseURL).responseDecodable(of: MemoryCardList.self) { response in
                switch response.result {
                    case .success(let memoryCardList):
                        continuation.resume(returning: memoryCardList.data)
                    case .failure(let error):
                        print("추억카드 목록 불러오기 실패: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchMemoryCardDetail(id: Int) async throws -> MemoryCardDetail? {
        let url = "\(baseURL)/\(id)"
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url).responseDecodable(of: MemoryCardDetail.self) { response in
                switch response.result {
                    case .success(let memoryCardDetail):
                        continuation.resume(returning: memoryCardDetail)
                    case .failure(let error):
                        print("단일 추억카드 상세 불러오기 실패: \(error.localizedDescription)")
                        debugPrint(error)
                        continuation.resume(throwing: error)
                }
            }
        }
    }
}




/*
import Alamofire
import Combine
import Foundation

final class MemoryCardService {
    static let shared = MemoryCardService()
    private let baseURL = "https://patch-harmony.azurewebsites.net/mc"
    
    private init() {}
    
    func fetchMemoryCards() -> AnyPublisher<[MemoryCard], Error> {
        return Future { promise in
            AF.request(self.baseURL).responseDecodable(of: MemoryCardList.self) { response in
                switch response.result {
                case .success(let memoryCardList):
                    if let data = memoryCardList.data {
                        promise(.success(data))
                    } else {
                        promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
                    }
                case .failure(let error):
                    print("추억카드 목록 불러오기 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func fetchMemoryCardDetail(id: Int) -> AnyPublisher<MemoryCardDetail, Error> {
        let url = "\(baseURL)/\(id)"
        return Future { promise in
            AF.request(url).responseDecodable(of: MemoryCardDetail.self) { response in
                switch response.result {
                case .success(let memoryCardDetail):
                    promise(.success(memoryCardDetail))
                case .failure(let error):
                    print("단일 추억카드 상세 불러오기 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
*/


