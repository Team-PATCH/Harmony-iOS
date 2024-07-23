//
//  QuestionCardViewModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/23/24.
//

import Foundation
import Alamofire

//@MainActor
//class QuestionViewModel: ObservableObject {
//    @Published var currentQuestion: Question?
//    @Published var provideQuestion: ProvideQuestion?
//    @Published var recentQuestions: [Question] = []
//    @Published var allQuestions: [Question] = []
//    @Published var selectedQuestion: Question?
//    @Published var comments: [Comment] = []
//
//    func fetchProvideQuestion() async {
//        do {
//            let question: ProvideQuestion = try await QuestionCardService.shared.fetchData(endpoint: "/providequestion")
//            self.provideQuestion = question
//        } catch {
//            print("Error fetching provide question: \(error)")
//        }
//    }
//
//    func fetchRecentQuestions(groupId: Int) async {
//        do {
//            let questions: [Question] = try await QuestionCardService.shared.fetchData(endpoint: "/questions/\(groupId)")
//            self.recentQuestions = questions
//        } catch {
//            print("Error fetching recent questions: \(error)")
//        }
//    }
//
//    func fetchAllQuestions(groupId: Int) async {
//        do {
//            let questions: [Question] = try await QuestionCardService.shared.fetchData(endpoint: "/allquestions/\(groupId)")
//            self.allQuestions = questions
//        } catch {
//            print("Error fetching all questions: \(error)")
//        }
//    }
//
//    func fetchQuestionDetail(questionId: Int) async {
//        do {
//            let question: Question = try await QuestionCardService.shared.fetchData(endpoint: "/question/\(questionId)")
//            self.selectedQuestion = question
//        } catch {
//            print("Error fetching question detail: \(error)")
//        }
//    }
//
//    func postAnswer(questionId: Int, answer: String) async {
//        do {
//            let parameters: [String: Any] = ["answer": answer]
//            let updatedQuestion: Question = try await QuestionCardService.shared.postData(endpoint: "/answer/\(questionId)", parameters: parameters)
//            self.selectedQuestion = updatedQuestion
//            if let index = self.allQuestions.firstIndex(where: { $0.id == questionId }) {
//                self.allQuestions[index] = updatedQuestion
//            }
//        } catch {
//            print("Error posting answer: \(error)")
//        }
//    }
//
//    func fetchComments(questionId: Int) async {
//        do {
//            let fetchedComments: [Comment] = try await QuestionCardService.shared.fetchData(endpoint: "/comments/\(questionId)")
//            self.comments = fetchedComments
//        } catch {
//            print("Error fetching comments: \(error)")
//        }
//    }
//
//    func postComment(questionId: Int, content: String) async {
//        do {
//            let parameters: [String: Any] = ["questionId": questionId, "content": content]
//            let newComment: Comment = try await QuestionCardService.shared.postData(endpoint: "/comment", parameters: parameters)
//            self.comments.append(newComment)
//        } catch {
//            print("Error posting comment: \(error)")
//        }
//    }
//
//    func fetchCurrentQuestion(groupId: Int) async {
//        do {
//            let question: Question = try await QuestionCardService.shared.fetchData(endpoint: "/currentquestion/\(groupId)")
//            self.currentQuestion = question
//        } catch {
//            print("Error fetching current question: \(error)")
//        }
//    }
//
//    func updateAnswer(questionId: Int, answer: String) async {
//        do {
//            let parameters: [String: Any] = ["answer": answer]
//            let updatedQuestion: Question = try await QuestionCardService.shared.postData(endpoint: "/updateanswer/\(questionId)", parameters: parameters)
//            self.selectedQuestion = updatedQuestion
//            if let index = self.allQuestions.firstIndex(where: { $0.id == questionId }) {
//                self.allQuestions[index] = updatedQuestion
//            }
//        } catch {
//            print("Error updating answer: \(error)")
//        }
//    }
//}
//
//
//extension QuestionViewModel {
//    func fetchQuestion(id: Int) async {
//        do {
//            let question: Question = try await QuestionCardService.shared.fetchData(endpoint: "/question/\(id)")
//            self.selectedQuestion = question
//        } catch {
//            print("Error fetching question: \(error)")
//        }
//    }
//}



// MARK: Mock Data
class QuestionViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var recentQuestions: [Question] = []
    @Published var allQuestions: [Question] = []
    @Published var selectedQuestion: Question?
    @Published var comments: [Comment] = []
    
    private var mockData: Bool
    
    init(mockData: Bool = false) {
        self.mockData = mockData
        if mockData {
            setupMockData()
        }
    }
    
    private func setupMockData() {
        let now = Date()
        
        // 현재 질문
        currentQuestion = Question(
            id: 1,
            groupId: 1,
            question: "오늘 가장 감사했던 순간은 언제인가요?",
            answer: "매순간이 감사하지~~~ 지혜가 문자보냈을때 너무 좋았어!!!",
            createdAt: now.addingTimeInterval(-86400),
            answeredAt: now.addingTimeInterval(-43200),
            updatedAt: now.addingTimeInterval(-43200)
        )
        
        // 최근 질문들
        recentQuestions = [
            Question(
                id: 1,
                groupId: 1,
                question: "어제 먹은 음식 중 가장 맛있었던 것은?",
                answer: "어제 먹은 파스타가 정말 맛있었어요.",
                createdAt: now.addingTimeInterval(-86400),
                answeredAt: now.addingTimeInterval(-43200),
                updatedAt: now.addingTimeInterval(-43200)
            ),
            Question(
                id: 2,
                groupId: 1,
                question: "최근에 본 영화 중 추천하고 싶은 작품이 있나요?",
                answer: "인셉션을 다시 봤는데, 여전히 훌륭한 영화더라구요.",
                createdAt: now.addingTimeInterval(-172800),
                answeredAt: now.addingTimeInterval(-86400),
                updatedAt: now.addingTimeInterval(-86400)
            ),
            Question(
                id: 3,
                groupId: 1,
                question: "올해의 목표는 무엇인가요?",
                answer: "규칙적인 운동 습관을 들이는 것이 목표예요.",
                createdAt: now.addingTimeInterval(-259200),
                answeredAt: now.addingTimeInterval(-172800),
                updatedAt: now.addingTimeInterval(-172800)
            )
        ]
        
        // 모든 질문들
        allQuestions = recentQuestions + [
            Question(
                id: 4,
                groupId: 1,
                question: "가장 좋아하는 계절은 언제인가요?",
                answer: "저는 선선한 가을이 가장 좋아요.",
                createdAt: now.addingTimeInterval(-345600),
                answeredAt: now.addingTimeInterval(-259200),
                updatedAt: now.addingTimeInterval(-259200)
            ),
            Question(
                id: 5,
                groupId: 1,
                question: "최근에 새로 배운 것이 있다면 무엇인가요?",
                answer: "최근에 기타를 배우기 시작했어요. 아직은 서툴지만 재미있어요.",
                createdAt: now.addingTimeInterval(-432000),
                answeredAt: now.addingTimeInterval(-345600),
                updatedAt: now.addingTimeInterval(-345600)
            )
        ]
        
        // 선택된 질문 (QuestionDetailView용)
        selectedQuestion = allQuestions[0]
        
        // 댓글들
        comments = [
            Comment(id: 1, questionId: 1, groupId: 1, authorId: "User1", content: "파스타 맛있죠! 어떤 종류의 파스타였나요?", createdAt: now.addingTimeInterval(-40000)),
            Comment(id: 2, questionId: 1, groupId: 1, authorId: "User2", content: "저도 파스타를 좋아해요. 집에서 만들어 먹는 것도 좋아요.", createdAt: now.addingTimeInterval(-35000)),
            Comment(id: 3, questionId: 2, groupId: 1, authorId: "User3", content: "인셉션 정말 좋은 영화죠. 놀란 감독의 작품들은 다 훌륭한 것 같아요.", createdAt: now.addingTimeInterval(-80000))
        ]
    }
    
    func fetchCurrentQuestion(groupId: Int) {
        // 실제 구현에서는 API 호출
        if mockData {
            // 이미 setupMockData()에서 설정됨
        }
    }
    
    func fetchRecentQuestions(groupId: Int) {
        // 실제 구현에서는 API 호출
        if mockData {
            // 이미 setupMockData()에서 설정됨
        }
    }
    
    func fetchAllQuestions(groupId: Int) {
        // 실제 구현에서는 API 호출
        if mockData {
            // 이미 setupMockData()에서 설정됨
        }
    }
    
    func fetchQuestionDetail(questionId: Int) {
        // 실제 구현에서는 API 호출
        if mockData {
            selectedQuestion = allQuestions.first { $0.id == questionId }
        }
    }
    
    func fetchComments(questionId: Int) {
        // 실제 구현에서는 API 호출
        if mockData {
            comments = comments.filter { $0.questionId == questionId }
        }
    }
    
    func postAnswer(questionId: Int, answer: String) {
        // 실제 구현에서는 API 호출
        if mockData {
            if let index = allQuestions.firstIndex(where: { $0.id == questionId }) {
                allQuestions[index].answer = answer
                allQuestions[index].answeredAt = Date()
                allQuestions[index].updatedAt = Date()
                if questionId == currentQuestion?.id {
                    currentQuestion?.answer = answer
                    currentQuestion?.answeredAt = Date()
                    currentQuestion?.updatedAt = Date()
                }
            }
        }
    }
    
    func updateAnswer(questionId: Int, answer: String) {
        // 실제 구현에서는 API 호출
        if mockData {
            if let index = allQuestions.firstIndex(where: { $0.id == questionId }) {
                allQuestions[index].answer = answer
                allQuestions[index].updatedAt = Date()
                if questionId == selectedQuestion?.id {
                    selectedQuestion?.answer = answer
                    selectedQuestion?.updatedAt = Date()
                }
            }
        }
    }
    
    func postComment(questionId: Int, content: String) {
        // 실제 구현에서는 API 호출
        if mockData {
            let newComment = Comment(
                id: comments.map { $0.id }.max()! + 1,
                questionId: questionId,
                groupId: 1,
                authorId: "CurrentUser",
                content: content,
                createdAt: Date()
            )
            comments.append(newComment)
        }
    }
}
