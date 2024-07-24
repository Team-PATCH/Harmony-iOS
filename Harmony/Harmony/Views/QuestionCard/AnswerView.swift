//
//  AnswerView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

import SwiftUI

struct AnswerView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var answerText = ""
    @State private var navigateToDetail = false
    
    var body: some View {
        AnswerCommonView(
            questionIndex: viewModel.currentQuestion?.id ?? 0,
            question: viewModel.currentQuestion?.question ?? "",
            answeredAt: nil,
            answerText: $answerText,
            buttonText: "답변 완료",
            onSubmit: {
                Task {
                    await viewModel.postAnswer(questionId: questionId, answer: answerText)
                    navigateToDetail = true
                }
            }
        )
        .navigationDestination(isPresented: $navigateToDetail) {
            QuestionDetailView(viewModel: viewModel, questionId: questionId)
        }
        .task {
            await viewModel.fetchCurrentQuestion(groupId: 1)
        }
    }
}

struct AnswerCommonView: View {
    let questionIndex: Int
    let question: String
    let answeredAt: Date?
    @Binding var answerText: String
    let buttonText: String
    let onSubmit: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.wh.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        questionSection
                        
                        textEditorSection(height: geometry.size.height * 0.6)
                        
                        submitButton
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("#\(questionIndex)번째 질문")
                .font(.pretendardMedium(size: 18))
                .foregroundColor(.green)
                .padding(.bottom)
            Text(question)
                .font(.pretendardSemiBold(size: 24))
                .foregroundColor(.black)
                .padding(.bottom, 10)
            if let date = answeredAt {
                Text(formatDate(date))
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 10)
    }
    
    private func textEditorSection(height: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            CustomTextEditor(text: $answerText,
                             backgroundColor: UIColor(Color.gray1), placeholder: "여정님의 답변을 알려주세요.")
            .frame(height: height)
            .cornerRadius(8)
        }
        .background(Color.gray1)
        .cornerRadius(10)
    }
    
    private var submitButton: some View {
        Button(action: onSubmit) {
            Text(buttonText)
                .font(.pretendardSemiBold(size: 24))
                .frame(maxWidth: .infinity)
                .padding()
                .background(answerText.isEmpty ? Color.gray2 : Color.mainGreen)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(answerText.isEmpty)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}



// MARK: - Preview
#Preview {
    NavigationView {
        AnswerView(viewModel: QuestionViewModel(mockData: true), questionId: 1)
    }
}
