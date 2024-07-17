//
//  MemoryCardViewModel.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import Foundation
import Combine
import Alamofire

class MemoryCardViewModel: ObservableObject {
    @Published var memoryCards: [MemoryCard] = []
    @Published var filteredMemoryCards: [MemoryCard] = []
    @Published var memoryCardDetail: MemoryCardDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoaded = false
    @Published var isSortedByNewest = true
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadMemoryCards() {
        isLoading = true
        errorMessage = nil
        hasLoaded = false
        MemoryCardService.shared.fetchMemoryCards { [weak self] cards in
            self?.isLoading = false
            self?.hasLoaded = true
            if let cards = cards {
                self?.memoryCards = cards
                self?.filteredMemoryCards = cards // 초기 데이터 설정
                self?.applySorting()
            } else {
                self?.errorMessage = "추억 카드 목록을 조회하는 데 실패했습니다."
            }
        }
    }
    
    func loadMemoryCardDetail(id: Int) {
        isLoading = true
        errorMessage = nil
        MemoryCardService.shared.fetchMemoryCardDetail(id: id) { [weak self] detail in
            self?.isLoading = false
            if let detail = detail {
                self?.memoryCardDetail = detail
            } else {
                self?.errorMessage = "추억 카드 상세 정보를 조회하는 데 실패했습니다."
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
    
}
