//
//  MemoryCardService.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import Alamofire
import Combine
import SwiftUI

final class MemoryCardService {
    static let shared = MemoryCardService()
//    let baseURL = "http://localhost:3000/mc"
    private let baseURL = Bundle.main.infoDictionary?["SION_BASE_URL"] as! String
    
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
    
    
    func saveChatHistory(mcId: Int, groupId: Int, messages: [ChatMessage]) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        return Future { promise in
            AF.upload(multipartFormData: { multipartFormData in
                let messagesData = messages.map { message -> [String: Any] in
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
                let requestData: [String: Any] = [
                    "groupId": groupId,
                    "messages": messagesData
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: requestData),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    multipartFormData.append(jsonString.data(using: .utf8)!, withName: "data")
                }
                
                for message in messages {
                    if let audioRecord = message.audioRecord,
                       let audioData = try? Data(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)) {
                        multipartFormData.append(audioData, withName: "audio", fileName: audioRecord.fileName, mimeType: "audio/wav")
                    }
                }
            }, to: url)
            .validate()
            .responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                case .success(let chatHistoryResponse):
                    if chatHistoryResponse.status, let data = chatHistoryResponse.data {
                        let chatMessages = data.map { messageData in
                            ChatMessage(id: UUID(uuidString: String(messageData.id)) ?? UUID(),
                                        role: messageData.role,
                                        content: messageData.content,
                                        audioRecord: messageData.audioRecord.map { AudioRecord(
                                            id: UUID(),
                                            fileName: $0.fileName,
                                            isUser: $0.isUser,
                                            duration: $0.duration,
                                            remoteURL: URL(string: $0.fileName)
                                        )},
                                        date: Date())
                        }
                        promise(.success(chatMessages))
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
    
//    func getSummary(mcId: Int, forceUpdate: Bool = false) -> AnyPublisher<String, Error> {
//        var urlComponents = URLComponents(string: "\(baseURL)/\(mcId)/summary")!
//        if forceUpdate {
//            urlComponents.queryItems = [URLQueryItem(name: "forceUpdate", value: "true")]
//        }
//        
//        return Future { promise in
//            AF.request(urlComponents.url!).responseDecodable(of: SummaryResponse.self) { response in
//                switch response.result {
//                case .success(let summaryResponse):
//                    if summaryResponse.status {
//                        promise(.success(summaryResponse.data))
//                    } else {
//                        promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: summaryResponse.message])))
//                    }
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
    func getSummary(mcId: Int, forceUpdate: Bool = false) -> AnyPublisher<SummaryData, Error> {
        var urlComponents = URLComponents(string: "\(baseURL)/\(mcId)/summary")!
        if forceUpdate {
            urlComponents.queryItems = [URLQueryItem(name: "forceUpdate", value: "true")]
        }
        
        return Future { promise in
            AF.request(urlComponents.url!).responseDecodable(of: SummaryResponse.self) { response in
                switch response.result {
                case .success(let summaryResponse):
                    if summaryResponse.status {
                        promise(.success(summaryResponse.data))
                    } else {
                        promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: summaryResponse.message])))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateChatHistory(mcId: Int, groupId: Int, messages: [ChatMessage]) -> AnyPublisher<[ChatMessage], Error> {
        let url = "\(baseURL)/\(mcId)/chat"
        
        return Future { promise in
            AF.upload(multipartFormData: { multipartFormData in
                let messagesData = messages.map { message -> [String: Any] in
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
                let requestData: [String: Any] = [
                    "groupId": groupId,
                    "messages": messagesData
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: requestData),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    multipartFormData.append(jsonString.data(using: .utf8)!, withName: "data")
                }
                
                for message in messages {
                    if let audioRecord = message.audioRecord,
                       let audioData = try? Data(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)) {
                        multipartFormData.append(audioData, withName: "audio", fileName: audioRecord.fileName, mimeType: "audio/wav")
                    }
                }
            }, to: url, method: .patch)
            .responseDecodable(of: ChatHistoryResponse.self) { response in
                switch response.result {
                    case .success(let chatHistoryResponse):
                        if chatHistoryResponse.status, let data = chatHistoryResponse.data {
                            let chatMessages = data.map { messageData in
                                ChatMessage(id: UUID(uuidString: String(messageData.id)) ?? UUID(),
                                            role: messageData.role,
                                            content: messageData.content,
                                            audioRecord: messageData.audioRecord.map { AudioRecord(id: UUID(),
                                                                                                   fileName: $0.fileName,
                                                                                                   isUser: $0.isUser,
                                                                                                   duration: $0.duration,
                                                                                                   remoteURL: URL(string: $0.fileName)) },
                                            date: Date())
                            }
                            promise(.success(chatMessages))
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


