//
//  MemoryCardDetailView.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

/*
import SwiftUI
import Kingfisher

struct MemoryCardDetailView: View {
    var memoryCardId: Int
    var groupId: Int
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
                    ForEach(memoryCardDetail.tags, id: \.self) { tag in
                        Text(tag)
                            .padding(8)
                            .background(.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                Text(viewModel.getRepresentativeUserMessage())
                    .font(.body)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)

                
            } else {
                Text("카드를 불러오는 중이에요🥹")
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId, groupId: viewModel.memoryCardDetail?.groupId ?? 0, previousChatHistory: viewModel.chatHistory)) {
                    Text(viewModel.memoryCardDetail?.description.isEmpty ?? true ? "모니와 대화하기" : "이어서 대화하기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: ChatHistoryView(memoryCardId: memoryCardId, groupId: groupId)) {
                    Text("대화 기록 보기")
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
//        .navigationTitle("추억 카드 상세")
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
        }
    }
}

#Preview {
    MemoryCardDetailView(memoryCardId: 1, groupId: 1)
}
*/

import SwiftUI
import Kingfisher

struct MemoryCardDetailView: View {
    var memoryCardId: Int
    var groupId: Int
    @StateObject var viewModel = MemoryCardViewModel()
    @State private var showingActionSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("상세 정보를 불러오고 있어요🥹")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else if let memoryCardDetail = viewModel.memoryCardDetail {
                VStack(spacing: 0) {
                    // Image section
                    if let memoryCard = viewModel.memoryCard {
                        KFImage(URL(string: memoryCard.image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray2)
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "camera")
                                    .foregroundColor(.gray4)
                                    .font(.system(size: 50))
                            )
                    }
                    
                    // Title and tags section
                    VStack {
                        Text(memoryCardDetail.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.bl)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                        
                        Text(FormatManager.shared.formattedDate(from: memoryCardDetail.dateTime))
                            .font(.headline)
                            .foregroundColor(.gray4)
                            .padding(.bottom, 5)
                        
                        HStack {
                            ForEach(memoryCardDetail.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.subheadline)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.subGreen)
                                    .foregroundColor(.mainGreen)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.bottom, 5)
                    }
                    .padding([.top, .bottom])
                    .frame(maxWidth: .infinity)
                    .background(Color.wh)
                    .multilineTextAlignment(.center)
                    
                    // Gray separator
                    Rectangle()
                        .fill(Color.gray1)
                        .frame(height: 8)
                    
                    // Content section
                    ScrollView {
                        Text(viewModel.getRepresentativeUserMessage())
                            .font(.body)
                            .foregroundColor(.bl)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray1)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    .background(Color.wh)
                    
                    Spacer()
                    
                    // Button section
                    NavigationLink(destination: ChatHistoryView(memoryCardId: memoryCardId, groupId: groupId)) {
                        Text("대화 전체 보기")
                            .font(.headline)
                            .foregroundColor(.wh)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mainGreen)
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.wh)
                }
            } else {
                Text("카드를 불러오는 중이에요🥹")
            }
        }
        .background(Color.wh)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.bl)
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(""), message: Text(""), buttons: [
                .default(Text("다시 대화하기").foregroundColor(.bl)) {
                    // 다시 대화하기 액션
                },
                .destructive(Text("삭제하기").foregroundColor(.subRed)) {
                    // 삭제 액션 (아직 구현되지 않음)
                },
                .cancel(Text("취소").foregroundColor(.gray4))
            ])
        }
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
        }
    }
}

#Preview {
    MemoryCardDetailView(memoryCardId: 1, groupId: 1)
}
