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
    let baseURL = "http://localhost:3000/mc"
    
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
    
    
    
    
    /*
    func saveChatHistory(mcId: Int, messages: [ChatMessage]) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        let parameters: [String: Any] = [
            "messages": messages.map { message in
                [
                    "role": message.role,
                    "content": message.content,
                    "audioRecord": message.audioRecord.map { audioRecord in
                        [
                            "fileName": audioRecord.fileName,
                            "isUser": audioRecord.isUser,
                            "duration": audioRecord.duration
                        ]
                    }
                ]
            }
        ]
        
        return Future { promise in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseDecodable(of: ChatHistoryResponse.self) { response in
                    switch response.result {
                    case .success(let chatHistoryResponse):
                        if let messageDataArray = chatHistoryResponse.data {
                            let savedMessages = messageDataArray.map { messageData -> ChatMessage in
                                let audioRecord = messageData.audioRecord.map { audioData in
                                    AudioRecord(id: UUID(),
                                                fileName: audioData.fileName,
                                                isUser: audioData.isUser,
                                                duration: audioData.duration,
                                                remoteURL: URL(string: "\(self.baseURL)/audio/\(audioData.fileName)"))
                                }
                                return ChatMessage(id: UUID(),
                                                   role: messageData.role,
                                                   content: messageData.content,
                                                   audioRecord: audioRecord,
                                                   date: Date())
                            }
                            promise(.success(savedMessages))
                        } else {
                            promise(.success([]))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
     */
    /*
    // MARK: - 동작 버전
    
    func saveChatHistory(mcId: Int, messages: [ChatMessage]) -> AnyPublisher<Void, Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        let parameters: [String: Any] = [
            "messages": messages.map { message in
                var messageDict: [String: Any] = [
                    "role": message.role,
                    "content": message.content
                ]
                if let audioRecord = message.audioRecord {
                    messageDict["audioRecord"] = [
                        "fileName": audioRecord.fileName,
                        "isUser": audioRecord.isUser,
                        "duration": audioRecord.duration
                    ]
                }
                return messageDict
            }
        ]
        
        return Future { promise in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseDecodable(of: ChatHistoryResponse.self) { response in
                    switch response.result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    */
    /*
    // MARK: - 0805 채팅기록만 저장, 음성 파일 로컬 재생, 안정화 버전
    func saveChatHistory(mcId: Int, groupId: Int, messages: [ChatMessage]) -> AnyPublisher<Void, Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        let parameters: [String: Any] = [
            "groupId": groupId,
            "messages": messages.map { message in
                var messageDict: [String: Any] = [
                    "role": message.role,
                    "content": message.content
                ]
                if let audioRecord = message.audioRecord {
                    messageDict["audioRecord"] = [
                        "fileName": audioRecord.fileName,
                        "isUser": audioRecord.isUser,
                        "duration": audioRecord.duration
                    ]
                }
                return messageDict
            }
        ]
        
        return Future { promise in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseDecodable(of: ChatHistoryResponse.self) { response in
                    switch response.result {
                    case .success(let chatHistoryResponse):
                        if chatHistoryResponse.status {
                            promise(.success(()))
                        } else {
                            promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: chatHistoryResponse.message])))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
     */
    
    /*
     // 디버깅 진행 중...
    func saveChatHistory(mcId: Int, groupId: Int, messages: [ChatMessage]) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        return Future { promise in
            AF.upload(multipartFormData: { multipartFormData in
                // JSON 데이터 추가
                let messagesData = messages.map { message -> ChatMessageRequest in
                    ChatMessageRequest(
                        role: message.role,
                        content: message.content,
                        audioRecord: message.audioRecord.map { AudioRecordRequest(
                            fileName: $0.fileName,
                            isUser: $0.isUser,
                            duration: $0.duration
                        )}
                    )
                }
                let requestData = ChatHistoryRequest(groupId: groupId, messages: messagesData)
                let jsonData = try! JSONEncoder().encode(requestData)
                multipartFormData.append(jsonData, withName: "data")
                
                // 오디오 파일 추가
                for message in messages {
                    if let audioRecord = message.audioRecord,
                       let audioData = try? Data(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)) {
                        multipartFormData.append(audioData, withName: "audio_\(message.id)", fileName: audioRecord.fileName, mimeType: "audio/wav")
                    }
                }
            }, to: url)
            .responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistoryResponse):
                    if chatHistoryResponse.status, let savedMessages = chatHistoryResponse.data {
                        let updatedMessages = savedMessages.map { messageData in
                            ChatMessage(
                                id: UUID(uuidString: String(messageData.id)) ?? UUID(),
                                role: messageData.role,
                                content: messageData.content,
                                audioRecord: messageData.audioRecord.map { AudioRecord(
                                    id: UUID(),
                                    fileName: $0.fileName,
                                    isUser: $0.isUser,
                                    duration: $0.duration,
                                    remoteURL: URL(string: $0.fileName)
                                )},
                                date: Date()
                            )
                        }
                        promise(.success(updatedMessages))
                    } else {
                        promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: chatHistoryResponse.message])))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
     */
    
    func saveChatHistory(mcId: Int, groupId: Int, messages: [ChatMessage]) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        return Future { promise in
            AF.upload(multipartFormData: { multipartFormData in
                // JSON 데이터 추가
                let messagesData = messages.map { message -> ChatMessageRequest in
                    ChatMessageRequest(
                        role: message.role,
                        content: message.content,
                        audioRecord: message.audioRecord.map { AudioRecordRequest(
                            fileName: $0.fileName,
                            isUser: $0.isUser,
                            duration: $0.duration
                        )}
                    )
                }
                let requestData = ChatHistoryRequest(groupId: groupId, messages: messagesData)
                let jsonData = try! JSONEncoder().encode(requestData)
                multipartFormData.append(jsonData, withName: "data")
                
                // 오디오 파일 추가
                for message in messages {
                    if let audioRecord = message.audioRecord,
                       let audioData = try? Data(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)) {
                        multipartFormData.append(audioData, withName: "audio_\(message.id)", fileName: audioRecord.fileName, mimeType: "audio/wav")
                    }
                }
            }, to: url)
            .responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistoryResponse):
                    if chatHistoryResponse.status, let savedMessages = chatHistoryResponse.data {
                        let updatedMessages = savedMessages.map { messageData in
                            ChatMessage(
                                id: UUID(uuidString: String(messageData.id)) ?? UUID(),
                                role: messageData.role,
                                content: messageData.content,
                                audioRecord: messageData.audioRecord.map { AudioRecord(
                                    id: UUID(),
                                    fileName: $0.fileName,
                                    isUser: $0.isUser,
                                    duration: $0.duration,
                                    remoteURL: URL(string: $0.fileName)
                                )},
                                date: Date()
                            )
                        }
                        promise(.success(updatedMessages))
                    } else {
                        promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: chatHistoryResponse.message])))
                    }
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /*
    func getChatHistory(mcId: Int) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        return Future { promise in
            AF.request(url).responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistoryResponse):
                    if let messageData = chatHistoryResponse.data {
                        let messages = messageData.map { data in
                            ChatMessage(
                                id: UUID(),
                                role: data.role,
                                content: data.content,
                                audioRecord: data.audioRecord.map { audioData in
                                    AudioRecord(
                                        id: UUID(),
                                        fileName: audioData.fileName,
                                        isUser: audioData.isUser,
                                        duration: audioData.duration,
                                        remoteURL: URL(string: "\(self.baseURL)/audio/\(audioData.fileName)")
                                    )
                                },
                                date: Date()
                            )
                        }
                        promise(.success(messages))
                    } else {
                        promise(.success([]))  // 데이터가 없는 경우 빈 배열 반환
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
     */
    
    func getChatHistory(mcId: Int) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        return Future { promise in
            AF.request(url).responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistoryResponse):
                    if let messageData = chatHistoryResponse.data {
                        let messages = messageData.map { data in
                            let audioRecord = data.audioRecord.map { audioData in
                                AudioRecord(id: UUID(),
                                            fileName: audioData.fileName,
                                            isUser: audioData.isUser,
                                            duration: audioData.duration,
                                            remoteURL: URL(string: "\(self.baseURL)/audio/\(audioData.fileName)")!)
                            }
                            print("Loaded message: \(data.content), Audio: \(audioRecord?.fileName ?? "None")")
                            return ChatMessage(id: UUID(uuidString: String(data.id)) ?? UUID(),
                                               role: data.role,
                                               content: data.content,
                                               audioRecord: audioRecord,
                                               date: Date())
                        }
                        promise(.success(messages))
                    } else {
                        promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No chat history data"])))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    

    func getInitialPrompt(mcId: Int) -> AnyPublisher<String, Error> {
        let url = "\(baseURL)/\(mcId)/initial-prompt"
        
        return Future { promise in
            AF.request(url).responseDecodable(of: InitialPromptResponse.self) { response in
                switch response.result {
                case .success(let promptResponse):
                    promise(.success(promptResponse.data))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
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


