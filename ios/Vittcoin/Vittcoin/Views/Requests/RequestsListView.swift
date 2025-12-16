import SwiftUI

struct RequestsListView: View {
    let requests: [Request]
    let currentUserId: Int?
    @Binding var isPresented: Bool
    
    var sortedRequests: [Request] {
        requests.sorted { r1, r2 in
            let active1 = r1.isActive ?? true
            let active2 = r2.isActive ?? true
            if active1 != active2 {
                return active1
            }
            return r1.createdAt > r2.createdAt
        }
    }
    
    var body: some View {
        NavigationView {
            List(sortedRequests) { request in
                let isActive = request.isActive ?? true
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.description ?? "Request")
                            .font(.headline)
                            .foregroundColor(isActive ? .primary : .secondary)
                        
                        if request.senderId == currentUserId {
                            if let recipient = request.recipient {
                                Text("To: \(recipient.fullName ?? recipient.username ?? "Unknown")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("To: Unknown")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            if let sender = request.sender {
                                Text("From: \(sender.fullName ?? sender.username ?? "Unknown")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("From: Unknown")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(request.amount) V")
                            .font(.headline)
                            .foregroundColor(isActive ? .vittPrimary : .secondary)
                        
                        Text(request.status.capitalized)
                            .font(.caption)
                            .foregroundColor(request.status == "pending" ? (isActive ? .orange : .gray) : .gray)
                            
                        if request.status == "pending" && request.recipientId == currentUserId && isActive {
                            Button(action: {
                                Task {
                                    do {
                                        _ = try await RequestService.shared.payRequest(requestId: request.id)
                                        // Ideally reload or update local state
                                        // For now, we can rely on view refresh or dismiss
                                        isPresented = false
                                    } catch {
                                        print("Error paying request: \(error)")
                                    }
                                }
                            }) {
                                Text("Pay")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green)
                                    .cornerRadius(5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.vertical, 4)
                .opacity(isActive ? 1.0 : 0.6)
                .listRowBackground(isActive ? Color(UIColor.systemBackground) : Color(UIColor.systemGray6))
            }
            .listStyle(.plain)
            .navigationTitle("Requests")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}

#Preview {
    RequestsListView(requests: [], currentUserId: 1, isPresented: .constant(true))
}
