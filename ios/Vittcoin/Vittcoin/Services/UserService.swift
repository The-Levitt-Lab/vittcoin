import Foundation
import Combine

struct User: Identifiable, Decodable, Hashable {
    let id: Int
    let email: String
    let fullName: String?
    let username: String?
    var balance: Int
    var giftBalance: Int
    let role: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, balance, role, username
        case giftBalance = "gift_balance"
        case fullName = "full_name"
        case createdAt = "created_at"
    }
}

struct Transaction: Identifiable, Decodable, Hashable {
    let id: Int
    let amount: Int
    let type: String
    let description: String?
    let createdAt: Date
    let userName: String?
    let recipientName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, type, description
        case createdAt = "created_at"
        case userName = "user_name"
        case recipientName = "recipient_name"
    }
    
    var isPositive: Bool {
        return amount > 0
    }
}

struct UserBalanceUpdate: Encodable {
    let amount: Int
}

struct TransferBody: Encodable {
    let recipient_id: Int
    let amount: Int
    let description: String?
    let use_gift_balance: Bool
}

@MainActor
class UserService: ObservableObject {
    static let shared = UserService()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(Config.baseURL)/users/") else {
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
        
        return try decoder.decode([User].self, from: data)
    }
    
    func fetchCurrentUser() async throws -> User {
        guard let url = URL(string: "\(Config.baseURL)/users/me") else {
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
        
        return try decoder.decode(User.self, from: data)
    }
    
    func fetchTransactions() async throws -> [Transaction] {
        guard let url = URL(string: "\(Config.baseURL)/users/me/transactions") else {
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
        
        return try decoder.decode([Transaction].self, from: data)
    }

    func fetchAllTransactions() async throws -> [Transaction] {
        guard let url = URL(string: "\(Config.baseURL)/admin/transactions") else {
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
        
        return try decoder.decode([Transaction].self, from: data)
    }
    
    func sendPayment(amount: Int, description: String?, recipientId: Int, useGiftBalance: Bool = false) async throws -> Transaction {
        guard let url = URL(string: "\(Config.baseURL)/transactions/transfer") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = TransferBody(recipient_id: recipientId, amount: amount, description: description, use_gift_balance: useGiftBalance)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 200 {
             if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let detail = errorJson["detail"] as? String {
                 throw NSError(domain: detail, code: httpResponse.statusCode)
             }
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
        
        return try decoder.decode(Transaction.self, from: data)
    }

    func addBalance(userId: Int, amount: Int) async throws -> User {
        return try await updateBalance(userId: userId, amount: amount, operation: "add")
    }
    
    func subtractBalance(userId: Int, amount: Int) async throws -> User {
        return try await updateBalance(userId: userId, amount: amount, operation: "subtract")
    }
    
    private func updateBalance(userId: Int, amount: Int, operation: String) async throws -> User {
        guard let url = URL(string: "\(Config.baseURL)/admin/users/\(userId)/balance/\(operation)") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = UserBalanceUpdate(amount: amount)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 200 {
            // Try to decode error message
             if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let detail = errorJson["detail"] as? String {
                 throw NSError(domain: detail, code: httpResponse.statusCode)
             }
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
        
        return try decoder.decode(User.self, from: data)
    }
}
