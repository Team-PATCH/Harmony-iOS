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
    var groupId: Int
    @StateObject var viewModel = MemoryCardViewModel()
    @State private var showingActionSheet = false
    @State private var shouldRefreshSummary = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else if let memoryCardDetail = viewModel.memoryCardDetail {
                VStack(spacing: 0) {
                    // Image section
                    if let memoryCard = viewModel.memoryCard {
                        KFImage(URL(string: memoryCard.image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray2)
                            .frame(height: 300)
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
                        if viewModel.isSummaryLoading {
                            ProgressView("모니가 대화를 요약하고 있어요☺️")
                                .padding()
                        } else if !viewModel.summary.isEmpty {
                            Text(viewModel.summary)
                                .font(.body)
                                .foregroundColor(.bl)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray1)
                                .cornerRadius(16)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        } else {
                            Text("아직 이 추억에 대해 대화를 나누지 않았네요, 모니와 대화를 시작해보세요!😄")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.gray1)
                                .cornerRadius(16)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                    }
                    .background(Color.wh)
                    
                    Spacer()
                    
                    // Button section
                    NavigationLink(destination: ChatHistoryView(memoryCardId: memoryCardId, groupId: groupId, shouldRefreshSummary: $shouldRefreshSummary, memoryCardViewModel: viewModel)) {
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
        .onChange(of: shouldRefreshSummary) { newValue in
            if newValue {
                viewModel.getSummary(for: memoryCardId, force: true)
                shouldRefreshSummary = false
            }
        }
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
            viewModel.getSummary(for: memoryCardId)
        }
    }
}



#Preview {
    MemoryCardDetailView(memoryCardId: 1, groupId: 1)
}
