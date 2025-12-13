//
//  AdminTransactionsView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/12/25.
//

import SwiftUI

struct AdminTransactionsView: View {
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task { await loadTransactions() }
                    }
                }
            } else if transactions.isEmpty {
                Text("No transactions found")
                    .foregroundColor(.secondary)
            } else {
                List(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
                .refreshable {
                    await loadTransactions()
                }
            }
        }
        .navigationTitle("Transactions")
        .task {
            await loadTransactions()
        }
    }
    
    private func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        do {
            transactions = try await UserService.shared.fetchAllTransactions()
            isLoading = false
        } catch {
            print("Error loading transactions: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
