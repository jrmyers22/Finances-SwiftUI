//
//  ContentView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

import CoreData
struct test {
    let expItem: ExpItem
}

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    var drinksExp: Double = 0.0
    var foodExp: Double = 0.0
    var groceryExp: Double = 0.0
    var transportExp: Double = 0.0
    var miscExp: Double = 0.0
    
    var body: some View {
        VStack {
            // Top information
            HeaderView().padding(.top, 30)
            Spacer()
            
            // All Buttons
            VStack{
                // First Row of Buttons
                HStack {
                    Spacer()
                    CategoryButton(category: "Drinks", total:"\(drinksExp)", color: Color("DrinkCategoryColor"))
                        .padding(.leading)
                    Spacer()
                    CategoryButton(category: "Food", total:"\(foodExp)", color: Color("FoodCategoryColor"))
                        .padding(.trailing)
                    Spacer()
                }.padding(.bottom)
                // Second Row of Buttons
                HStack {
                    Spacer()
                    CategoryButton(category: "Grocery", total:"\(groceryExp)", color: Color("GroceryCategoryColor"))
                        .padding(.leading)
                    Spacer()
                    CategoryButton(category: "Transport", total:"\(transportExp)", color: Color("TransportationCategoryColor"))
                        .padding(.trailing)
                    Spacer()
                }.padding(.bottom)
                // Bottom
                CategoryButton(category: "Misc", total:"\(miscExp)", color: Color("MiscCategoryColor"))
            }
            Spacer()
            // Add Button
            HStack {
                Spacer()
                AddButtonView()
                    .padding(.trailing, 50)
            }
            Spacer()
        }.background(Color.white).edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
