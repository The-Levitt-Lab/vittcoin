import Foundation
import AuthenticationServices
import Combine
import PostHog

enum AuthProvider: String, Sendable {
    case google
    case apple
    case dev
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
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    // Use production URL for both dev and prod as requested
    private let baseURL = "https://api.thelevittlab.com/api/v1" 
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
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
        
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        let success = KeychainService.shared.saveAccessToken(tokenResponse.accessToken)
        
        if success {
            print("✅ [AuthService] Token saved to keychain, setting isAuthenticated = true")
            
            // Identify user in PostHog
            let user = tokenResponse.user
            var userProperties: [String: Any] = [
                "email": user.email,
                "role": user.role
            ]
            if let username = user.username {
                userProperties["username"] = username
            }
            if let name = user.fullName {
                userProperties["name"] = name
            }
            
            PostHogSDK.shared.identify(String(user.id), userProperties: userProperties)
            print("✅ [AuthService] Identified user \(user.id) in PostHog")
            
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
    
    #if DEBUG
    func devLogin(email: String) async throws {
        try await login(provider: .dev, idToken: email, fullName: nil)
    }
    #endif
}
