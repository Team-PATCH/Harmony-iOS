//
//  RoutineService.swift
//  Harmony
//
//  Created by 조다은 on 7/29/24.
//

import Foundation
import Alamofire

final class RoutineService {
    static let shared = RoutineService()
    private let baseURL = "http://localhost:3000" // 로컬 서버 주소

    private init() {}

    func fetchRoutines() async throws -> [Routine] {
        let response: Response<[Routine]> = try await fetchData(endpoint: "/routine")
        return response.data
    }
    
    func fetchDailyRoutines() async throws -> [DailyRoutine] {
        let response: Response<[DailyRoutine]> = try await fetchData(endpoint: "/dailyroutine/today")
        return response.data
    }
    
    func fetchRoutineReactions(dailyId: Int) async throws -> [RoutineReaction] {
        let response: Response<[RoutineReaction]> = try await fetchData(endpoint: "/dailyroutine/\(dailyId)/reactions")
        return response.data
    }
    
    func createRoutine(parameters: [String: Any]) async throws -> Routine {
        let response: Response<Routine> = try await postData(endpoint: "/routine", parameters: parameters)
        return response.data
    }
    
    func updateRoutine(routineId: Int, parameters: [String: Any]) async throws -> Routine {
        let response: Response<Routine> = try await postData(endpoint: "/routine/update/\(routineId)", parameters: parameters, method: .post)
        return response.data
    }
    
    func deleteRoutine(routineId: Int) async throws -> Void {
        try await request(endpoint: "/routine/\(routineId)", method: .delete)
    }
    
    func proveDailyRoutine(dailyId: Int, imageData: Data) async throws -> DailyRoutine {
        let url = baseURL + "/dailyroutine/proving/\(dailyId)"
        let headers: HTTPHeaders = ["Content-Type": "multipart/form-data"]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "completedPhoto", fileName: "photo.jpg", mimeType: "image/jpeg")
            }, to: url, headers: headers)
            .responseDecodable(of: Response<DailyRoutine>.self) { response in
                switch response.result {
                case .success(let responseData):
                    if responseData.status {
                        continuation.resume(returning: responseData.data)
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchData<T: Decodable>(endpoint: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil) async throws -> T {
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

    private func postData<U: Decodable>(endpoint: String, parameters: [String: Any], method: HTTPMethod = .post) async throws -> U {
        let url = baseURL + endpoint
        print("Posting to URL: \(url)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
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

    private func request(endpoint: String, method: HTTPMethod) async throws -> Void {
        let url = baseURL + endpoint
        print("Requesting URL: \(url)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, encoding: JSONEncoding.default)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        continuation.resume(returning: ())
                    case .failure(let error):
                        print("Network error: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
