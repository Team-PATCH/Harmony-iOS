//
//  QuestionDetailView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

import SwiftUI

struct QuestionDetailView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var showingCommentModal = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    Divider()
                    VStack(alignment: .leading, spacing: 20) {
                        questionSection
                        answerSection
                    }
                    .padding()
                    .background(Color.white)
                    
                    commentsSection
                        .background(Color.gray1)
                }
            }
            .background(Color.gray1)
            
            addCommentButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AnswerEditView(viewModel: viewModel, questionId: questionId)) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingCommentModal) {
            CommentModalView(viewModel: viewModel, questionId: questionId)
                .presentationDetents([.medium])
        }
        .task {
            await viewModel.fetchQuestionDetail(questionId: questionId)
            await viewModel.fetchComments(questionId: questionId)
        }
    }
    
    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(viewModel.selectedQuestion?.id ?? 0)번째 질문")
                .font(.pretendardMedium(size: 18))
                .foregroundColor(.mainGreen)
                .padding(.bottom)
            Text(viewModel.selectedQuestion?.question ?? "")
                .font(.pretendardSemiBold(size: 24))
            if let date = viewModel.selectedQuestion?.createdAt {
                Text(formatDate(date))
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
        }
    }
    
    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let answer = viewModel.selectedQuestion?.answer {
                Text(answer)
                    .padding()
                    .font(.pretendardMedium(size: 20))
                    .foregroundColor(.gray5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray1)
                    .cornerRadius(10)
                    .padding(.bottom)
            }
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("댓글")
                Text("\(viewModel.comments.count)")
            }
            .font(.pretendardMedium(size: 18))
            .foregroundColor(.gray5)
            
            ForEach(viewModel.comments) { comment in
                CommentView(comment: comment)
            }
        }
        .padding()
        .padding(.bottom, 70)
    }
    
    private var addCommentButton: some View {
        Button(action: {
            showingCommentModal = true
        }) {
            Text("댓글 남기기")
                .font(.pretendardSemiBold(size: 22))
                .padding(.horizontal, 20)
                .padding(.vertical,20)
                .frame(maxWidth: .infinity)
                .background(Color.mainGreen)
                .foregroundColor(.white)
                .cornerRadius(999)
        }
        .padding(.horizontal, 100)
        .padding(.bottom, 20)
        .background(Color.gray1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 20) {
                Image("mock-profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40) // 이미지 크기 조절
                
                VStack(alignment: .leading) {
                    Text(comment.authorId)
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.gray5)
                }
                .frame(height: 40, alignment: .center) // 이미지 높이와 동일하게 설정
                
                Spacer()
            }
            
            Text(comment.content)
                .font(.pretendardMedium(size: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

struct CommentModalView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var commentText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack {
                    CustomTextEditor(text: $commentText,
                                     backgroundColor: UIColor(Color.gray1),
                                     textColor: .black,
                                     font: .pretendardMedium(size: 18),
                                     placeholder: "댓글을 입력해주세요",
                                     maxLength: 200)
                    .frame(height: 250)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Button("작성 완료") {
                        Task {
                            await viewModel.postComment(
                                questionId: questionId,
                                groupId: viewModel.selectedQuestion?.groupId ?? 0,
                                content: commentText
                            )
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(commentText.isEmpty ? Color.gray2 : Color.mainGreen)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding()
                    .disabled(commentText.isEmpty)
                }
            }
            .navigationTitle("댓글 남기기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("댓글 남기기")
                        .font(.pretendardSemiBold(size: 20))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}



// MARK: - Preview
//#Preview {
//    NavigationView {
//        QuestionDetailView(viewModel: QuestionViewModel(mockData: true), questionId: 1)
//    }
//}

