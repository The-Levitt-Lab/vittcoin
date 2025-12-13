//
//  MoreView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/12/25.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: UserBalancesView()) {
                        Label("User Balances", systemImage: "person.2")
                    }
                    
                    NavigationLink(destination: AdminChallengesView()) {
                        Label("Challenges", systemImage: "trophy")
                    }
                    
                    NavigationLink(destination: AdminShopView()) {
                        Label("Shop", systemImage: "cart")
                    }
                    
                    NavigationLink(destination: AdminTransactionsView()) {
                        Label("Transactions", systemImage: "list.bullet")
                    }
                } header: {
                    Text("Management")
                }
            }
            .navigationTitle("More")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    MoreView()
}
