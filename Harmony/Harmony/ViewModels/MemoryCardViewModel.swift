//
//  MemoryCardViewModel.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

/*
import SwiftUI
import Combine
import Alamofire
import AVFoundation


 final class MemoryCardViewModel: ObservableObject {
 @Published var memoryCards: [MemoryCard] = []
 @Published var filteredMemoryCards: [MemoryCard] = []
 @Published var memoryCardDetail: MemoryCardDetail?
 @Published var memoryCard: MemoryCard?
 @Published var chatBotMessage: String = "안녕하세요! 추억을 기록하러 오셨군요.\n 아래 버튼을 누르면 기록을 시작합니다."
 @Published var isRecording = false
 @Published var isLoading = false
 @Published var errorMessage: String?
 @Published var hasLoaded = false
 @Published var isSortedByNewest = true
 @Published var memoryCardData: MemoryCardData?
 
 private var cancellables = Set<AnyCancellable>()
 //    private let speechService = SpeechService()
 //    private let ttsService = TextToSpeechService()
 
 func loadMemoryCards() {
 Task {
 await loadMemoryCardsAsync()
 }
 }
 
 private func loadMemoryCardsAsync() async {
 isLoading = true
 errorMessage = nil
 hasLoaded = false
 do {
 if let cards = try await MemoryCardService.shared.fetchMemoryCards() {
 DispatchQueue.main.async { [weak self] in
 self?.memoryCards = cards
 self?.filteredMemoryCards = cards
 self?.applySorting()
 self?.hasLoaded = true
 self?.isLoading = false
 }
 }
 } catch {
 DispatchQueue.main.async { [weak self] in
 self?.errorMessage = "추억 카드 목록을 조회하는 데 실패했습니다: \(error.localizedDescription)"
 self?.isLoading = false
 }
 }
 }
 
 func loadMemoryCardDetail(id: Int) {
 Task {
 await loadMemoryCardDetailAsync(id: id)
 }
 }
 
 private func loadMemoryCardDetailAsync(id: Int) async {
 isLoading = true
 errorMessage = nil
 do {
 if let detail = try await MemoryCardService.shared.fetchMemoryCardDetail(id: id) {
 DispatchQueue.main.async { [weak self] in
 self?.memoryCardDetail = detail
 self?.memoryCard = MemoryCard(id: detail.memorycardId, title: detail.title, dateTime: detail.dateTime, image: detail.image)
 self?.isLoading = false
 }
 }
 } catch {
 DispatchQueue.main.async { [weak self] in
 self?.errorMessage = "추억 카드 상세 정보를 조회하는 데 실패했습니다: \(error.localizedDescription)"
 self?.isLoading = false
 }
 }
 }
 
 func createMemoryCard(groupId: Int, title: String, date: Date, image: UIImage, completion: @escaping (Result<MemoryCardData, Error>) -> Void) {
 isLoading = true
 let serverDateFormatter = DateFormatter()
 serverDateFormatter.dateFormat = "yyyy-MM-dd"
 let formattedDate = serverDateFormatter.string(from: date)
 
 MemoryCardService.shared.createMemoryCard(groupId: groupId, title: title, year: formattedDate, image: image) { [weak self] result in
 DispatchQueue.main.async {
 self?.isLoading = false
 switch result {
 case .success(let memoryCardData):
 self?.memoryCardData = memoryCardData
 completion(.success(memoryCardData))
 case .failure(let error):
 self?.errorMessage = "추억 카드 생성 실패: \(error.localizedDescription)"
 completion(.failure(error))
 }
 }
 }
 }
 
 
 func searchMemoryCards(with query: String) {
 if query.isEmpty {
 filteredMemoryCards = memoryCards
 } else {
 filteredMemoryCards = memoryCards.filter { card in
 card.title.contains(query)
 }
 }
 applySorting()
 }
 
 func toggleSorting() {
 isSortedByNewest.toggle()
 applySorting()
 }
 
 private func applySorting() {
 if isSortedByNewest {
 filteredMemoryCards = filteredMemoryCards.sorted {
 date(from: $0.dateTime) > date(from: $1.dateTime)
 }
 } else {
 filteredMemoryCards = filteredMemoryCards.sorted {
 date(from: $0.dateTime) < date(from: $1.dateTime)
 }
 }
 }
 
 private func date(from dateTime: String) -> Date {
 let dateFormatter = ISO8601DateFormatter()
 dateFormatter.formatOptions = [.withInternetDateTime]
 return dateFormatter.date(from: dateTime) ?? Date.distantPast
 }
 
 //    func startRecording() {
 //        // STT 시작
 //        speechService.startRecording()
 //    }
 //
 //    func stopRecording() {
 //        // STT 종료 및 결과 처리
 //        speechService.stopRecording { [weak self] result in
 //            if let text = result {
 //                self?.callOpenAIAPI(with: text)
 //                print("STT Result: \(text)")
 //            }
 //        }
 //    }
 //
 //    func callOpenAIAPI(with text: String) {
 //        // OpenAI API 호출 로직
 //        let url = "https://patch-harmony.openai.azure.com/v1/engines/davinci/completions"
 //        let parameters: [String: Any] = [
 //            "prompt": text,
 //            "max_tokens": 150
 //        ]
 //
 //        let headers: HTTPHeaders = [
 //            "Content-Type": "application/json",
 //            "Authorization": "Bearer "
 //        ]
 //
 //        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
 //            .responseDecodable(of: OpenAICompletionResponse.self) { response in
 //                switch response.result {
 //                case .success(let completionResponse):
 //                    if let text = completionResponse.choices.first?.text {
 //                        DispatchQueue.main.async {
 //                            self.chatBotMessage = text
 //                            self.ttsService.synthesizeText(text) { audioData in
 //                                if let data = audioData {
 //                                    self.playAudio(data: data)
 //                                }
 //                            }
 //                        }
 //                    } else {
 //                        print("Failed to parse text from OpenAI API response")
 //                    }
 //                case .failure(let error):
 //                    print("Failed to call OpenAI API: \(error.localizedDescription)")
 //                }
 //            }
 //    }
 //
 //    func playAudio(data: Data) {
 //        // TTS로 변환된 음성 재생 로직
 //        do {
 //            let audioPlayer = try AVAudioPlayer(data: data)
 //            audioPlayer.play()
 //        } catch {
 //            print("Failed to play audio: \(error.localizedDescription)")
 //        }
 //    }
 }
 */

/*
import SwiftUI
import Combine
import Alamofire
import AVFoundation

final class MemoryCardViewModel: ObservableObject {
    @Published var memoryCards: [MemoryCard] = []
    @Published var filteredMemoryCards: [MemoryCard] = []
    @Published var memoryCardDetail: MemoryCardDetail?
    @Published var memoryCard: MemoryCard?
    @Published var chatHistory: [ChatMessage] = []
    @Published var chatBotMessage: String = "안녕하세요! 추억을 기록하러 오셨군요.\n 아래 버튼을 누르면 기록을 시작합니다."
    @Published var isRecording = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoaded = false
    @Published var isSortedByNewest = true
    @Published var memoryCardData: MemoryCardData?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMemoryCards() {
        Task {
            await loadMemoryCardsAsync()
        }
    }
    
    /*
    private func loadMemoryCardsAsync() async {
        isLoading = true
        errorMessage = nil
        hasLoaded = false
        do {
            if let cards = try await MemoryCardService.shared.fetchMemoryCards() {
                DispatchQueue.main.async { [weak self] in
                    self?.memoryCards = cards
                    self?.filteredMemoryCards = cards
                    self?.applySorting()
                    self?.hasLoaded = true
                    self?.isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "추억 카드 목록을 조회하는 데 실패했습니다: \(error.localizedDescription)"
                self?.isLoading = false
            }
        }
    }
     */
    private func loadMemoryCardsAsync() async {
        isLoading = true
        errorMessage = nil
        hasLoaded = false
        do {
            if let cards = try await MemoryCardService.shared.fetchMemoryCards() {
                Just(cards)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] cards in
                        self?.memoryCards = cards
                        self?.filteredMemoryCards = cards
                        self?.applySorting()
                        self?.hasLoaded = true
                        self?.isLoading = false
                    })
                    .store(in: &cancellables)
            }
        } catch {
            Just("추억 카드 목록을 조회하는 데 실패했습니다: \(error.localizedDescription)")
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                    self?.isLoading = false
                })
                .store(in: &cancellables)
        }
    }
    
    
    func loadMemoryCardDetail(id: Int) {
        Task {
            await loadMemoryCardDetailAsync(id: id)
        }
    }
    
    /*
    private func loadMemoryCardDetailAsync(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            if let detail = try await MemoryCardService.shared.fetchMemoryCardDetail(id: id) {
                DispatchQueue.main.async { [weak self] in
                    self?.memoryCardDetail = detail
                    self?.memoryCard = MemoryCard(id: detail.memorycardId, title: detail.title, dateTime: detail.dateTime, image: detail.image)
                    self?.chatHistory = detail.description.isEmpty ? [] : self?.parseChatHistory(from: detail.description) ?? []
                    self?.isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "추억 카드 상세 정보를 조회하는 데 실패했습니다: \(error.localizedDescription)"
                self?.isLoading = false
            }
        }
    }
     */
    private func loadMemoryCardDetailAsync(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            if let detail = try await MemoryCardService.shared.fetchMemoryCardDetail(id: id) {
                Just(detail)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] detail in
                        self?.memoryCardDetail = detail
                        self?.memoryCard = MemoryCard(id: detail.memorycardId, title: detail.title, dateTime: detail.dateTime, image: detail.image)
                        self?.chatHistory = detail.description.isEmpty ? [] : self?.parseChatHistory(from: detail.description) ?? []
                        self?.isLoading = false
                    })
                    .store(in: &cancellables)
            }
        } catch {
            Just("추억 카드 상세 정보를 조회하는 데 실패했습니다: \(error.localizedDescription)")
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                    self?.isLoading = false
                })
                .store(in: &cancellables)
        }
    }
    
    func createMemoryCard(groupId: Int, title: String, date: Date, image: UIImage, completion: @escaping (Result<MemoryCardData, Error>) -> Void) {
            isLoading = true
            let serverDateFormatter = DateFormatter()
            serverDateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = serverDateFormatter.string(from: date)
            
            MemoryCardService.shared.createMemoryCard(groupId: groupId, title: title, year: formattedDate, image: image) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                        case .success(let memoryCardData):
                            self?.memoryCardData = memoryCardData
                            completion(.success(memoryCardData))
                        case .failure(let error):
                            self?.errorMessage = "추억 카드 생성 실패: \(error.localizedDescription)"
                            completion(.failure(error))
                    }
                }
            }
        }
    
    func parseChatHistory(from description: String) -> [ChatMessage] {
        // 구현: description 문자열을 분석하여 ChatMessage 배열로 변환
        // 예제용 임시 구현
        return []
    }
    
    func searchMemoryCards(with query: String) {
        if query.isEmpty {
            filteredMemoryCards = memoryCards
        } else {
            filteredMemoryCards = memoryCards.filter { card in
                card.title.contains(query)
            }
        }
        applySorting()
    }
    
    func toggleSorting() {
        isSortedByNewest.toggle()
        applySorting()
    }
    
    private func applySorting() {
        if isSortedByNewest {
            filteredMemoryCards = filteredMemoryCards.sorted {
                date(from: $0.dateTime) > date(from: $1.dateTime)
            }
        } else {
            filteredMemoryCards = filteredMemoryCards.sorted {
                date(from: $0.dateTime) < date(from: $1.dateTime)
            }
        }
    }
    
    private func date(from dateTime: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        return dateFormatter.date(from: dateTime) ?? Date.distantPast
    }
}
 */

import SwiftUI
import Combine
import Alamofire
import AVFoundation

final class MemoryCardViewModel: ObservableObject {
    @Published var memoryCards: [MemoryCard] = []
    @Published var filteredMemoryCards: [MemoryCard] = []
    @Published var memoryCardDetail: MemoryCardDetail?
    @Published var memoryCard: MemoryCard?
    @Published var chatHistory: [ChatMessage] = []
    @Published var chatBotMessage: String = "안녕하세요! 추억을 기록하러 오셨군요.\n 아래 버튼을 누르면 기록을 시작합니다."
    @Published var isRecording = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoaded = false
    @Published var isSortedByNewest = true
    @Published var memoryCardData: MemoryCardData?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMemoryCards() {
        isLoading = true
        errorMessage = nil
        hasLoaded = false
        MemoryCardService.shared.fetchMemoryCards()
            .sink(receiveCompletion: { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    self?.isLoading = false
                    self?.hasLoaded = true
                case .failure(let error):
                    self?.errorMessage = "추억 카드 목록을 조회하는 데 실패했습니다: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] cards in
                self?.memoryCards = cards
                self?.filteredMemoryCards = cards
                self?.applySorting()
            })
            .store(in: &cancellables)
    }
    
    func loadMemoryCardDetail(id: Int) {
        isLoading = true
        errorMessage = nil
        MemoryCardService.shared.fetchMemoryCardDetail(id: id)
            .sink(receiveCompletion: { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = "추억 카드 상세 정보를 조회하는 데 실패했습니다: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] detail in
                self?.memoryCardDetail = detail
                self?.memoryCard = MemoryCard(id: detail.memorycardId, title: detail.title, dateTime: detail.dateTime, image: detail.image)
                self?.chatHistory = detail.description.isEmpty ? [] : self?.parseChatHistory(from: detail.description) ?? []
            })
            .store(in: &cancellables)
    }
    
    func createMemoryCard(groupId: Int, title: String, date: Date, image: UIImage, completion: @escaping (Result<MemoryCardData, Error>) -> Void) {
        isLoading = true
        let serverDateFormatter = DateFormatter()
        serverDateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = serverDateFormatter.string(from: date)
        
        MemoryCardService.shared.createMemoryCard(groupId: groupId, title: title, year: formattedDate, image: image)
            .sink(receiveCompletion: { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = "추억 카드 생성 실패: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }, receiveValue: { [weak self] memoryCardData in
                self?.memoryCardData = memoryCardData
                completion(.success(memoryCardData))
            })
            .store(in: &cancellables)
    }
    
    func parseChatHistory(from description: String) -> [ChatMessage] {
        // 구현: description 문자열을 분석하여 ChatMessage 배열로 변환
        // 예제용 임시 구현
        return []
    }
    
    func searchMemoryCards(with query: String) {
        if query.isEmpty {
            filteredMemoryCards = memoryCards
        } else {
            filteredMemoryCards = memoryCards.filter { card in
                card.title.contains(query)
            }
        }
        applySorting()
    }
    
    func toggleSorting() {
        isSortedByNewest.toggle()
        applySorting()
    }
    
    private func applySorting() {
        if isSortedByNewest {
            filteredMemoryCards = filteredMemoryCards.sorted {
                date(from: $0.dateTime) > date(from: $1.dateTime)
            }
        } else {
            filteredMemoryCards = filteredMemoryCards.sorted {
                date(from: $0.dateTime) < date(from: $1.dateTime)
            }
        }
    }
    
    private func date(from dateTime: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        return dateFormatter.date(from: dateTime) ?? Date.distantPast
    }
    
    
    
    func loadChatHistory(for memoryCardId: Int) {
        let histories = ChatHistoryManager.shared.loadChatHistories()
        print("Loaded \(histories.count) chat histories")
        if let history = histories.first(where: { $0.id == memoryCardId }) {
            self.chatHistory = history.messages
            print("Found chat history for memory card \(memoryCardId) with \(history.messages.count) messages")
        } else {
            self.chatHistory = []
            print("No chat history found for memory card \(memoryCardId)")
        }
        print("Loaded \(self.chatHistory.count) chat messages for memory card \(memoryCardId)")
    }
    
    func getRepresentativeUserMessage() -> String {
        let userMessages = chatHistory.filter { $0.role == "user" }
        if let longestMessage = userMessages.max(by: { $0.content.count < $1.content.count }) {
            return longestMessage.content
        }
        return "아직 대화 내용이 없습니다."
    }
    
}



