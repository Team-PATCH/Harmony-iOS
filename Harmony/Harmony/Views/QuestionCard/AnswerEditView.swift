//
//  AnswerEditView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

/*
import SwiftUI

struct AnswerEditView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var answerText: String
    @State private var navigateToDetail = false
    @State private var isVIP: Bool = false
    
    init(viewModel: QuestionViewModel, questionId: Int) {
        self.viewModel = viewModel
        self.questionId = questionId
        _answerText = State(initialValue: viewModel.selectedQuestion?.answer ?? "")
    }
    
    var body: some View {
        Group {
            if isVIP {
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
            } else {
                Text("VIP 회원만 답변을 수정할 수 있습니다.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .task {
            await viewModel.fetchQuestionDetail(questionId: questionId)
        }
        .onAppear {
            isVIP = UserDefaultsManager.shared.isVIP()
        }
    }
}
*/


// MARK: - Preview
//#Preview {
//    NavigationView {
//        AnswerEditView(viewModel: QuestionViewModel(mockData: true), questionId: 1)
//    }
//}


import SwiftUI

struct AnswerEditView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var answerText: String
    @State private var navigateToDetail = false
    @State private var isVIP: Bool = false
    
    init(viewModel: QuestionViewModel, questionId: Int) {
        self.viewModel = viewModel
        self.questionId = questionId
        _answerText = State(initialValue: viewModel.selectedQuestion?.answer ?? "")
    }
    
    var body: some View {
        Group {
            if isVIP {
                NavigationStack {
                    AnswerCommonView(
                        questionIndex: viewModel.selectedQuestion?.id ?? 0,
                        question: viewModel.selectedQuestion?.question ?? "",
                        answeredAt: viewModel.selectedQuestion?.answeredAt,
                        questionId: questionId,
                        initialAnswer: viewModel.selectedQuestion?.answer ?? "",
                        onSubmit: { updatedAnswer in
                            Task {
                                await viewModel.updateAnswer(questionId: questionId, answer: updatedAnswer)
                                navigateToDetail = true
                            }
                        }
                    )
                    .navigationDestination(isPresented: $navigateToDetail) {
                        QuestionDetailView(viewModel: viewModel, questionId: questionId)
                    }
                }
            } else {
                Text("VIP 회원만 답변을 수정할 수 있습니다.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .task {
            await viewModel.fetchQuestionDetail(questionId: questionId)
        }
        .onAppear {
            isVIP = UserDefaultsManager.shared.isVIP()
        }
    }
}
