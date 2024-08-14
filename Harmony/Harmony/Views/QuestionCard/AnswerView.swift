//
//  AnswerView.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//


import SwiftUI
import Speech
/*
struct AnswerView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var answerText = ""
    @State private var navigateToDetail = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var isSTTActive = false
    @State private var transcribedText = ""
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private let audioEngine = AVAudioEngine()
    
    var isVIP: Bool {
        UserDefaultsManager.shared.isVIP()
    }
    
    var body: some View {
        Group {
            if isVIP {
                AnswerCommonView(
                    questionIndex: viewModel.currentQuestion?.id ?? 0,
                    question: viewModel.currentQuestion?.question ?? "",
                    answeredAt: nil,
                    answerText: $answerText,
                    buttonText: "답변 완료",
                    onSubmit: submitAnswer
                )
                .navigationDestination(isPresented: $navigateToDetail) {
                    QuestionDetailView(viewModel: viewModel, questionId: questionId)
                }
            } else {
                Text("VIP 회원만 답변을 작성할 수 있습니다.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .task {
            if viewModel.currentQuestion == nil, let groupId = UserDefaultsManager.shared.getGroupId() {
                await viewModel.fetchCurrentQuestion(groupId: groupId)
            }
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $isSTTActive) {
            STTModalView(transcribedText: $transcribedText, isActive: $isSTTActive, answerText: $answerText, onComplete: {
                answerText += transcribedText
                transcribedText = ""
            })
        }
    }
    
    private func submitAnswer() {
        Task {
            do {
                await viewModel.postAnswer(questionId: questionId, answer: answerText)
                navigateToDetail = true
            } catch {
                errorMessage = "답변 제출 중 오류가 발생했습니다: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    private var sttButton: some View {
        Button(action: {
            isSTTActive = true
            startSTT()
        }) {
            HStack {
                Image(systemName: "mic")
                Text("음성으로 입력하기")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.mainGreen)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding(.top)
    }
    
    private func startSTT() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    do {
                        try self.startRecording()
                    } catch {
                        print("Failed to start recording: \(error)")
                    }
                } else {
                    print("Speech recognition not authorized")
                }
            }
        }
    }
    
    private func startRecording() throws {
        // 기존 태스크 취소
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            if error != nil {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
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


struct STTModalView: View {
    @Binding var transcribedText: String
    @Binding var isActive: Bool
    @Binding var answerText: String
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            Image("moni-talk") // 앱에서 사용하는 이미지 에셋 이름
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("모니가 음성을 듣고 있어요")
                .font(.headline)
                .padding()
            
            Text(transcribedText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            Button("완료") {
                stopRecording()
                onComplete()
                isActive = false
            }
            .padding()
            .background(Color.mainGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func stopRecording() {
        NotificationCenter.default.post(name: .stopSTTRecording, object: nil)
    }
}

extension Notification.Name {
    static let stopSTTRecording = Notification.Name("stopSTTRecording")
}
*/


// MARK: - Preview
//#Preview {
//    NavigationView {
//        AnswerView(viewModel: QuestionViewModel(mockData: true), questionId: 1)
//    }
//}


import SwiftUI
import Speech
import AVFoundation
import Accelerate

struct AnswerView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let questionId: Int
    @State private var navigateToDetail = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var isVIP: Bool {
        UserDefaultsManager.shared.isVIP()
    }
    
    var body: some View {
        Group {
            if isVIP {
                AnswerCommonView(
                    questionIndex: viewModel.currentQuestion?.id ?? 0,
                    question: viewModel.currentQuestion?.question ?? "",
                    answeredAt: nil,
                    questionId: questionId,
                    onSubmit: submitAnswer
                )
                .navigationDestination(isPresented: $navigateToDetail) {
                    QuestionDetailView(viewModel: viewModel, questionId: questionId)
                }
            } else {
                Text("VIP 회원만 답변을 작성할 수 있습니다.")
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .task {
            if viewModel.currentQuestion == nil, let groupId = UserDefaultsManager.shared.getGroupId() {
                await viewModel.fetchCurrentQuestion(groupId: groupId)
            }
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func submitAnswer(answer: String) {
        Task {
            do {
                await viewModel.postAnswer(questionId: questionId, answer: answer)
                navigateToDetail = true
            } catch {
                errorMessage = "답변 제출 중 오류가 발생했습니다: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}

struct AnswerCommonView: View {
    let questionIndex: Int
    let question: String
    let answeredAt: Date?
    let questionId: Int
    let onSubmit: (String) -> Void
    
    @State private var audioLevel: CGFloat = 0.0
    @State private var answerText: String
    @State private var isSTTActive = false
    @State private var transcribedText = ""
    @State private var isSTTViewPresented = false
    @State private var isRecognizing = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private let audioEngine = AVAudioEngine()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    
    
    init(questionIndex: Int, question: String, answeredAt: Date?, questionId: Int, initialAnswer: String = "", onSubmit: @escaping (String) -> Void) {
        self.questionIndex = questionIndex
        self.question = question
        self.answeredAt = answeredAt
        self.questionId = questionId
        self.onSubmit = onSubmit
        _answerText = State(initialValue: initialAnswer)
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.wh.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        questionSection
                        
                        sttButton
                        
                        textEditorSection(height: geometry.size.height * 0.6)
                        
                        submitButton
                    }
                    .padding()
                }
                
                if isSTTViewPresented {
                    VStack {
                        Spacer()
                        STTView(transcribedText: $transcribedText,
                                isActive: $isSTTViewPresented,
                                answerText: $answerText,
                                isRecognizing: $isRecognizing,
                                audioLevel: $audioLevel,
                                onComplete: {
                            answerText += transcribedText
                            transcribedText = ""
                            stopRecording()
                        },
                                onCancel: {
                            stopRecording()
                        })
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(), value: isSTTViewPresented)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("오류"), message: Text(errorMessage), dismissButton: .default(Text("확인")))
        }
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
    
    private var sttButton: some View {
        Button(action: {
            if isSTTViewPresented {
                stopRecording()
            } else {
                isSTTViewPresented = true
                startSTT()
            }
        }) {
            HStack {
                Image(systemName: "mic")
                Text("음성으로 입력하기")
                    .font(.system(size: 18, weight: .bold)) // 텍스트를 볼드로 변경
            }
            .padding(.horizontal, 25) // 가로 패딩 증가
            .padding(.vertical, 15) // 세로 패딩 증가
            .background(isSTTViewPresented ? Color.red : Color.mainGreen)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 5) // 상하 패딩 감소
    }
    
    private var submitButton: some View {
        Button(action: { onSubmit(answerText) }) {
            Text("답변 완료")
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
    
    
    private func startSTT() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    do {
                        try self.startRecording()
                    } catch {
                        self.errorMessage = "음성 인식을 시작할 수 없습니다: \(error.localizedDescription)"
                        self.showErrorAlert = true
                        print("Failed to start recording: \(error)")
                    }
                } else {
                    self.errorMessage = "음성 인식 권한이 필요합니다."
                    self.showErrorAlert = true
                    print("Speech recognition not authorized")
                }
            }
        }
    }
    
    private func startRecording() throws {
        // 기존 태스크 취소
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        
        // 새로운 인식 요청 생성
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        // 인식 태스크 시작
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                self.isRecognizing = true
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopRecording()
            }
        }
        
        // 오디오 버퍼 설정
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
            
            // 오디오 레벨 계산
            self.updateAudioLevel(buffer: buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecognizing = true
    }
    
    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = UInt(buffer.frameLength)
        
        var sum: Float = 0
        vDSP_measqv(channelData, 1, &sum, frameLength)
        var db = 10 * log10f(sum / Float(frameLength))
        if db.isInfinite {
            db = -160
        }
        let normalizedValue = (db + 160) / 160 // Normalize to 0-1 range
        
        DispatchQueue.main.async {
            self.audioLevel = CGFloat(normalizedValue)
        }
    }
    
    private func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        
        let minDb: Float = -80
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }
    
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // 오디오 세션 비활성화
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        isRecognizing = false
        isSTTViewPresented = false
    }
}

struct STTView: View {
    @Binding var transcribedText: String
    @Binding var isActive: Bool
    @Binding var answerText: String
    @Binding var isRecognizing: Bool
    @Binding var audioLevel: CGFloat
    var onComplete: () -> Void
    var onCancel: () -> Void
    
    @State private var glowAmount: CGFloat = 0.0
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.mainGreen.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .scaleEffect(1 + glowAmount)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: glowAmount)
                
                Image("moni-talk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .onAppear {
                self.glowAmount = 0.2
            }
            
            Text(isRecognizing ? "모니가 음성을 듣고 있어요" : "음성 인식 준비 중...")
                .font(.headline)
                .padding()
            
            Text(transcribedText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            HStack {
                Button("취소") {
                    onCancel()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
                
                Button("완료") {
                    onComplete()
                }
                .padding()
                .background(Color.mainGreen)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(height: 350)
        .onChange(of: audioLevel) { newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                glowAmount = 0.2 + (newValue * 2)
            }
        }
    }
}

extension Notification.Name {
    static let stopSTTRecording = Notification.Name("stopSTTRecording")
}
