//
//  VitmoView.swift
//  Vittcoin
//
//  Created by Assistant on 12/11/25.
//

import SwiftUI
import UIKit

struct VitmoView: View {
    @State private var recipient: String = ""
    @State private var users: [User] = []
    @State private var selectedUser: User?
    
    var filteredUsers: [User] {
        if recipient.isEmpty {
            return users
        }
        return users.filter { user in
            let query = recipient.lowercased()
            let nameMatch = user.fullName?.lowercased().contains(query) ?? false
            let usernameMatch = user.username?.lowercased().contains(query) ?? false
            return nameMatch || usernameMatch
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Semicircle at the very top
            GeometryReader { geometry in
                Circle()
                .fill(Color.vittPrimary)
                .frame(width: geometry.size.width * 1.4, height: geometry.size.width * 1.4)
                .position(x: geometry.size.width / 2, y: -geometry.size.width * 0.15)
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: 200) // Limit the height impact of GeometryReader on the ZStack if needed, but here it's background
            
            VStack(spacing: 20) {
                // User Name in upper left
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ben Klosky")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("@ben.klosky")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 10) // Adjust for safe area
                
                Spacer()
                    .frame(height: 100)
                                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("@username", text: $recipient)
                    .padding()
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .autocapitalization(.none)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Scrollable list of people
                List(filteredUsers) { user in
                    Button(action: {
                        selectedUser = user
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullName ?? "Unknown")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                if let username = user.username {
                                    Text("@\(username)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: $selectedUser) { user in
            TransactionModalView(user: user, selectedUser: $selectedUser)
        }
        .task {
            do {
                users = try await UserService.shared.fetchUsers()
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }
}

#Preview {
    VitmoView()
}
