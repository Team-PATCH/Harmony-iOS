//
//  AzureAIService.swift
//  Harmony
//
//  Created by 한범석 on 7/24/24.
//

import Foundation
import AVFoundation
import Alamofire

/*
final class SpeechService {
    private var audioRecorder: AVAudioRecorder?
    private let audioFilename: URL
    private let endpoint = "https://koreacentral.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
    private let subscriptionKey = ""
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.audioFilename = documentsPath.appendingPathComponent("recording.wav")
    }
    
    func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording(completion: @escaping (String?) -> Void) {
        audioRecorder?.stop()
        audioRecorder = nil
        transcribeAudio(completion: completion)
    }
    
    private func transcribeAudio(completion: @escaping (String?) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "audio/wav; codec=audio/pcm; samplerate=16000",
            "Ocp-Apim-Subscription-Key": subscriptionKey
        ]
        
        AF.upload(audioFilename, to: endpoint, headers: headers)
            .responseDecodable(of: SpeechRecognitionResponse.self) { response in
                switch response.result {
                case .success(let recognitionResponse):
                    completion(recognitionResponse.DisplayText)
                case .failure(let error):
                    print("Failed to transcribe audio: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
}


class TextToSpeechService {
    private let subscriptionKey = ""
    private let endpoint = "https://koreacentral.tts.speech.microsoft.com/cognitiveservices/v1"
    
    func synthesizeText(_ text: String, completion: @escaping (Data?) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/ssml+xml",
            "Ocp-Apim-Subscription-Key": subscriptionKey
        ]
        
        let ssml = """
        <speak version='1.0' xml:lang='ko-KR'>
            <voice xml:lang='ko-KR' xml:gender='Female' name='ko-KR-SunHiNeural'>
                \(text)
            </voice>
        </speak>
        """
        
        guard let ssmlData = ssml.data(using: .utf8) else {
            print("Failed to convert SSML string to Data")
            completion(nil)
            return
        }
        
        AF.upload(ssmlData, to: endpoint, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    print("Failed to synthesize text: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
}
*/


import Foundation
import Alamofire

class AzureSpeechService {
    static let shared = AzureSpeechService()

    private init() {}

    func recognizeSpeech(audioData: Data, completion: @escaping (String) -> Void) {
        let url = "https://koreacentral.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=ko-KR"
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "a84015bd8b264580b81e5ddebdd6ec73",
            "Content-Type": "audio/wav"
        ]
        
        print("initiate Azure speech service.")

        AF.upload(audioData, to: url, headers: headers).responseDecodable(of: RecognitionResponse.self) { response in
            switch response.result {
            case .success(let recognitionResponse):
                print("Speech Recognition Response: \(recognitionResponse)")
                if recognitionResponse.recognitionStatus == "Success", let text = recognitionResponse.displayText {
                    completion(text)
                } else {
                    print("Recognition failed: \(recognitionResponse.recognitionStatus ?? "unknown")")
                    completion("인식에 실패했습니다.")
                }
            case .failure(let error):
                print("Error in recognizeSpeech: \(error)")
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }
                completion("인식에 실패했습니다.")
            }
        }
    }

    func chatWithGPT4(messages: [ChatMessage], completion: @escaping (String) -> Void) {
        let url = "https://patch-harmony.openai.azure.com/openai/deployments/test2/chat/completions?api-version=2024-07-01-preview"
        let headers: HTTPHeaders = [
            "api-key": "5b76d0e6a6ea4ed0948db1d9ee1e5e54",
            "Content-Type": "application/json"
        ]
        
        var formattedMessages: [[String: String]] = [
                ["role": "system", "content": "당신은 가족간의 조화를 만드는 챗봇 '모니'입니다. 당신은 노인분과 대화하고 있고, 긍정적이고 따뜻한, 공감하는 말투로 대답해야 합니다. 또한, 2~3문장 이내로 대답해야 하며, 노인분에게 질문을 하는 등 대화를 적극적으로 이어가려고 노력해야 합니다."]
            ]
            
            formattedMessages.append(contentsOf: messages.map { ["role": $0.role, "content": $0.content] })
            
            let parameters: [String: Any] = [
                "messages": formattedMessages,
                "max_tokens": 100,
                "temperature": 0.7
            ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: ChatResponse.self) { response in
            switch response.result {
            case .success(let chatResponse):
                let responseText = chatResponse.choices.first?.message.content ?? "No response"
                completion(responseText)
            case .failure(let error):
                print("Error in chatWithGPT4: \(error)")
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }
                completion("응답을 받을 수 없습니다.")
            }
        }
    }

    func synthesizeSpeech(text: String, completion: @escaping (URL) -> Void) {
        let url = "https://koreacentral.tts.speech.microsoft.com/cognitiveservices/v1"
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "488fde61f6a646d9b47d24c9a8916674",
            "Content-Type": "application/ssml+xml",
            "X-Microsoft-OutputFormat": "audio-16khz-32kbitrate-mono-mp3"
        ]
        let ssml = """
        <speak version='1.0' xml:lang='ko-KR'>
            <voice name='ko-KR-SunHiNeural'>
                \(text)
            </voice>
        </speak>
        """

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers.dictionary
        request.httpBody = ssml.data(using: .utf8)

        AF.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
                do {
                    try data.write(to: tempFileURL)
                    completion(tempFileURL)
                } catch {
                    print("Error in synthesizeSpeech: \(error)")
                }
            case .failure(let error):
                print("Error in synthesizeSpeech: \(error)")
            }
        }
    }
}




