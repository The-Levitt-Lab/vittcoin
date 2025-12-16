import SwiftUI

struct TransactionModalView: View {
    let user: User
    @Binding var selectedUser: User?
    @State private var amount: String = "0"
    @State private var memo: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: {
                    selectedUser = nil
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
                
                Text(user.fullName ?? user.username ?? "Unknown")
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
                        Task {
                            let amountInt = Int(amount) ?? 0
                            if amountInt > 0 {
                                do {
                                    _ = try await RequestService.shared.createRequest(
                                        amount: amountInt,
                                        description: memo.isEmpty ? nil : memo,
                                        recipientId: user.id
                                    )
                                    selectedUser = nil
                                } catch {
                                    print("Error creating request: \(error)")
                                }
                            }
                        }
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
                        Task {
                            let amountInt = Int(amount) ?? 0
                            if amountInt > 0 {
                                do {
                                    _ = try await UserService.shared.sendPayment(
                                        amount: amountInt,
                                        description: memo.isEmpty ? nil : memo,
                                        recipientId: user.id
                                    )
                                    selectedUser = nil
                                } catch {
                                    print("Error sending payment: \(error)")
                                }
                            }
                        }
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
