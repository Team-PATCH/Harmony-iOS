//
//  AzureAISpeechModel.swift
//  Harmony
//
//  Created by 한범석 on 7/24/24.
//

import Foundation



struct SpeechRecognitionResponse: Decodable {
    let DisplayText: String
}


struct OpenAICompletionResponse: Codable {
    struct Choice: Codable {
        let text: String
    }
    let choices: [Choice]
}
