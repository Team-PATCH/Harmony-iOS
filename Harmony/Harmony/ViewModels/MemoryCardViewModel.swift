//
//  MemoryCardViewModel.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

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
    @Published var initialPrompt: String = ""
    @Published var summary: String = ""
    @Published var isSummaryLoading: Bool = false
    @Published var isSummaryLoaded: Bool = false


    
    private var cancellables = Set<AnyCancellable>()
    
    func getSummary(for memoryCardId: Int, force: Bool = false) {
        if !force && isSummaryLoaded {
            return // 이미 로드된 경우 중복 요청 방지
        }
        
        isSummaryLoading = true
        MemoryCardService.shared.getSummary(mcId: memoryCardId, forceUpdate: force)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isSummaryLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
                self?.isSummaryLoaded = true
            }, receiveValue: { [weak self] summary in
                self?.summary = summary
            })
            .store(in: &cancellables)
    }
    
    // 채팅 기록 업데이트 후 요약 갱신
    func updateSummaryAfterChat(for memoryCardId: Int) {
        getSummary(for: memoryCardId, force: true)
    }
    
    func loadInitialPrompt(for memoryCardId: Int) {
        isLoading = true
        MemoryCardService.shared.getInitialPrompt(mcId: memoryCardId)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                print("이니셜 프롬프트 메서드 진입")
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("이니셜 프롬프트 로드 실패")
                }
            }, receiveValue: { [weak self] prompt in
                self?.initialPrompt = prompt
                print("이니셜 프롬프트 receiveValue")
            })
            .store(in: &cancellables)
    }
    
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
    
    private func date(from dateTime: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateTime) ?? Date.distantPast
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



