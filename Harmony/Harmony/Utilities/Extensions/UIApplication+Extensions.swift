//
//  UIApplication+Extensions.swift
//  Harmony
//
//  Created by 한범석 on 7/17/24.
//

import SwiftUI
import Combine


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        
        keyboardWillShow.merge(with: keyboardWillHide)
            .compactMap { notification -> CGFloat? in
                guard let userInfo = notification.userInfo,
                      let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                return notification.name == UIResponder.keyboardWillShowNotification ? frame.height : 0
            }
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
    }
}
