//
//  QuestionCardViewModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/23/24.
//

import Foundation
import Alamofire

@MainActor
final class QuestionViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var provideQuestion: ProvideQuestion?
    @Published var recentQuestions: [Question] = []
    @Published var allQuestions: [Question] = []
    @Published var selectedQuestion: Question?
    @Published var comments: [Comment] = []
    
    // 제공된 질문 불러오기
    func fetchProvideQuestion() async {
        do {
            let response: ServerResponse<ProvideQuestion> = try await QuestionCardService.shared.fetchData(endpoint: "/providequestion")
            self.provideQuestion = response.data
        } catch {
            print("Error fetching provide question: \(error)")
        }
    }
    
    // 오늘의 질문 불러오기
    func fetchCurrentQuestion(groupId: Int) async {
        do {
            print("Fetching current question for groupId: \(groupId)")
            let response: ServerResponse<Question> = try await QuestionCardService.shared.fetchData(endpoint: "/currentquestion/\(groupId)")
            print("Server response: \(response)")
            if let question = response.data {
                self.currentQuestion = question
                print("Current question set: \(question)")
                
                // 현재 질문이 설정되었으므로 최근 질문 목록 갱신
                // 답변 여부에 관계없이 항상 갱신하지만, fetchRecentQuestions에서 필터링됨
                await fetchRecentQuestions(groupId: groupId)
            } else {
                print("No question data in response")
            }
        } catch {
            print("Error fetching current question: \(error)")
        }
    }
    
    //최근질문 조회
    func fetchRecentQuestions(groupId: Int) async {
        do {
            print("Fetching recent questions for groupId: \(groupId)")
            // 서버에서 더 많은 질문을 요청 (예: 10개)
            let response: ServerResponse<[Question]> = try await QuestionCardService.shared.fetchData(endpoint: "/questions/\(groupId)?limit=10")
            if let questions = response.data {
                print("Received \(questions.count) questions from server")
                
                // 답변이 있는 질문만 필터링
                var answeredQuestions = questions.filter { $0.answer != nil }
                
                // 현재 질문이 있고 답변이 있다면 포함
                if let currentQuestion = self.currentQuestion,
                   currentQuestion.answer != nil,
                   !answeredQuestions.contains(where: { $0.id == currentQuestion.id }) {
                    answeredQuestions.insert(currentQuestion, at: 0)
                }
                
                // ID 기준으로 내림차순 정렬
                answeredQuestions.sort { $0.id > $1.id }
                
                // 최대 3개의 가장 최근 답변된 질문 선택
                self.recentQuestions = Array(answeredQuestions.prefix(4))
                
                print("Recent questions set: \(self.recentQuestions.map { $0.id })")
                
                // 3개 미만인 경우 추가 로깅
                if self.recentQuestions.count < 3 {
                    print("Warning: Less than 3 recent questions available. Total: \(self.recentQuestions.count)")
                }
            } else {
                print("No questions data in response")
                self.recentQuestions = []
            }
        } catch {
            print("Error fetching recent questions: \(error)")
            self.recentQuestions = []
        }
    }
    
    // 전체 질문목록 조회
    func fetchAllQuestions(groupId: Int) async {
        do {
            let response: ServerResponse<[Question]> = try await QuestionCardService.shared.fetchData(endpoint: "/allquestions/\(groupId)")
            self.allQuestions = response.data ?? []
        } catch {
            print("Error fetching all questions: \(error)")
        }
    }
    
    // 질문카드 상세정보 조회
    func fetchQuestionDetail(questionId: Int) async {
        do {
            let response: ServerResponse<Question> = try await QuestionCardService.shared.fetchData(endpoint: "/question/\(questionId)")
            self.selectedQuestion = response.data
        } catch {
            print("Error fetching question detail: \(error)")
        }
    }
    
    // 질문카드 코멘트 조회
    func fetchComments(questionId: Int) async {
        do {
            let response: ServerResponse<[Comment]> = try await QuestionCardService.shared.fetchData(endpoint: "/comments/\(questionId)")
            self.comments = response.data ?? []
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    // 질문카드 답변 저장
    func postAnswer(questionId: Int, answer: String) async {
        do {
            let parameters: [String: Any] = ["answer": answer]
            let response: ServerResponse<Question> = try await QuestionCardService.shared.postData(endpoint: "/answer/\(questionId)", parameters: parameters)
            if let updatedQuestion = response.data {
                self.selectedQuestion = updatedQuestion
                if let index = self.allQuestions.firstIndex(where: { $0.id == questionId }) {
                    self.allQuestions[index] = updatedQuestion
                }
                
                // 현재 질문 업데이트
                if self.currentQuestion?.id == questionId {
                    self.currentQuestion = updatedQuestion
                }
                
                // RecentQuestions 업데이트
                await fetchRecentQuestions(groupId: updatedQuestion.groupId)
            } else {
                print("Error: Updated question data is nil")
            }
            
            // 답변 후 다음 질문 가져오기
            await fetchNextQuestion()
        } catch {
            print("Error posting answer: \(error)")
        }
    }
        
    func fetchNextQuestion() async {
        do {
            let response: ServerResponse<Question> = try await QuestionCardService.shared.fetchData(endpoint: "/nextquestion")
            self.currentQuestion = response.data
        } catch {
            print("Error fetching next question: \(error)")
        }
    }
    
    // 질문카드 코멘트 저장
    func postComment(questionId: Int, groupId: Int, content: String) async {
        do {
            let authorId = UserDefaultsManager.shared.getNick() ?? "Unknown User"
            
            let parameters: [String: Any] = [
                "questionId": questionId,
                "groupId": groupId,
                "authorId": authorId,
                "content": content
            ]
            let response: ServerResponse<Comment> = try await QuestionCardService.shared.postData(endpoint: "/comment", parameters: parameters)
            if let newComment = response.data {
                self.comments.append(newComment)
            }
        } catch {
            print("Error posting comment: \(error)")
        }
    }
    
    // 질문카드 답변 수정
    func updateAnswer(questionId: Int, answer: String) async {
        do {
            let parameters: [String: Any] = ["answer": answer]
            let response: ServerResponse<Question> = try await QuestionCardService.shared.postData(endpoint: "/updateanswer/\(questionId)", parameters: parameters)
            if let updatedQuestion = response.data {
                self.selectedQuestion = updatedQuestion
                if let index = self.allQuestions.firstIndex(where: { $0.id == questionId }) {
                    self.allQuestions[index] = updatedQuestion
                }
            }
        } catch {
            print("Error updating answer: \(error)")
        }
    }
    
    //질문카드 댓글 수정
    func updateComment(commentId: Int, content: String) async {
        do {
            let parameters: [String: Any] = ["content": content]
            let response: ServerResponse<Comment> = try await QuestionCardService.shared.putData(endpoint: "/comment/\(commentId)", parameters: parameters)
            if response.status == "success", let updatedComment = response.data {
                if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                    self.comments[index] = updatedComment
                }
            } else {
                print("댓글 업데이트 실패: \(response.message)")
            }
        } catch {
            print("Error updating comment: \(error)")
        }
    }

    //질문카드 댓글 삭제
    func deleteComment(commentId: Int) async {
        do {
            let response: ServerResponse<EmptyResponse?> = try await QuestionCardService.shared.deleteData(endpoint: "/comment/\(commentId)")
            if response.status == "success" {
                self.comments.removeAll { $0.id == commentId }
            } else {
                print("댓글 삭제 실패: \(response.message)")
            }
        } catch {
            print("Error deleting comment: \(error)")
        }
    }
}

extension QuestionViewModel {
    var answeredQuestions: [Question] {
        return allQuestions.filter { $0.answer != nil }
    }
}

// MARK: - 서버 응답을 위한 일반화된 구조체
struct ServerResponse<T: Codable>: Codable {
    let status: String
    let message: String
    let data: T?
}

// MARK: - 빈 응답을 위한 구조체
struct EmptyResponse: Codable {}




// MARK: - Mock Data
/*
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
            answeredAt: now.addingTimeInterval(-43200)
            
        )
        
        // 최근 질문들
        recentQuestions = [
            Question(
                id: 1,
                groupId: 1,
                question: "어제 먹은 음식 중 가장 맛있었던 것은?",
                answer: "어제 먹은 파스타가 정말 맛있었어요.",
                createdAt: now.addingTimeInterval(-86400),
                answeredAt: now.addingTimeInterval(-43200)
                
            ),
            Question(
                id: 2,
                groupId: 1,
                question: "최근에 본 영화 중 추천하고 싶은 작품이 있나요?",
                answer: "인셉션을 다시 봤는데, 여전히 훌륭한 영화더라구요.",
                createdAt: now.addingTimeInterval(-172800),
                answeredAt: now.addingTimeInterval(-86400)
                
            ),
            Question(
                id: 3,
                groupId: 1,
                question: "올해의 목표는 무엇인가요?",
                answer: "규칙적인 운동 습관을 들이는 것이 목표예요.",
                createdAt: now.addingTimeInterval(-259200),
                answeredAt: now.addingTimeInterval(-172800)
                
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
                answeredAt: now.addingTimeInterval(-259200)
                
            ),
            Question(
                id: 5,
                groupId: 1,
                question: "최근에 새로 배운 것이 있다면 무엇인가요?",
                answer: "최근에 기타를 배우기 시작했어요. 아직은 서툴지만 재미있어요.",
                createdAt: now.addingTimeInterval(-432000),
                answeredAt: now.addingTimeInterval(-345600)
                
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
                
                if questionId == currentQuestion?.id {
                    currentQuestion?.answer = answer
                    currentQuestion?.answeredAt = Date()
                    
                }
            }
        }
    }
    
    func updateAnswer(questionId: Int, answer: String) {
        // 실제 구현에서는 API 호출
        if mockData {
            if let index = allQuestions.firstIndex(where: { $0.id == questionId }) {
                allQuestions[index].answer = answer
                
                if questionId == selectedQuestion?.id {
                    selectedQuestion?.answer = answer
                    
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
*/
