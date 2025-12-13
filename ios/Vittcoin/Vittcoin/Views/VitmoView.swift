//
//  VitmoView.swift
//  Vittcoin
//
//  Created by Assistant on 12/11/25.
//

import SwiftUI
import UIKit

struct VitmoView: View {
    @State private var recipient: String = ""
    @State private var selectedContact: String?
    
    // Dummy data for the list
    let contacts = [
        "Alice Smith", "Bob Jones", "Charlie Brown", 
        "David Wilson", "Eve Davis", "Frank Miller", 
        "Grace Lee", "Henry Ford", "Ivy Chen"
    ]
    
    var filteredContacts: [String] {
        FuzzyMatcher.search(query: recipient, in: contacts)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Semicircle at the very top
            GeometryReader { geometry in
                Circle()
                .fill(Color.vittPrimary)
                .frame(width: geometry.size.width * 1.4, height: geometry.size.width * 1.4)
                .position(x: geometry.size.width / 2, y: -geometry.size.width * 0.15)
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: 200) // Limit the height impact of GeometryReader on the ZStack if needed, but here it's background
            
            VStack(spacing: 20) {
                // User Name in upper left
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ben Klosky")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("@ben.klosky")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 10) // Adjust for safe area
                
                Spacer()
                    .frame(height: 100)
                                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("@username", text: $recipient)
                        .padding()
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Scrollable list of people
                List(filteredContacts, id: \.self) { contact in
                    Button(action: {
                        selectedContact = contact
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("@\(contact.replacingOccurrences(of: " ", with: "").lowercased())")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: Binding<IdentifiableString?>(
            get: { selectedContact.map { IdentifiableString(string: $0) } },
            set: { selectedContact = $0?.string }
        )) { contactWrapper in
            TransactionModalView(contact: contactWrapper.string, selectedContact: $selectedContact)
        }
    }
}

struct TransactionModalView: View {
    let contact: String
    @Binding var selectedContact: String?
    @State private var amount: String = "0"
    @State private var memo: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: {
                    selectedContact = nil
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            VStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                Text(contact)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Big Integer Input
                IntegerInputView(text: $amount)
                    .frame(height: 80)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                TextField("What is this for?", text: $memo)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button(action: {
                        // Request logic
                        selectedContact = nil
                    }) {
                        Text("Request")
                            .font(.headline)
                            .foregroundColor(.vittPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.vittPrimary, lineWidth: 1)
                            )
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Pay logic
                        selectedContact = nil
                    }) {
                        Text("Pay")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.vittPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .presentationDetents([.large]) // Ensure full height availability
        .interactiveDismissDisabled()
    }
}

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

struct IdentifiableString: Identifiable {
    let id = UUID()
    let string: String
}

#Preview {
    VitmoView()
}
