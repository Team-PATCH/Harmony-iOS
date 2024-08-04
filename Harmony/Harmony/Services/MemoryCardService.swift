//
//  MemoryCardService.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

/*
import Alamofire
import SwiftUI

final class MemoryCardService {
    static let shared = MemoryCardService()
    private let baseURL = "http://localhost:3000/mc"
    
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
    
    func createMemoryCard(groupId: Int, title: String, year: String, image: UIImage, completion: @escaping (Result<MemoryCardData, Error>) -> Void) {
            let url = baseURL
            
            let headers: HTTPHeaders = [
                "Content-Type": "multipart/form-data"
            ]
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append("\(groupId)".data(using: .utf8)!, withName: "groupId")
                multipartFormData.append(title.data(using: .utf8)!, withName: "title")
                multipartFormData.append(year.data(using: .utf8)!, withName: "year") // date를 year로 보냄
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                }
            }, to: url, headers: headers).responseDecodable(of: CreateMemoryCard.self) { response in
                switch response.result {
                    case .success(let createMemoryCardResponse):
                        completion(.success(createMemoryCardResponse.data))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
}
*/


import Alamofire
import Combine
import SwiftUI

final class MemoryCardService {
    static let shared = MemoryCardService()
    private let baseURL = "http://localhost:3000/mc"
    
    func fetchMemoryCards() -> AnyPublisher<[MemoryCard], Error> {
        Future { promise in
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
    
    func createMemoryCard(groupId: Int, title: String, year: String, image: UIImage) -> AnyPublisher<MemoryCardData, Error> {
        let url = baseURL
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data"
        ]
        
        return Future { promise in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append("\(groupId)".data(using: .utf8)!, withName: "groupId")
                multipartFormData.append(title.data(using: .utf8)!, withName: "title")
                multipartFormData.append(year.data(using: .utf8)!, withName: "year")
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                }
            }, to: url, headers: headers).responseDecodable(of: CreateMemoryCard.self) { response in
                switch response.result {
                case .success(let createMemoryCardResponse):
                    promise(.success(createMemoryCardResponse.data))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
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


