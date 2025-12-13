import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.vittPrimary.opacity(0.8), Color.vittSecondary.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 20) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    
                    Text("Vittcoin")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    // Sign in with Apple Button
                    SignInWithAppleButton(
                        onRequest: { request in
                            print("📍 [SIWA] onRequest called - requesting scopes")
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            print("📍 [SIWA] onCompletion called with result: \(result)")
                            handleAppleSignIn(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
                }
                
                #if DEBUG
                Button(action: {
                    Task {
                        isLoading = true
                        do {
                            try await authService.devLogin(email: "benklosky@uchicago.edu")
                            isLoading = false
                        } catch {
                            isLoading = false
                            errorMessage = "Dev login failed: \(error.localizedDescription)"
                        }
                    }
                }) {
                    Text("Developer Login")
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.top, 20)
                #endif
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        print("📍 [SIWA] handleAppleSignIn called")
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authResults):
            print("📍 [SIWA] Success - credential type: \(type(of: authResults.credential))")
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                print("📍 [SIWA] Got AppleIDCredential - user: \(appleIDCredential.user)")
                
                guard let identityTokenData = appleIDCredential.identityToken,
                      let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
                    print("❌ [SIWA] Failed to get identity token")
                    isLoading = false
                    errorMessage = "Failed to fetch identity token"
                    return
                }
                
                print("📍 [SIWA] Got identity token (length: \(identityTokenString.count))")
                
                let fullName = [
                    appleIDCredential.fullName?.givenName,
                    appleIDCredential.fullName?.familyName
                ]
                .compactMap { $0 }
                .joined(separator: " ")
                
                let nameToSend = fullName.isEmpty ? nil : fullName
                print("📍 [SIWA] Full name: \(nameToSend ?? "nil")")
                
                Task {
                    do {
                        print("📍 [SIWA] Calling authService.login...")
                        try await authService.login(provider: .apple, idToken: identityTokenString, fullName: nameToSend)
                        isLoading = false
                        print("✅ [SIWA] Login successful!")
                    } catch {
                        print("❌ [SIWA] Login failed: \(error)")
                        isLoading = false
                        errorMessage = "Login failed: \(error.localizedDescription)"
                    }
                }
                
            default:
                print("❌ [SIWA] Invalid credential type: \(type(of: authResults.credential))")
                isLoading = false
                errorMessage = "Invalid credential type"
            }
            
        case .failure(let error):
            print("❌ [SIWA] Sign in failed: \(error)")
            isLoading = false
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    LoginView()
}
