//
//  LeaderboardView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "list.number")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Leaderboard")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("See who's on top")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Leaderboard")
        }
    }
}

#Preview {
    LeaderboardView()
}

