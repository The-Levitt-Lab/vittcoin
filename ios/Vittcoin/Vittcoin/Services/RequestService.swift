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
    let isActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, status, description, sender, recipient
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case createdAt = "created_at"
        case isActive = "is_active"
    }
}

@MainActor
class RequestService: ObservableObject {
    static let shared = RequestService()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchRequests() async throws -> [Request] {
        guard let url = URL(string: "\(Config.baseURL)/users/me/requests") else {
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
    
    func payRequest(requestId: Int) async throws -> Request {
        guard let url = URL(string: "\(Config.baseURL)/requests/\(requestId)/pay") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 200 {
            // Try to decode error
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = errorJson["detail"] as? String {
                throw NSError(domain: detail, code: httpResponse.statusCode)
            }
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
        
        return try decoder.decode(Request.self, from: data)
    }
    
    struct CreateRequestBody: Encodable {
        let amount: Int
        let description: String?
        let recipient_id: Int
    }
    
    func createRequest(amount: Int, description: String?, recipientId: Int) async throws -> Request {
        guard let url = URL(string: "\(Config.baseURL)/requests/") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = CreateRequestBody(amount: amount, description: description, recipient_id: recipientId)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
             if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let detail = errorJson["detail"] as? String {
                 throw NSError(domain: detail, code: httpResponse.statusCode)
             }
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
        
        return try decoder.decode(Request.self, from: data)
    }
}
