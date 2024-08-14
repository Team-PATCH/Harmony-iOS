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
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                if let url = URL(string: card.image), !card.image.isEmpty {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 120)
                        .clipped()
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 120)
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(card.title)
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.black)
                    Text(FormatManager.shared.formattedDate(from: card.dateTime))
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                }
                .padding([.horizontal, .bottom])
            }
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray3, lineWidth: 0.5)
            )
        }
        .padding(.horizontal)
        .frame(height: 200)
        .frame(maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    MemoryCardView(card: MemoryCard(id: 1, title: "Sample Title", dateTime: "2024-01-01T12:00:00Z", image: "", groupId: 1), viewModel: MemoryCardViewModel())
}

let dummyMemoryCard = MemoryCard(id: 1, title: "더미", dateTime: "2024-08-04T13:21:08.000Z", image: "https://cdn.eyesmag.com/content/uploads/posts/2022/09/07/main-b40b2d5d-2d99-4734-80af-9fd4ac428fb4.jpg")

let dummyViewModel = MemoryCardViewModel()
