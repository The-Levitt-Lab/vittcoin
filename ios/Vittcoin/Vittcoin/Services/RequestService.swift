import Foundation
import Combine

struct Request: Identifiable, Decodable, Hashable {
    let id: Int
    let senderId: Int
    let recipientId: Int
    let amount: Int
    let status: String
    let description: String?
    let createdAt: Date
    let sender: User?
    let recipient: User?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, status, description, sender, recipient
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case createdAt = "created_at"
    }
}

@MainActor
class RequestService: ObservableObject {
    static let shared = RequestService()
    
    private let baseURL = "https://api.thelevittlab.com/api/v1"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchRequests() async throws -> [Request] {
        guard let url = URL(string: "\(baseURL)/users/me/requests") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 200 {
            throw NSError(domain: "Server Error", code: httpResponse.statusCode)
        }
        
        return try decoder.decode([Request].self, from: data)
    }
}

