import Foundation
import AuthenticationServices
import Combine

enum AuthProvider: String, Sendable {
    case google
    case apple
}

struct LoginRequest: Encodable, Sendable {
    let token: String
    let provider: String
    let fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case token
        case provider
        case fullName = "full_name"
    }
}

struct TokenResponse: Decodable, Sendable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    // Use localhost for simulator, but standard IP for physical device if needed
    // Update this to your machine's local IP if testing on physical device.
    private let baseURL = "http://127.0.0.1:8000/api/v1" 
    
    init() {
        self.isAuthenticated = KeychainService.shared.getAccessToken() != nil
    }
    
    func login(provider: AuthProvider, idToken: String, fullName: String? = nil) async throws {
        print("📍 [AuthService] login called - provider: \(provider.rawValue)")
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            print("❌ [AuthService] Invalid URL: \(baseURL)/auth/login")
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        print("📍 [AuthService] URL: \(url)")
        
        let requestBody = LoginRequest(token: idToken, provider: provider.rawValue, fullName: fullName)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        print("📍 [AuthService] Making request to API...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📍 [AuthService] Response status: \(httpResponse.statusCode)")
        }
        
        // Debug: Print response if needed
        if let str = String(data: data, encoding: .utf8) {
            print("📍 [AuthService] Server response: \(str)")
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        let success = KeychainService.shared.saveAccessToken(tokenResponse.accessToken)
        
        if success {
            print("✅ [AuthService] Token saved to keychain, setting isAuthenticated = true")
            isAuthenticated = true
        } else {
            print("❌ [AuthService] Failed to save token to keychain")
            throw NSError(domain: "Keychain Save Failed", code: 0)
        }
    }
    
    func logout() {
        _ = KeychainService.shared.deleteAccessToken()
        isAuthenticated = false
    }
}
