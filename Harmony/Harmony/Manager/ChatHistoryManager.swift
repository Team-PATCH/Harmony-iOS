//
//  ChatHistoryManager.swift
//  Harmony
//
//  Created by 한범석 on 8/3/24.
//

import Foundation

class ChatHistoryManager {
    static let shared = ChatHistoryManager()
    private let userDefaults = UserDefaults.standard
    private let chatHistoryKey = "chatHistories"
    
    private init() {}
    
    func saveChatHistory(_ history: ChatHistory) {
        var histories = loadChatHistories()
        if let index = histories.firstIndex(where: { $0.id == history.id }) {
            histories[index] = history
        } else {
            histories.append(history)
        }
        if let encoded = try? JSONEncoder().encode(histories) {
            userDefaults.set(encoded, forKey: chatHistoryKey)
        }
        print("Saved chat history for memory card \(history.id)")
    }
    
    func loadChatHistories() -> [ChatHistory] {
        if let data = userDefaults.data(forKey: chatHistoryKey),
           let histories = try? JSONDecoder().decode([ChatHistory].self, from: data) {
            print("Loaded \(histories.count) chat histories from UserDefaults")
            return histories
        }
        print("No chat histories found in UserDefaults")
        return []
    }
}
