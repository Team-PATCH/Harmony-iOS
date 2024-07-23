//
//  AnswerEditView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

import SwiftUI

struct AnswerEditView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var answerText: String
    @State private var navigateToDetail = false
    
    init(viewModel: QuestionViewModel, questionId: Int) {
        self.viewModel = viewModel
        self.questionId = questionId
        _answerText = State(initialValue: viewModel.selectedQuestion?.answer ?? "")
    }
    
    var body: some View {
        NavigationStack {
            AnswerCommonView(
                questionIndex: viewModel.selectedQuestion?.id ?? 0,
                question: viewModel.selectedQuestion?.question ?? "",
                answeredAt: viewModel.selectedQuestion?.answeredAt,
                answerText: $answerText,
                buttonText: "답변 수정",
                onSubmit: {
                    Task {
                        await viewModel.updateAnswer(questionId: questionId, answer: answerText)
                        navigateToDetail = true
                    }
                }
            )
            .navigationDestination(isPresented: $navigateToDetail) {
                QuestionDetailView(viewModel: viewModel, questionId: questionId)
            }
        }
        .task {
            await viewModel.fetchQuestionDetail(questionId: questionId)
        }
    }
}



// MARK: - Preview
#Preview {
    NavigationView {
        AnswerEditView(viewModel: QuestionViewModel(mockData: true), questionId: 1)
    }
}
