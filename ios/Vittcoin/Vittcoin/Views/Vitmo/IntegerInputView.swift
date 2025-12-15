import SwiftUI
import UIKit

struct IntegerInputView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 64, weight: .bold) // Big bold
        textField.textColor = .label
        textField.tintColor = UIColor(Color.vittPrimary)
        textField.text = text
        textField.delegate = context.coordinator
        
        // Target for updates
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        
        // Auto-focus and select all
        textField.becomeFirstResponder()
        
        // Dispatch to select all after layout
        DispatchQueue.main.async {
            textField.selectAll(nil)
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: IntegerInputView
        
        init(_ parent: IntegerInputView) {
            self.parent = parent
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Allow backspace
            if string.isEmpty { return true }
            
            // Allow only digits
            if !string.allSatisfy({ $0.isNumber }) { return false }
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Max 4 digits
            if updatedText.count > 4 { return false }
            
            return true
        }
    }
}
