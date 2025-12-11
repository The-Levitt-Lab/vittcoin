//
//  AdminView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/12/25.
//

import SwiftUI

struct AdminView: View {
    @State private var selectedUserId: String = ""
    @State private var disburseAmount: String = ""
    @State private var removeAmount: String = ""
    @State private var showDisbursementSuccess = false
    @State private var showRemovalSuccess = false
    
    // Sample users - replace with actual user data
    @State private var users: [AdminUser] = [
        AdminUser(id: "1", name: "John Doe", balance: 1500.00),
        AdminUser(id: "2", name: "Jane Smith", balance: 2300.50),
        AdminUser(id: "3", name: "Mike Johnson", balance: 980.00),
        AdminUser(id: "4", name: "Sarah Williams", balance: 3200.75)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin Panel")
                            .font(.system(size: 32, weight: .semibold))
                        Text("Manage user balances")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // User Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select User")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
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
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Disburse Vittcoin Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Disburse Vittcoin")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            TextField("Amount to disburse", text: $disburseAmount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            Button(action: disburseVittcoin) {
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
                            .disabled(selectedUserId.isEmpty || disburseAmount.isEmpty)
                            .opacity(selectedUserId.isEmpty || disburseAmount.isEmpty ? 0.5 : 1.0)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Remove Vittcoin Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Remove Vittcoin")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            TextField("Amount to remove", text: $removeAmount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            Button(action: removeVittcoin) {
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
                            .disabled(selectedUserId.isEmpty || removeAmount.isEmpty)
                            .opacity(selectedUserId.isEmpty || removeAmount.isEmpty ? 0.5 : 1.0)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Admin")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Success", isPresented: $showDisbursementSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Vittcoin disbursed successfully")
            }
            .alert("Success", isPresented: $showRemovalSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Vittcoin removed successfully")
            }
        }
    }
    
    private func disburseVittcoin() {
        // Placeholder for actual disbursement logic
        guard let amount = Double(disburseAmount), amount > 0 else { return }
        
        // Update user balance in the list
        if let index = users.firstIndex(where: { $0.id == selectedUserId }) {
            users[index].balance += amount
        }
        
        showDisbursementSuccess = true
        disburseAmount = ""
    }
    
    private func removeVittcoin() {
        // Placeholder for actual removal logic
        guard let amount = Double(removeAmount), amount > 0 else { return }
        
        // Update user balance in the list
        if let index = users.firstIndex(where: { $0.id == selectedUserId }) {
            users[index].balance = max(0, users[index].balance - amount)
        }
        
        showRemovalSuccess = true
        removeAmount = ""
    }
}

struct AdminUser: Identifiable {
    let id: String
    var name: String
    var balance: Double
}

struct UserSelectionRow: View {
    let user: AdminUser
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(String(format: "%.2f vtc", user.balance))
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

#Preview {
    AdminView()
}


