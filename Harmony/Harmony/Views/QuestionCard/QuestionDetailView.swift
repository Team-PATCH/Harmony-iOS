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
    @State private var isVIP: Bool = false
    @State private var commentToEdit: Comment?
    
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
                        .foregroundColor(isVIP ? .black : .gray) // 변경: VIP 여부에 따라 색상 변경
                }
                .disabled(!isVIP)  // 추가: VIP가 아닌 경우 버튼 비활성화
            }
        }
        .sheet(isPresented: $showingCommentModal) {
                    CommentModalView(viewModel: viewModel, questionId: questionId, commentToEdit: commentToEdit)
                        .presentationDetents([.medium])
                }
                .task {
                    await viewModel.fetchQuestionDetail(questionId: questionId)
                    await viewModel.fetchComments(questionId: questionId)
                }
                .onAppear {
                    isVIP = UserDefaultsManager.shared.isVIP()
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
                CommentView(viewModel: viewModel, comment: comment)
            }
        }
        .padding()
        .padding(.bottom, 70)
    }
    
    private var addCommentButton: some View {
        Button(action: {
                    // MARK: - 수정: 새 댓글 작성 시 commentToEdit를 nil로 설정
                    commentToEdit = nil
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
    @ObservedObject var viewModel: QuestionViewModel
    let comment: Comment
    @State private var showingOptions = false
    @State private var showingEditModal = false  // 추가: 수정 모달 표시 여부

    init(viewModel: QuestionViewModel, comment: Comment) {
            self.viewModel = viewModel
            self.comment = comment
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 20) {
                Image("mock-profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text(comment.authorId)
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.gray5)
                }
                .frame(height: 40, alignment: .center)
                
                Spacer()

                Button(action: {
                    showingOptions = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .actionSheet(isPresented: $showingOptions) {
                    ActionSheet(title: Text("댓글 옵션"), buttons: [
                        .default(Text("수정")) {
                            showingEditModal = true  // 수정: 수정 모달 표시
                        },
                        .destructive(Text("삭제")) {
                            Task {
                                await viewModel.deleteComment(commentId: comment.id)
                            }
                        },
                        .cancel()
                    ])
                }
            }
            
            Text(comment.content)
                .font(.pretendardMedium(size: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .sheet(isPresented: $showingEditModal) {
            // 추가: 수정 모달 표시
            CommentModalView(viewModel: viewModel, questionId: comment.questionId, commentToEdit: comment)
                .presentationDetents([.medium])
        }
    }
}

struct CommentModalView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    let commentToEdit: Comment?  // 수정할 댓글 (없으면 새 댓글 작성)
    @State private var commentText: String
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: QuestionViewModel, questionId: Int, commentToEdit: Comment? = nil) {
        self.viewModel = viewModel
        self.questionId = questionId
        self.commentToEdit = commentToEdit
        _commentText = State(initialValue: commentToEdit?.content ?? "")
    }
    
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
                    
                    Button(commentToEdit == nil ? "작성 완료" : "수정 완료") {
                        Task {
                            if let comment = commentToEdit {
                                // 댓글 수정
                                await viewModel.updateComment(commentId: comment.id, content: commentText)
                            } else {
                                // 새 댓글 작성
                                await viewModel.postComment(
                                    questionId: questionId,
                                    groupId: viewModel.selectedQuestion?.groupId ?? 0,
                                    content: commentText
                                )
                            }
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
            .navigationTitle(commentToEdit == nil ? "댓글 남기기" : "댓글 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(commentToEdit == nil ? "댓글 남기기" : "댓글 수정")
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

