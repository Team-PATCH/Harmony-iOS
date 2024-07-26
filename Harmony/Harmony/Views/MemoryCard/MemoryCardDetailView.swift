//
//  MemoryCardDetailView.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import SwiftUI
import Kingfisher

struct MemoryCardDetailView: View {
    var memoryCardId: Int
    @StateObject var viewModel = MemoryCardViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if viewModel.isLoading {
                ProgressView("상세 정보를 불러오고 있어요🥹")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else if let memoryCardDetail = viewModel.memoryCardDetail {
                
                HStack {
                    if let memoryCard = viewModel.memoryCard {
                        
                        KFImage(URL(string: memoryCard.image))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 200)
                            .clipped()
                            .cornerRadius(10, corners: [.topLeft, .topRight])
                    }
                }
                
                Text(memoryCardDetail.title)
                    .font(.largeTitle)
                    .bold()
                    .padding([.top, .horizontal])
                    .multilineTextAlignment(.center)
                
                Text(FormatManager.shared.formattedDateTime(from: memoryCardDetail.dateTime))
                    .font(.subheadline)
                HStack {
                    ForEach(memoryCardDetail.tag, id: \.self) { tag in
                        Text(tag)
                            .padding(8)
                            .background(.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                
                Text(memoryCardDetail.description)
                    .font(.body)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
                
                
            } else {
                Text("카드를 불러오는 중이에요🥹")
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: 1)) {
                    Text("이어서 대화하기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: MemoryChatView(messages: dummyChatMessages)) {
                    Text("대화 전체 보기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.green)
                        .cornerRadius(10)
                }
            }
            .padding([.top, .horizontal])
            
        }
        .padding()
        .navigationTitle("너무 멋지고 특별한 추억")
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
        }
    }
}

#Preview {
    MemoryCardDetailView(memoryCardId: 1)
}
