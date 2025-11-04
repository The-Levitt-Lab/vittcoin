//
//  ShopView.swift
//  Vittcoin
//
//  Created by Ben Klosky on 11/4/25.
//

import SwiftUI

struct ShopItem: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
    let price: Int
}

struct ShopView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Sample shop items
    let shopItems = [
        ShopItem(imageName: "tshirt.fill", name: "Vittcoin T-Shirt", price: 500),
        ShopItem(imageName: "cup.and.saucer.fill", name: "Coffee Mug", price: 250),
        ShopItem(imageName: "headphones", name: "Headphones", price: 1000),
        ShopItem(imageName: "figure.walk", name: "Fitness Tracker", price: 750),
        ShopItem(imageName: "book.fill", name: "Notebook", price: 200),
        ShopItem(imageName: "pencil.and.outline", name: "Pen Set", price: 150),
        ShopItem(imageName: "backpack.fill", name: "Backpack", price: 800),
        ShopItem(imageName: "waterbottle.fill", name: "Water Bottle", price: 300),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(shopItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            // Item image
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Image(systemName: item.imageName)
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                            }
                            
                            // Item name (left justified)
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Item price
                            Text("\(item.price) VC")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Shop")
        }
    }
}

#Preview {
    ShopView()
}

