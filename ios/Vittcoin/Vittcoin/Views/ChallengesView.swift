//
//  ChallengesView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct ChallengesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background content (dimmed)
                VStack(spacing: 20) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.vittSecondary)
                        .opacity(0.3)
                    
                    Text("Challenges")
                        .font(.title)
                        .fontWeight(.bold)
                        .opacity(0.3)
                    
                    Text("Complete challenges to earn Vittcoin")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                }
                
                // Canted Banner
                Text("COMING SOON!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(
                        LinearGradient(
                            colors: [.vittSecondary, .vittPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .rotationEffect(.degrees(-12))
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ChallengesView()
}

