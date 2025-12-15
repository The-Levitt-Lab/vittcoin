import SwiftUI

struct RequestsListView: View {
    let requests: [Request]
    let currentUserId: Int?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(requests) { request in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.description ?? "Request")
                            .font(.headline)
                        
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
                            .foregroundColor(.vittPrimary)
                        
                        Text(request.status.capitalized)
                            .font(.caption)
                            .foregroundColor(request.status == "pending" ? .orange : .gray)
                    }
                }
                .padding(.vertical, 4)
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

