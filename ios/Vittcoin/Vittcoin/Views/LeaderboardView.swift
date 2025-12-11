//
//  LeaderboardView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let coins: Int
}

struct LeaderboardView: View {
    // Placeholder data for top 10 students
    let leaderboardData = [
        LeaderboardEntry(rank: 1, name: "Alex Johnson", coins: 2450),
        LeaderboardEntry(rank: 2, name: "Sarah Chen", coins: 2280),
        LeaderboardEntry(rank: 3, name: "Michael Williams", coins: 2150),
        LeaderboardEntry(rank: 4, name: "Emma Davis", coins: 1980),
        LeaderboardEntry(rank: 5, name: "James Rodriguez", coins: 1875),
        LeaderboardEntry(rank: 6, name: "Olivia Martinez", coins: 1720),
        LeaderboardEntry(rank: 7, name: "Daniel Kim", coins: 1650),
        LeaderboardEntry(rank: 8, name: "Sophia Patel", coins: 1540),
        LeaderboardEntry(rank: 9, name: "Ethan Thompson", coins: 1425),
        LeaderboardEntry(rank: 10, name: "Ava Anderson", coins: 1350)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Leaderboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                List {
                    ForEach(leaderboardData) { entry in
                        HStack(spacing: 15) {
                            // Rank badge
                            ZStack {
                                Circle()
                                    .fill(rankColor(for: entry.rank))
                                    .frame(width: 40, height: 40)
                                
                                Text("\(entry.rank)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            // Student name
                            Text(entry.name)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            // Coin amount
                            HStack(spacing: 4) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(entry.coins)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarHidden(true)
        }
    }
    
    // Helper function to assign colors based on rank
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1:
            return .yellow
        case 2:
            return .gray
        case 3:
            return Color(red: 0.8, green: 0.5, blue: 0.2)
        default:
            return .vittPrimary
        }
    }
}

#Preview {
    LeaderboardView()
}
