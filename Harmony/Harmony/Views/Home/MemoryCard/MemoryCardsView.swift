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
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("맥도날드님의 추억 저장소")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                
                SearchBar(searchText: $searchText) {
                    viewModel.searchMemoryCards(with: searchText)
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                .onChange(of: searchText) { newValue in
                    viewModel.searchMemoryCards(with: newValue)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            viewModel.toggleSorting()
                        }
                    }) {
                        HStack {
                            Text(viewModel.isSortedByNewest ? "오래된 것부터 보기" : "새로운 것부터 보기")
                            Image(systemName: "chevron.down")
                        }
                    }
                }
                .padding([.horizontal])
                .padding(.bottom, 5)
                
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
                .navigationTitle("")
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

/*
 NavigationStack {
 GeometryReader { geometry in
 VStack {
 HStack {
 Text("맥도날드님의 추억 저장소")
 .font(.title)
 .bold()
 .foregroundColor(.black)
 Spacer()
 }
 .padding()
 
 SearchBar(searchText: $searchText) {
 viewModel.searchMemoryCards(with: searchText)
 }
 .padding(.horizontal)
 .padding(.bottom, 5)
 .onChange(of: searchText) { newValue in
 viewModel.searchMemoryCards(with: newValue)
 }
 
 HStack {
 Spacer()
 Button(action: {
 withAnimation {
 viewModel.toggleSorting()
 }
 }) {
 HStack {
 Text(viewModel.isSortedByNewest ? "오래된 것부터 보기" : "새로운 것부터 보기")
 Image(systemName: "chevron.down")
 }
 }
 }
 .padding([.horizontal])
 .padding(.bottom, 5)
 
 ScrollView {
 LazyVGrid(columns: adaptiveGridItems(width: geometry.size.width), spacing: 30) {
 ForEach(viewModel.filteredMemoryCards) { card in
 NavigationLink(destination: MemoryCardDetailView(memoryCardId: card.id)) {
 MemoryCardView(card: card, viewModel: viewModel)
 .frame(maxWidth: 100)
 .padding(10)
 }
 }
 }
 .padding([.horizontal, .top])
 }
 .navigationTitle("")
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
 */
