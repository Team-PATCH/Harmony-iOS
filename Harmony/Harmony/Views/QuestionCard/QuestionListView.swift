//
//  QuestionListView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

import SwiftUI

struct QuestionListView: View {
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        ZStack {
            Color.wh.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 15) {
                    Divider()
                    ForEach(viewModel.allQuestions) { question in
                        QuestionListBox(question: question, viewModel: viewModel)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        }
        .navigationTitle("주고받은 질문 목록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("주고받은 질문 목록")
                    .font(.pretendardBold(size: 20))
            }
        }
        .task {
            await viewModel.fetchAllQuestions(groupId: 1)
        }
    }
}

struct QuestionListBox: View {
    let question: Question
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        NavigationLink(destination: QuestionDetailView(viewModel: viewModel, questionId: question.id)) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("#\(question.id)")
                        .font(.pretendardSemiBold(size: 18))
                        .foregroundColor(.secondary)
                    
                    Text(question.question)
                        .font(.pretendardSemiBold(size: 20))
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
            .padding()
            .background(Color.gray1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Preview
#Preview {
    NavigationView {
        QuestionListView(viewModel: QuestionViewModel(mockData: true))
    }
}
