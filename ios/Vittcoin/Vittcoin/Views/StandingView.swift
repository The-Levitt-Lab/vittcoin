//
//  StandingView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI
import Charts

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let date: Date
    let isPositive: Bool
}

struct BalancePoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}

struct StandingView: View {
    // Sample data - replace with actual user data
    @State private var firstName: String = "Ben."
    @State private var currentBalance: Double = 1250.50
    
    // Sample balance history for chart
    @State private var balanceHistory: [BalancePoint] = {
        let calendar = Calendar.current
        let now = Date()
        return [
            BalancePoint(date: calendar.date(byAdding: .day, value: -6, to: now)!, balance: 850),
            BalancePoint(date: calendar.date(byAdding: .day, value: -5, to: now)!, balance: 920),
            BalancePoint(date: calendar.date(byAdding: .day, value: -4, to: now)!, balance: 880),
            BalancePoint(date: calendar.date(byAdding: .day, value: -3, to: now)!, balance: 1050),
            BalancePoint(date: calendar.date(byAdding: .day, value: -2, to: now)!, balance: 1100),
            BalancePoint(date: calendar.date(byAdding: .day, value: -1, to: now)!, balance: 1200),
            BalancePoint(date: now, balance: 1250.50)
        ]
    }()
    
    // Sample transactions
    @State private var recentTransactions: [Transaction] = {
        let calendar = Calendar.current
        let now = Date()
        return [
            Transaction(
                title: "Daily Challenge Completed",
                amount: 50.50,
                date: now,
                isPositive: true
            ),
            Transaction(
                title: "Item Purchase",
                amount: 25.00,
                date: calendar.date(byAdding: .hour, value: -2, to: now)!,
                isPositive: false
            ),
            Transaction(
                title: "Weekly Bonus",
                amount: 100.00,
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                isPositive: true
            ),
            Transaction(
                title: "Leaderboard Reward",
                amount: 75.00,
                date: calendar.date(byAdding: .day, value: -2, to: now)!,
                isPositive: true
            ),
            Transaction(
                title: "Shop Purchase",
                amount: 30.00,
                date: calendar.date(byAdding: .day, value: -3, to: now)!,
                isPositive: false
            )
        ]
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
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
                        
                        Chart(balanceHistory) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Balance", point.balance)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
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
                                    colors: [.green.opacity(0.3), .green.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: 2)) { value in
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
                    .padding(.vertical, 8)
                    
                    // Transaction Ledger
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(recentTransactions) { transaction in
                                TransactionRow(transaction: transaction)
                                
                                if transaction.id != recentTransactions.last?.id {
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
                .padding(.bottom)
            }
            .navigationTitle("Standing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.isPositive ? "+" : "-")\(String(format: "%.2f", transaction.amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.isPositive ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    StandingView()
}
