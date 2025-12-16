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
    @State private var requests: [Request] = []
    @State private var showRequests = false
    @State private var currentUser: User?
    
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
                        Text(currentUser?.fullName ?? "Loading...")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text(currentUser?.username ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    
                    RequestsButtonView(requestsCount: requests.filter { $0.status == "pending" && $0.recipientId == currentUser?.id && ($0.isActive ?? true) }.count) {
                        showRequests = true
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 10) // Adjust for safe area
                
                Spacer()
                    .frame(height: 100)
                                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("username", text: $recipient)
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
                                    Text(username)
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
        .sheet(isPresented: $showRequests) {
            RequestsListView(requests: requests, currentUserId: currentUser?.id, isPresented: $showRequests)
        }
        .task {
            do {
                async let fetchedUsers = UserService.shared.fetchUsers()
                async let fetchedRequests = RequestService.shared.fetchRequests()
                async let fetchedMe = UserService.shared.fetchCurrentUser()
                
                let (usersResult, requestsResult, meResult) = try await (fetchedUsers, fetchedRequests, fetchedMe)
                
                users = usersResult
                requests = requestsResult
                currentUser = meResult
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
}

#Preview {
    VitmoView()
}
