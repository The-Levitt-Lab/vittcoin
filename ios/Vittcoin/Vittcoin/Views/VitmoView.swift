//
//  VitmoView.swift
//  Vittcoin
//
//  Created by Assistant on 12/11/25.
//

import SwiftUI

struct VitmoView: View {
    @State private var recipient: String = ""
    
    // Dummy data for the list
    let contacts = [
        "Alice Smith", "Bob Jones", "Charlie Brown", 
        "David Wilson", "Eve Davis", "Frank Miller", 
        "Grace Lee", "Henry Ford", "Ivy Chen"
    ]
    
    var filteredContacts: [String] {
        if recipient.isEmpty {
            return contacts
        } else {
            return contacts.filter { $0.localizedCaseInsensitiveContains(recipient) }
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
                    Text("Ben Klosky")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 10) // Adjust for safe area
                
                Spacer()
                    .frame(height: 100)
                                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("@username", text: $recipient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Scrollable list of people
                List(filteredContacts, id: \.self) { contact in
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contact)
                                .font(.headline)
                            Text("@\(contact.replacingOccurrences(of: " ", with: "").lowercased())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    VitmoView()
}
