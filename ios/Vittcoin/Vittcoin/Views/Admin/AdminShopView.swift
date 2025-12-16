//
//  AdminShopView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/12/25.
//

import SwiftUI
import PhotosUI

struct AdminShopView: View {
    @StateObject private var shopService = ShopService.shared
    @State private var items: [ShopItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Form fields
    @State private var title = ""
    @State private var description = ""
    @State private var priceString = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showAddForm = false
    
    var body: some View {
        List {
            Section(header: Text("Add New Item")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Price", text: $priceString)
                    .keyboardType(.numberPad)
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    } else {
                        Label("Select Image", systemImage: "photo")
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                Button("Add Item") {
                    addItem()
                }
                .disabled(title.isEmpty || priceString.isEmpty)
            }
            
            Section(header: Text("Existing Items")) {
                if items.isEmpty {
                    Text("No items found")
                        .foregroundColor(.gray)
                } else {
                    ForEach(items) { item in
                        HStack {
                            if let imageBase64 = item.image,
                               let imageData = Data(base64Encoded: imageBase64),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text("\(item.price) Vittcoins")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
            }
        }
        .navigationTitle("Manage Shop")
        .task {
            await loadItems()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }
    
    private func loadItems() async {
        isLoading = true
        do {
            items = try await shopService.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func addItem() {
        guard let price = Int(priceString), price > 0 else {
            errorMessage = "Price must be a positive integer"
            return
        }
        
        guard let imageData = selectedImageData else {
            errorMessage = "Please select an image"
            return
        }
        
        let imageBase64 = imageData.base64EncodedString()
        
        isLoading = true
        Task {
            do {
                let _ = try await shopService.createItem(
                    title: title,
                    description: description,
                    price: price,
                    image: imageBase64
                )
                
                // Reset form
                title = ""
                description = ""
                priceString = ""
                selectedItem = nil
                selectedImageData = nil
                
                // Reload items
                await loadItems()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = items[index]
            Task {
                do {
                    try await shopService.deleteItem(itemId: item.id)
                    await loadItems()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
