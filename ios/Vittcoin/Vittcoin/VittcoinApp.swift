//
//  VittcoinApp.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

@main
struct VittcoinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authService = AuthService.shared
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(isActive: $showSplash)
            } else {
                if authService.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
        }
    }
}
