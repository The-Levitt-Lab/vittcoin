//
//  StandingView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI
import Charts

struct BalancePoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}

struct StandingView: View {
    @State private var user: User?
    @State private var transactions: [Transaction] = []
    @State private var balanceHistory: [BalancePoint] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var firstName: String {
        if let fullName = user?.fullName, !fullName.isEmpty {
            return fullName.components(separatedBy: " ").first ?? "User"
        }
        return user?.username ?? "User"
    }
    
    var currentBalance: Double {
        Double(user?.balance ?? 0)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        // Greeting
                        Text("Hi, \(firstName)")
                            .font(.system(size: 32, weight: .semibold))
                            .padding(.horizontal)
                        
                        // Balance
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(String(format: "%.2f", currentBalance))
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("vtc")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                        
                        // Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Balance History")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if balanceHistory.isEmpty {
                                Text("No history available")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                Chart(balanceHistory) { point in
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("Balance", point.balance)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.vittPrimary, .vittPrimary.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                    
                                    AreaMark(
                                        x: .value("Date", point.date),
                                        y: .value("Balance", point.balance)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.vittPrimary.opacity(0.3), .vittPrimary.opacity(0.05)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { value in
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.month().day())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Transaction Ledger
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Transactions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if transactions.isEmpty {
                                Text("No recent transactions")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(transactions) { transaction in
                                        TransactionRow(transaction: transaction)
                                        
                                        if transaction.id != transactions.last?.id {
                                            Divider()
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            async let userTask = UserService.shared.fetchCurrentUser()
            async let txTask = UserService.shared.fetchTransactions()
            
            let (fetchedUser, fetchedTx) = try await (userTask, txTask)
            
            withAnimation {
                self.user = fetchedUser
                self.transactions = fetchedTx
                self.balanceHistory = calculateHistory(user: fetchedUser, transactions: fetchedTx)
                self.isLoading = false
                self.errorMessage = nil
            }
        } catch {
            print("Error fetching data: \(error)")
            self.errorMessage = "Failed to load data. Please try again."
            self.isLoading = false
        }
    }
    
    private func calculateHistory(user: User, transactions: [Transaction]) -> [BalancePoint] {
        let now = Date()
        var points: [BalancePoint] = []
        
        // Start with current balance at 'now'
        var currentBal = Double(user.balance)
        points.append(BalancePoint(date: now, balance: currentBal))
        
        // Sort transactions descending by date (newest first)
        let sortedTx = transactions.sorted { $0.createdAt > $1.createdAt }
        
        for tx in sortedTx {
            // Revert the transaction to get previous balance
            // Logic: prev = current - amount
            currentBal -= Double(tx.amount)
            points.append(BalancePoint(date: tx.createdAt, balance: currentBal))
        }
        
        // Finally, add point at createdAt with the calculated initial balance
        points.append(BalancePoint(date: user.createdAt, balance: currentBal))
        
        return points.sorted { $0.date < $1.date }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? transaction.type.capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount is Int, convert to Double
            let amount = Double(transaction.amount)
            let isPositive = transaction.isPositive
            
            Text("\(isPositive ? "+" : "")\(String(format: "%.2f", amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isPositive ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    StandingView()
}
