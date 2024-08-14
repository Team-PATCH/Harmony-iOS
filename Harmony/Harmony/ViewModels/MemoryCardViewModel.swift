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
    @Published var lastMessageId: Int?
    @Published var lastSummarizedMessageId: Int?
    @Published var hasMemoryCard: Bool = false
    @Published var memoryCardImage: UIImage? = nil
    @Published var newMemoryCard: MemoryCard? {
        didSet {
            print("newMemoryCard 설정됨: \(String(describing: newMemoryCard))")
        }
    }
    @Published var showNewMemoryCardNotification: Bool = false



    
    private var cancellables = Set<AnyCancellable>()
    
    func refreshSummary(for memoryCardId: Int) {
        getSummary(for: memoryCardId, force: true)
    }
    
    func getSummary(for memoryCardId: Int, force: Bool = false) {
        if !force && isSummaryLoaded && !summary.isEmpty && lastSummarizedMessageId == lastMessageId {
            return // 이미 로드되었고 요약이 있으며 새 메시지가 없는 경우 중복 요청 방지
        }
        
        isSummaryLoading = true
        MemoryCardService.shared.getSummary(mcId: memoryCardId, forceUpdate: force)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isSummaryLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
                self?.isSummaryLoaded = true
            }, receiveValue: { [weak self] summaryData in
                if self?.lastSummarizedMessageId != summaryData.lastMessageId {
                    self?.summary = summaryData.summary
                    self?.lastMessageId = summaryData.lastMessageId
                    self?.lastSummarizedMessageId = summaryData.lastMessageId
                }
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
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    self?.isLoading = false
                    self?.hasLoaded = true
                case .failure(let error):
                    self?.errorMessage = "추억 카드 목록을 조회하는 데 실패했습니다: \(error.localizedDescription)"
                    self?.isLoading = false
                    self?.hasLoaded = true
                }
            }, receiveValue: { [weak self] cards in
                self?.memoryCards = cards
                self?.filteredMemoryCards = cards
                self?.applySorting()
                self?.isLoading = false
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
    
    
    func loadLatestMemoryCard() {
        print("loadLatestMemoryCard 호출됨")
        MemoryCardService.shared.fetchMemoryCards()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        print("메모리 카드 로드 완료")
                    case .failure(let error):
                        print("메모리 카드 로드 실패: \(error)")
                }
            } receiveValue: { [weak self] cards in
                if let latestCard = cards.first {
                    self?.newMemoryCard = latestCard
                    print("최신 메모리 카드 로드됨: \(latestCard)")
                } else {
                    print("메모리 카드를 찾을 수 없음")
                }
            }
            .store(in: &cancellables)
    }
    
    func setNewMemoryCard(_ card: MemoryCard) {
        DispatchQueue.main.async {
            self.newMemoryCard = card
            print("새 메모리 카드 설정: \(card)")
        }
    }
    
    
    func createMemoryCard(groupId: Int, title: String, date: Date, image: UIImage, completion: @escaping (Result<MemoryCardData, Error>) -> Void) {
        isLoading = true
        let serverDateFormatter = DateFormatter()
        serverDateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = serverDateFormatter.string(from: date)
        
        MemoryCardService.shared.createMemoryCard(groupId: groupId, title: title, year: formattedDate, image: image)
            .sink(receiveCompletion: { [weak self] completionResult in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch completionResult {
                        case .finished:
                            break
                        case .failure(let error):
                            self?.errorMessage = "메모리 카드 생성 실패: \(error.localizedDescription)"
                            completion(.failure(error))
                    }
                }
            }, receiveValue: { [weak self] memoryCardData in
                DispatchQueue.main.async {
                    let newCard = MemoryCard(id: memoryCardData.memorycardId,
                                             title: memoryCardData.title,
                                             dateTime: memoryCardData.dateTime,
                                             image: memoryCardData.image,
                                             groupId: groupId)
                    self?.setNewMemoryCard(newCard)
                    completion(.success(memoryCardData))
                }
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



