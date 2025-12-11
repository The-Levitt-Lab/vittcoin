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
    
    // Shop items
    let shopItems = [
        ShopItem(imageName: "theatermasks.fill", name: "Letterman Jacket", price: 2000),
        ShopItem(imageName: "tshirt.fill", name: "TLL Shirt", price: 800),
        ShopItem(imageName: "book.fill", name: "Notebook", price: 300),
        ShopItem(imageName: "backpack.fill", name: "Backpack", price: 1200),
        ShopItem(imageName: "waterbottle.fill", name: "Water Bottle", price: 400),
        ShopItem(imageName: "cup.and.saucer.fill", name: "Mug", price: 500),
        ShopItem(imageName: "tshirt", name: "School Designed by a Freak Shirt", price: 900),
        ShopItem(imageName: "bed.double.fill", name: "Fuzzy Socks", price: 600),
        ShopItem(imageName: "carrot.fill", name: "Snack Level 1", price: 250),
        ShopItem(imageName: "birthday.cake.fill", name: "Snack Level 2", price: 500),
        ShopItem(imageName: "fork.knife", name: "1-1 Meal with Steve", price: 3000),
        ShopItem(imageName: "chart.pie.fill", name: "Pie Steve", price: 1500),
        ShopItem(imageName: "figure.walk.departure", name: "Field Trip of Your Choice", price: 5000),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Shop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

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
                                    .foregroundColor(.vittPrimary)
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
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ShopView()
}

