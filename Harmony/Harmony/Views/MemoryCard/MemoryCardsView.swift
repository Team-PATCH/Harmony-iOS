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
        GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(viewModel.filteredMemoryCards) { card in
                            NavigationLink(destination: MemoryCardDetailView(memoryCardId: card.id)) {
                                MemoryCardView(card: card, viewModel: viewModel)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.horizontal, -15)
                                    .padding(.bottom, -15)
                            }
                        }
                    }
                    .padding([.horizontal, .top])
                    .background(Color.gray1)
                }
                .background(Color.gray1)
                .navigationBarHidden(true)
                .onAppear {
                    if !viewModel.hasLoaded {
                        viewModel.loadMemoryCards()
                    }
                }
            }
            .background(Color.gray1.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    MemoryCardsView()
}


