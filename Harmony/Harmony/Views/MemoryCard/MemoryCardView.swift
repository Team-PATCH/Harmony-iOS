//
//  MemoryCardView.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

// MARK: - 그리드 목록에 보이는 개별 메모리 카드 뷰입니다.


import SwiftUI
import Kingfisher

struct MemoryCardView: View {
    let card: MemoryCard
    let viewModel: MemoryCardViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topTrailing) {
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

                    // "새로운 추억" 캡슐 추가
                    if viewModel.newMemoryCard == card {
                        Text("새로운 추억")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.mainGreen)
                            .cornerRadius(15)
                            .offset(x: -10, y: 10)  // 위치 조정
                    }
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


