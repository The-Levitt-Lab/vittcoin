//
//  ShopView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct ShopItemDetailView: View {
    let item: ShopItem
    let onPurchase: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 300)
                
                if let base64String = item.image,
                   let imageData = Data(base64Encoded: base64String),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260)
                } else {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.vittPrimary)
                }
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text("\(item.price) VC")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.vittPrimary)
                }
                
                if let description = item.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                onPurchase()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Purchase for \(item.price) VC")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.vittPrimary)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
    }
}

struct ShopView: View {
    @State private var shopItems: [ShopItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    // Selection and Modals
    @State private var selectedItem: ShopItem?
    @State private var showingDetail = false
    
    // Purchase state
    @State private var isPurchasing = false
    @State private var purchaseSuccessMessage: String?
    @State private var showingPurchaseSuccess = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Shop")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        if isLoading && shopItems.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 50)
                        } else if shopItems.isEmpty {
                            Text("No items available in the shop.")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                        } else {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(shopItems) { item in
                                    Button(action: {
                                        selectedItem = item
                                        showingDetail = true
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Item image
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.gray.opacity(0.1))
                                                    .aspectRatio(1, contentMode: .fit)
                                                
                                                if let base64String = item.image,
                                                   let imageData = Data(base64Encoded: base64String),
                                                   let uiImage = UIImage(data: imageData) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .padding()
                                                } else {
                                                    Image(systemName: "cart.fill")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.vittPrimary)
                                                }
                                            }
                                            
                                            // Item name (left justified)
                                            Text(item.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            // Item price
                                            Text("\(item.price) VC")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .refreshable {
                    await fetchItems()
                }
                
                if isPurchasing {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Purchasing...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                await fetchItems()
            }
            .sheet(isPresented: $showingDetail) {
                if let item = selectedItem {
                    ShopItemDetailView(item: item) {
                        Task {
                            await purchaseItem(item)
                        }
                    }
                    .presentationDetents([.fraction(0.6), .medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
            .alert("Success!", isPresented: $showingPurchaseSuccess) {
                Button("OK") { }
            } message: {
                if let message = purchaseSuccessMessage {
                    Text(message)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func fetchItems() async {
        isLoading = true
        do {
            shopItems = try await ShopService.shared.fetchItems()
            isLoading = false
        } catch {
            print("Error fetching shop items: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
            if shopItems.isEmpty {
                showingError = true
            }
        }
    }
    
    private func purchaseItem(_ item: ShopItem) async {
        // Wait a bit for the sheet to dismiss animation to start or it feels jarring
        // Or we can just start it.
        isPurchasing = true
        do {
            _ = try await ShopService.shared.purchaseItem(itemId: item.id)
            purchaseSuccessMessage = "Successfully purchased \(item.title)!"
            showingPurchaseSuccess = true
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            showingError = true
        }
        isPurchasing = false
    }
}

#Preview {
    ShopView()
}
