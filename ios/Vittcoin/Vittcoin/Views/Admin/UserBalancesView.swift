//
//  UserBalancesView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/12/25.
//

import SwiftUI

struct UserBalancesView: View {
    @StateObject private var userService = UserService.shared
    @State private var users: [User] = []
    @State private var selectedUserId: Int?
    @State private var amountString: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // User Selection
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Select User")
                            .font(.headline)
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Button(action: loadUsers) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        if users.isEmpty && !isLoading {
                            Text("No users found")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(users) { user in
                                UserSelectionRow(
                                    user: user,
                                    isSelected: selectedUserId == user.id
                                ) {
                                    selectedUserId = user.id
                                }
                                
                                if user.id != users.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Change Balance Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Change Balance")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        TextField("Amount (integer)", text: $amountString)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        HStack(spacing: 16) {
                            // Disburse Button
                            Button(action: {
                                Task { await updateBalance(operation: .add) }
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Disburse")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(selectedUserId == nil || amountString.isEmpty)
                            .opacity(selectedUserId == nil || amountString.isEmpty ? 0.5 : 1.0)
                            
                            // Remove Button
                            Button(action: {
                                Task { await updateBalance(operation: .subtract) }
                            }) {
                                HStack {
                                    Image(systemName: "minus.circle.fill")
                                    Text("Remove")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(selectedUserId == nil || amountString.isEmpty)
                            .opacity(selectedUserId == nil || amountString.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("User Balances")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUsers()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
    }
    
    private func loadUsers() {
        isLoading = true
        Task {
            do {
                users = try await userService.fetchUsers()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
    
    enum BalanceOperation {
        case add, subtract
    }
    
    private func updateBalance(operation: BalanceOperation) async {
        guard let userId = selectedUserId,
              let amount = Int(amountString),
              amount > 0 else {
            return
        }
        
        isLoading = true
        do {
            let updatedUser: User
            switch operation {
            case .add:
                updatedUser = try await userService.addBalance(userId: userId, amount: amount)
                successMessage = "Successfully disbursed \(amount) Vittcoin to \(updatedUser.fullName ?? updatedUser.email)"
            case .subtract:
                updatedUser = try await userService.subtractBalance(userId: userId, amount: amount)
                successMessage = "Successfully removed \(amount) Vittcoin from \(updatedUser.fullName ?? updatedUser.email)"
            }
            
            // Update local user list
            if let index = users.firstIndex(where: { $0.id == userId }) {
                users[index] = updatedUser
            }
            
            amountString = ""
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

struct UserSelectionRow: View {
    let user: User
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName ?? user.email)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(user.balance) vtc")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

