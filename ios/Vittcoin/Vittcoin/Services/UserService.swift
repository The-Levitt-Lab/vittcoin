import Foundation
import Combine

struct User: Identifiable, Decodable, Hashable {
    let id: Int
    let email: String
    let fullName: String?
    let username: String?
    var balance: Int
    let role: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, balance, role, username
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
    
    enum CodingKeys: String, CodingKey {
        case id, amount, type, description
        case createdAt = "created_at"
    }
    
    var isPositive: Bool {
        return amount > 0
    }
}

struct UserBalanceUpdate: Encodable {
    let amount: Int
}

@MainActor
class UserService: ObservableObject {
    static let shared = UserService()
    
    // Using the same base URL as AuthService
    private let baseURL = "http://127.0.0.1:8000/api/v1"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users/") else {
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
        guard let url = URL(string: "\(baseURL)/users/me") else {
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
        guard let url = URL(string: "\(baseURL)/users/me/transactions") else {
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
        guard let url = URL(string: "\(baseURL)/admin/transactions") else {
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
    
    func addBalance(userId: Int, amount: Int) async throws -> User {
        return try await updateBalance(userId: userId, amount: amount, operation: "add")
    }
    
    func subtractBalance(userId: Int, amount: Int) async throws -> User {
        return try await updateBalance(userId: userId, amount: amount, operation: "subtract")
    }
    
    private func updateBalance(userId: Int, amount: Int, operation: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/admin/users/\(userId)/balance/\(operation)") else {
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
