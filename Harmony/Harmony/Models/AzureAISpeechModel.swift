//
//  AzureAISpeechModel.swift
//  Harmony
//
//  Created by 한범석 on 7/24/24.
//

/*
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
*/

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct RecognitionResponse: Codable {
    let recognitionStatus: String?
    let displayText: String?
    let offset: Int?
    let duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case recognitionStatus = "RecognitionStatus"
        case displayText = "DisplayText"
        case offset = "Offset"
        case duration = "Duration"
    }
}

struct ChatResponse: Codable {
    let choices: [Choice]
    let id: String
    let model: String
    let object: String
    let promptFilterResults: [PromptFilterResults]?
    let usage: Usage
}

struct Choice: Codable {
    let contentFilterResults: ContentFilterResults
    let finishReason: String
    let index: Int
    let message: ChatGPTMessage
    
    enum CodingKeys: String, CodingKey {
        case contentFilterResults = "content_filter_results"
        case finishReason = "finish_reason"
        case index, message
    }
}

struct ChatGPTMessage: Codable {
    let content: String
    let role: String
}

struct PromptFilterResults: Codable {
    let promptIndex: Int
    let contentFilterResults: ContentFilterResults
    
    enum CodingKeys: String, CodingKey {
        case promptIndex = "prompt_index"
        case contentFilterResults = "content_filter_results"
    }
}

struct ContentFilterResults: Codable {
    let hate: Hate
    let jailbreak: Jailbreak?
    let selfHarm: SelfHarm
    let sexual: Sexual
    let violence: Violence
    
    enum CodingKeys: String, CodingKey {
        case selfHarm = "self_harm"
        case hate, jailbreak, sexual, violence
    }
}

struct Hate: Codable {
    let filtered: Bool
    let severity: String
}

struct Jailbreak: Codable {
    let filtered: Bool
    let detected: Bool
}

struct SelfHarm: Codable {
    let filtered: Bool
    let severity: String
}

struct Sexual: Codable {
    let filtered: Bool
    let severity: String
}

struct Violence: Codable {
    let filtered: Bool
    let severity: String
}

struct Usage: Codable {
    let completionTokens: Int
    let promptTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case completionTokens = "completion_tokens"
        case promptTokens = "prompt_tokens"
        case totalTokens = "total_tokens"
    }
}




