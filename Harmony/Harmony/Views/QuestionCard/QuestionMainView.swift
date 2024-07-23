//
//  QuestionMainView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

import SwiftUI

import SwiftUI

struct QuestionMainView: View {
    @StateObject var viewModel = QuestionViewModel()
    let userNick = "여정"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        if let currentQuestion = viewModel.currentQuestion {
                            VStack {
                                CurrentQuestionBox(question: currentQuestion, viewModel: viewModel)
                            }
                            .padding()
                            .background(Color.wh)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.gray1)
                    
                    RecentQuestionsSection(viewModel: viewModel)
                        .background(Color.white)
                }
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("오늘의 ")
                            .font(.system(size: 24, weight: .bold))
                        + Text("질문")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.mainGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, -1)
                    .padding(.bottom)
                }
            }
        }
        .task {
            await viewModel.fetchCurrentQuestion(groupId: 1)
            await viewModel.fetchRecentQuestions(groupId: 1)
        }
    }
}

struct CurrentQuestionBox: View {
    let question: Question
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("#\(question.id)")
                .font(.pretendardSemiBold(size: 18))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text(question.question)
                .font(.pretendardSemiBold(size: 24))
            NavigationLink(destination: AnswerView(viewModel: viewModel, questionId: question.id)) {
                HStack {
                    Text("답변하러 가기")
                    Image("qc-right-arrow")
                }
                .font(.pretendardSemiBold(size: 20))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.mainGreen)
                .cornerRadius(999)
            }
        }
    }
}

struct RecentQuestionsSection: View {
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("주고받은 질문들")
                    .font(.pretendardMedium(size: 22))
                    .padding(.bottom, 10)
                Spacer()
                NavigationLink(destination: QuestionListView(viewModel: viewModel)) {
                    Text("전체보기")
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.mainGreen)
                }
            }
            .padding()
            .background(Color.white)
            
            VStack(spacing: 10) {
                ForEach(viewModel.recentQuestions) { question in
                    QuestionBox(question: question, viewModel: viewModel)
                }
                .font(.pretendardSemiBold(size: 20))
                .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.white)
    }
}

struct QuestionBox: View {
    let question: Question
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        NavigationLink(destination: QuestionDetailView(viewModel: viewModel, questionId: question.id)) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question)
                        .font(.pretendardBold(size: 20))
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
struct QuestionMainView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionMainView(viewModel: QuestionViewModel(mockData: true))
    }
}
