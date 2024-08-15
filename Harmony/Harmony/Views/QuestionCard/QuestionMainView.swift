
import SwiftUI

struct QuestionMainView: View {
    @StateObject var viewModel = QuestionViewModel()
    let userNick = UserDefaultsManager.shared.getNick() ?? " "
    @State private var isVIP: Bool = false
    @State private var appearAnimation = false
    @State private var currentQuestionAppear = false
    @State private var recentQuestionsAppear = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        if let currentQuestion = viewModel.currentQuestion {
                            VStack {
                                CurrentQuestionBox(question: currentQuestion, viewModel: viewModel, isVIP: isVIP)
                            }
                            .padding()
                            .background(Color.wh)
                            .cornerRadius(10)
                            .opacity(currentQuestionAppear ? 1 : 0)
                            .offset(y: currentQuestionAppear ? 0 : 50)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: currentQuestionAppear)
                        }
                    }
                    .padding()
                    .background(Color.gray1)
                    
                    RecentQuestionsSection(viewModel: viewModel, appearAnimation: $recentQuestionsAppear)
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
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -20)
                    .animation(.easeOut(duration: 0.5), value: appearAnimation)
                }
            }
        }
        .task {
            if let groupId = UserDefaultsManager.shared.getGroupId() {
                await viewModel.fetchCurrentQuestion(groupId: groupId)
                await viewModel.fetchRecentQuestions(groupId: groupId)
            }
        }
        .onAppear {
            isVIP = UserDefaultsManager.shared.isVIP()
            animateView()
        }
    }
    
    private func animateView() {
        withAnimation(.easeOut(duration: 0.5)) {
            appearAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentQuestionAppear = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                recentQuestionsAppear = true
            }
        }
    }
}

struct CurrentQuestionBox: View {
    let question: Question
    @ObservedObject var viewModel: QuestionViewModel
    let isVIP: Bool
    @State private var buttonScale: CGFloat = 1.0
    
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
                .background(isVIP ? Color.mainGreen : Color.gray)
                .cornerRadius(999)
                .scaleEffect(buttonScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonScale)
            }
            .disabled(!isVIP)
            .onHover { hovering in
                buttonScale = hovering ? 1.05 : 1.0
            }
        }
    }
}

struct RecentQuestionsSection: View {
    @ObservedObject var viewModel: QuestionViewModel
    @Binding var appearAnimation: Bool
    
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
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appearAnimation)
            
            VStack(spacing: 10) {
                ForEach(Array(viewModel.recentQuestions.enumerated()), id: \.element.id) { index, question in
                    QuestionBox(question: question, viewModel: viewModel)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.3), value: appearAnimation)
                }
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
    @State private var isHovered = false
    
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
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
