//
//  CustomTextEditor.swift
//  Harmony_ForPR
//
//  Created by Ji Hye PARK on 7/23/24.
//

import SwiftUI
import UIKit

struct CustomTextEditor: UIViewControllerRepresentable {
    @Binding var text: String
    var backgroundColor: UIColor
    var textColor: UIColor = .black
    var font: UIFont = .systemFont(ofSize: 20)
    var placeholder: String?
    var maxLength: Int = 200

    func makeUIViewController(context: Context) -> CustomTextViewController {
        let viewController = CustomTextViewController()
        viewController.delegate = context.coordinator
        viewController.backgroundColor = backgroundColor
        viewController.textColor = textColor
        viewController.font = font
        viewController.placeholder = placeholder
        viewController.maxLength = maxLength
        return viewController
    }

    func updateUIViewController(_ uiViewController: CustomTextViewController, context: Context) {
        uiViewController.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CustomTextViewControllerDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ text: String) {
            parent.text = text
        }
    }
}

protocol CustomTextViewControllerDelegate: AnyObject {
    func textDidChange(_ text: String)
}

class CustomTextViewController: UIViewController, UITextViewDelegate {
    var textPadding: UIEdgeInsets = UIEdgeInsets(top: 15, left: 19, bottom: 0, right: 8)
    weak var delegate: CustomTextViewControllerDelegate?
    
    var text: String = "" {
        didSet {
            textView.text = text
            updatePlaceholder()
            updateCharacterCount()
        }
    }
    
    var backgroundColor: UIColor = .white {
        didSet { updateBackgroundColor() }
    }
    
    var textColor: UIColor = .black {
        didSet { updateTextColor() }
    }
    
    var font: UIFont = .systemFont(ofSize: 20) {
        didSet { updateFont() }
    }
    
    var placeholder: String? {
        didSet { updatePlaceholder() }
    }
    
    var maxLength: Int = 200 {
        didSet { updateCharacterCount() }
    }
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.pretendardMedium(size: 18)
        label.textColor = UIColor(Color.gray4)
        return label
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(textView)
        view.addSubview(characterCountLabel)
        textView.addSubview(placeholderLabel)
        
        // Set the text view's text container inset to match the placeholder padding
        textView.textContainerInset = textPadding
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            characterCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            characterCountLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: textPadding.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textPadding.left),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -textPadding.right)
        ])
        
        textView.delegate = self
        updateBackgroundColor()
        updateTextColor()
        updateFont()
        updatePlaceholder()
        updateCharacterCount()
    }

    
    private func updateBackgroundColor() {
        textView.backgroundColor = backgroundColor
    }
    
    private func updateTextColor() {
        textView.textColor = textColor
    }
    
    private func updateFont() {
        textView.font = font
        placeholderLabel.font = font
    }
    
    private func updatePlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    private func updateCharacterCount() {
        characterCountLabel.text = "\(text.count)/\(maxLength)자"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.textDidChange(text)
        updateCharacterCount()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxLength
    }
}

// UIFont extension for Pretendard fonts
extension UIFont {
    static func pretendardMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Pretendard-Medium", size: size) ?? .systemFont(ofSize: size)
    }
}

