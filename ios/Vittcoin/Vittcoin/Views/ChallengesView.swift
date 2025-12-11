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
            VStack(spacing: 20) {
                Image(systemName: "medal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.vittSecondary)
                
                Text("Challenges")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Complete challenges to earn Vittcoin")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ChallengesView()
}

