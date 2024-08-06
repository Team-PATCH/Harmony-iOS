//
//  QuestionCardService.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/23/24.
//

import Foundation
import Alamofire

final class QuestionCardService {
    static let shared = QuestionCardService()
    private let baseURL = "http://localhost:3000/qc" // 로컬 서버 주소

    private init() {}

    func fetchData<T: Decodable>(endpoint: String) async throws -> ServerResponse<T> {
            let url = baseURL + endpoint
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(url).responseDecodable(of: ServerResponse<T>.self) { response in
                    switch response.result {
                    case .success(let serverResponse):
                        continuation.resume(returning: serverResponse)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        
        func postData<T: Decodable>(endpoint: String, parameters: [String: Any]) async throws -> ServerResponse<T> {
            let url = baseURL + endpoint
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .responseDecodable(of: ServerResponse<T>.self) { response in
                        switch response.result {
                        case .success(let serverResponse):
                            continuation.resume(returning: serverResponse)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
            }
        }

    func fetchRawData(endpoint: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil) async throws -> Data {
        let url = baseURL + endpoint
        print("Requesting raw data from URL: \(url)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                        continuation.resume(returning: data)
                    case .failure(let error):
                        print("Network error: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    //PUT
    func putData<T: Decodable>(endpoint: String, parameters: [String: Any]) async throws -> ServerResponse<T> {
        let url = baseURL + endpoint
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(of: ServerResponse<T>.self) { response in
                    switch response.result {
                    case .success(let serverResponse):
                        continuation.resume(returning: serverResponse)
                    case .failure(let error):
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("Raw server response: \(str)")
                        }
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    //DELETE
    func deleteData<T: Decodable>(endpoint: String) async throws -> ServerResponse<T> {
        let url = baseURL + endpoint
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .delete)
                .validate()
                .responseDecodable(of: ServerResponse<T>.self) { response in
                    switch response.result {
                    case .success(let serverResponse):
                        continuation.resume(returning: serverResponse)
                    case .failure(let error):
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("Raw server response: \(str)")
                        }
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
}
