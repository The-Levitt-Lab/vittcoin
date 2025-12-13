//
//  MainTabView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct MainTabView: View {
    // Dummy admin flag - set to true to show admin tab
    @State private var isAdmin: Bool = true
    
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
            
            VitmoView()
                .tabItem {
                    Label("Vitmo", systemImage: "paperplane.fill")
                }
            
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "medal.fill")
                }
                        
            if isAdmin {
                MoreView()
                    .tabItem {
                        Label("More", systemImage: "ellipsis.circle.fill")
                    }
            } else {
                LeaderboardView()
                    .tabItem {
                        Label("Leaderboard", systemImage: "list.number")
                    }
            }
        }
    }
}

#Preview {
    MainTabView()
}
