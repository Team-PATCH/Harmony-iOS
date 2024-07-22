//
//  GetMemoryCardsView.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import SwiftUI

struct MemoryCardsView: View {
    @StateObject private var viewModel = MemoryCardViewModel()
    @State private var searchText = ""
    @State private var isSearchBarVisible = false
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if isSearchBarVisible { // SearchBar가 표시될 때
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
                                HStack{
                                    Text("취소")
                                        .foregroundColor(.mainGreen)
                                }
                                .padding(.trailing, 20)
                                .padding(.leading, -17)
                            }
                        }
                        .padding(.top, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else { // 기본 상태
                        HStack {
                            Text("여정")
                                .font(.title)
                                .bold()
                                .foregroundColor(Color.mainGreen) +
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
                    }
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
                }
                .background(.white)
                
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(viewModel.filteredMemoryCards) { card in
                            NavigationLink(destination: MemoryCardDetailView(memoryCardId: card.id)) {
                                MemoryCardView(card: card, viewModel: viewModel)
                                    .frame(maxWidth: 100)
                            }
                        }
                    }
                    .padding([.horizontal, .top])
                }
                .background(Color.gray1)
                .navigationBarHidden(true)
                .onAppear {
                    if !viewModel.hasLoaded {
                        viewModel.loadMemoryCards()
                    }
                }
            }
        }
    }
}

#Preview {
    MemoryCardsView()
}



