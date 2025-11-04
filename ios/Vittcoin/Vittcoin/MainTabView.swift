//
//  MainTabView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            StandingView()
                .tabItem {
                    Label("Balance", systemImage: "dollarsign.circle.fill")
                }
            
            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart.fill")
                }
            
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "medal.fill")
                }
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                }
        }
    }
}

#Preview {
    MainTabView()
}

