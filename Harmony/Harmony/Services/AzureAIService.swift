//
//  AzureAIService.swift
//  Harmony
//
//  Created by 한범석 on 7/24/24.
//

import Foundation
import AVFoundation
import Alamofire

class SpeechService {
    private var audioRecorder: AVAudioRecorder?
    private let audioFilename: URL
    private let endpoint = "https://koreacentral.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
    private let subscriptionKey = "a84015bd8b264580b81e5ddebdd6ec73"
    
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
    private let subscriptionKey = "a84015bd8b264580b81e5ddebdd6ec73"
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

