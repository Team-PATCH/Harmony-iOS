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
                    KFImage(URL(string: "https://cdn.eyesmag.com/content/uploads/posts/2022/09/07/main-b40b2d5d-2d99-4734-80af-9fd4ac428fb4.jpg"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 200)
                        .clipped()
                }
                
                Text(memoryCardDetail.title)
                    .font(.largeTitle)
                    .bold()
                    .padding([.top, .horizontal])
                    .multilineTextAlignment(.center)
                
                Text(formattedDateTime(from: memoryCardDetail.dateTime))
                    .font(.subheadline)
                HStack {
                    ForEach(memoryCardDetail.tag, id: \.self) { tag in
                        Text(tag)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
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
                NavigationLink(destination: Text("이어서 대화하기 뷰")) {
                    Text("이어서 대화하기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: MemoryChatView(messages: dummyChatMessages)) {
                    Text("대화 전체 보기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
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
