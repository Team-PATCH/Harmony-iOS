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

    func fetchData<T: Decodable>(endpoint: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil) async throws -> T {
        let url = baseURL + endpoint
        print("Requesting URL: \(url)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: data)
                            continuation.resume(returning: decodedData)
                        } catch {
                            print("Decoding error: \(error)")
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        print("Network error: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func postData<U: Decodable>(endpoint: String, parameters: [String: Any]) async throws -> U {
        let url = baseURL + endpoint
        print("Posting to URL: \(url)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                        do {
                            let decodedData = try JSONDecoder().decode(U.self, from: data)
                            continuation.resume(returning: decodedData)
                        } catch {
                            print("Decoding error: \(error)")
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        print("Network error: \(error)")
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
}
