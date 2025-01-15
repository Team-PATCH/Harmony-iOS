//
//  MemoryCardsView.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import SwiftUI

struct MemoryCardsView: View {
    @EnvironmentObject var viewModel: MemoryCardViewModel
    @State private var searchText = ""
    @State private var isSearchBarVisible = false
    @State private var isAppeared = false
    @State private var isContentVisible = false
    @State private var appearingCardIndex = 0
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray1)
                } else {
                    VStack(spacing: 0) {
                        // MARK: - 상단 바 요소들
                        VStack(spacing: 0) {
                            if isSearchBarVisible {
                                HStack {
                                    SearchBar(searchText: $searchText) {
                                        viewModel.searchMemoryCards(with: searchText)
                                    }
                                    .padding(.horizontal)
                                    .onChange(of: searchText) { newValue in
                                        viewModel.searchMemoryCards(with: newValue)
                                    }
                                    Button(action: {
                                        withAnimation {
                                            isSearchBarVisible.toggle()
                                            searchText = ""
                                        }
                                        viewModel.searchMemoryCards(with: searchText)
                                        UIApplication.shared.endEditing()
                                    }) {
                                        Text("취소")
                                            .foregroundColor(.mainGreen)
                                    }
                                    .padding(.trailing, 20)
                                }
                                .padding(.top, 10)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .background(.white)
                            } else {
                                HStack {
                                    Text("여정")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.mainGreen) +
                                    Text("님의 추억 저장소")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.black)
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            isSearchBarVisible.toggle()
                                        }
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                                .background(Color.white)
                            }
                        }
                        
                        // 정렬 버튼
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    viewModel.toggleSorting()
                                }
                            }) {
                                HStack {
                                    Text(viewModel.isSortedByNewest ? "최신순" : "오래된순")
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundColor(.mainGreen)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .padding(.top, 5)
                        .background(Color.white)
                        
                        Divider()
                            .background(Color.gray3)
                        
                        // 오류 메시지
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            // MARK: - ScrollView 영역
                            ScrollView {
                                VStack(spacing: 0) {
                                    if let newCard = viewModel.newMemoryCard {
                                        NavigationLink(
                                            destination: MemoryCardDetailView(
                                                memoryCardId: newCard.id,
                                                groupId: newCard.groupId ?? 1
                                            )
                                        ) {
                                            MemoryCardView(card: newCard, viewModel: viewModel)
                                                .padding(.top, 20)
                                        }
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 30) {
                                        ForEach(Array(viewModel.filteredMemoryCards.enumerated()), id: \.element.id) { index, card in
                                            if card != viewModel.newMemoryCard {
                                                NavigationLink(
                                                    destination: MemoryCardDetailView(
                                                        memoryCardId: card.id,
                                                        groupId: card.groupId ?? 1
                                                    )
                                                ) {
                                                    MemoryCardView(card: card, viewModel: viewModel)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .padding(.horizontal, -15)
                                                        .padding(.bottom, -15)
                                                        .opacity(index <= appearingCardIndex ? 1 : 0)
                                                        .offset(y: index <= appearingCardIndex ? 0 : 100)
                                                        .animation(
                                                            .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2)
                                                            .delay(Double(index) * 0.03),
                                                            value: appearingCardIndex
                                                        )
                                                }
                                            }
                                        }
                                    }
                                    .padding([.horizontal, .top])
                                    .background(Color.gray1)
                                }
                                .background(Color.gray1)
                            }
                            .background(Color.gray1)
                        }
                    }
                    .opacity(isContentVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isContentVisible)
                }
            }
            .background(Color.gray1.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .onAppear {
                // 매번 모든 메모리 카드를 로드
                viewModel.isLoading = true
                viewModel.loadMemoryCards()

                withAnimation(.easeInOut(duration: 0.3)) {
                    isContentVisible = true
                }
            }
            .onChange(of: viewModel.isLoading) { isLoading in
                if !isLoading {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isContentVisible = true
                    }
                    animateCards()
                }
            }
        }
    }
    
    // MARK: - 카드 애니메이션
    private func animateCards() {
        let totalCards = viewModel.filteredMemoryCards.count
        for index in 0..<totalCards {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                withAnimation {
                    self.appearingCardIndex = index
                }
            }
        }
    }
}

