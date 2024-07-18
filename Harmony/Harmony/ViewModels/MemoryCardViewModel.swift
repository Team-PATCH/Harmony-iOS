//
//  MemoryCardViewModel.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import Foundation
import Combine
import Alamofire

final class MemoryCardViewModel: ObservableObject {
    @Published var memoryCards: [MemoryCard] = []
    @Published var filteredMemoryCards: [MemoryCard] = []
    @Published var memoryCardDetail: MemoryCardDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoaded = false
    @Published var isSortedByNewest = true
    
    private var cancellables = Set<AnyCancellable>()
    
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

