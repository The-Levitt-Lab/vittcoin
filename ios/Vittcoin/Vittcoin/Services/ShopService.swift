import Foundation
import Combine

struct ShopItem: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String?
    let price: Int
    let image: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, image
        case createdAt = "created_at"
    }
}

struct ShopItemCreate: Encodable {
    let title: String
    let description: String
    let price: Int
    let image: String?
}

@MainActor
class ShopService: ObservableObject {
    static let shared = ShopService()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchItems() async throws -> [ShopItem] {
        guard let url = URL(string: "\(Config.baseURL)/shop/") else {
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
        
        return try decoder.decode([ShopItem].self, from: data)
    }
    
    func createItem(title: String, description: String, price: Int, image: String?) async throws -> ShopItem {
        guard let url = URL(string: "\(Config.baseURL)/shop/") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let itemCreate = ShopItemCreate(title: title, description: description, price: price, image: image)
        request.httpBody = try JSONEncoder().encode(itemCreate)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 201 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = errorJson["detail"] as? String {
                throw NSError(domain: detail, code: httpResponse.statusCode)
            }
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
        
        return try decoder.decode(ShopItem.self, from: data)
    }
    
    func deleteItem(itemId: Int) async throws {
        guard let url = URL(string: "\(Config.baseURL)/shop/\(itemId)") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid Response", code: 0)
        }
        
        if httpResponse.statusCode != 204 {
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
    }
    
    func purchaseItem(itemId: Int) async throws -> Transaction {
        guard let url = URL(string: "\(Config.baseURL)/shop/\(itemId)/purchase") else {
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
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = errorJson["detail"] as? String {
                throw NSError(domain: detail, code: httpResponse.statusCode)
            }
            throw NSError(domain: "Server Error: \(httpResponse.statusCode)", code: httpResponse.statusCode)
        }
        
        return try decoder.decode(Transaction.self, from: data)
    }
}
