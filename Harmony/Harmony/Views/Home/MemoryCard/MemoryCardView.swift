//
//  MemoryCardView.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import SwiftUI
import Kingfisher

// MARK: - 그리드 목록에 보이는 개별 메모리 카드 뷰입니다.

struct MemoryCardView: View {
    let card: MemoryCard
    let viewModel: MemoryCardViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.gray.opacity(0.1))
                .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    if let url = URL(string: "https://cdn.eyesmag.com/content/uploads/posts/2022/09/07/main-b40b2d5d-2d99-4734-80af-9fd4ac428fb4.jpg"), !card.image.isEmpty {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 120) // 고정 너비와 높이 설정
                            .clipped()
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                    } else {
                        Rectangle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 120) // 고정 너비와 높이 설정
                            .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))
                    }
                }
                
                Text(card.title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
                    .padding([.leading, .bottom], 10)
//                    .frame(maxHeight: .infinity)
                Text(formattedDate(from: card.dateTime))
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .padding([.leading, .bottom], 10)
//                    .frame(maxHeight: .infinity)
            }
        }
        .background(.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        .frame(width: UIScreen.main.bounds.width / 2 - 30) // 고정 너비 및 높이 설정
        .frame(maxHeight: .infinity)
    }
}


//#Preview {
//    MemoryCardView(card: dummyMemoryCard, viewModel: dummyViewModel)
//}

let dummyMemoryCard = MemoryCard(id: 1, title: "더미", dateTime: "날짜", image: "업ㄷㅅ어")

let dummyViewModel = MemoryCardViewModel()
