//
//  ContentView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    var drinksExp: Double = 0.0
    var foodExp: Double = 0.0
    var groceryExp: Double = 0.0
    var transportExp: Double = 0.0
    var miscExp: Double = 0.0
    
    init() {
//        UITabBar.appearance().backgroundColor = UIColor.lightGray
        if getDefaultInfo() == nil {
            setDefaultInfoForProperty(keyValue: ["availableAmount": "500.00", "payDays":"1,15"])
        }
    }
    
    var body: some View {
        TabView {
            VStack {
                
                // Top information
                HeaderView().padding(.top, 30)
                
                
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
//                    Spacer()
//                    AddButtonView(buttonText: "settings")
                    Spacer()
                    AddButtonView(buttonText: "add")
                    Spacer()
                }
                Spacer()
            }
            .tabItem {
                Label("Expenses", systemImage: "square.stack")
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            HistoryMainView()
                .tabItem {
                    Label("History", systemImage: "chart.pie")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.black)
    }
    
    struct DefaultInfo: Codable {
        var availableAmount: String = "500.00"
        var payDays: String = "1,15"
    }
    
    // Write JSON to Documents directory defaults.json file
    //   Retrieve what's in that file as DefaultInfo object,
    //   update desired value
    //   encode to JSON again
    //   write to file
    func setDefaultInfoForProperty(keyValue: [String: String]) {
        var defaultInfo = DefaultInfo()
        if keyValue.keys.contains("availableAmount") {
            print("Attempting to set value for: availableAmount")
            defaultInfo.availableAmount = keyValue["availableAmount"]!
        }
        
        if keyValue.keys.contains("payDays") {
            print("Attempting to set value for: payDays")
            defaultInfo.payDays = keyValue["payDays"]!
        }
        
        let url = getDocumentsDirectory().appendingPathComponent("defaults.json")
        
        do {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(defaultInfo) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    try jsonString.write(to: url, atomically: true, encoding: .utf8)
                    print("Successfully wrote to defaults.json")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // Get value from Documents directory defaults.json file
    func getDefaultInfo() -> DefaultInfo? {
        
        let url = getDocumentsDirectory().appendingPathComponent("defaults.json")
        do {
            let input = try String(contentsOf: url)
            let json = input.data(using: .utf8)!
            let decoder = JSONDecoder()
            let defaultInfo = try decoder.decode(DefaultInfo.self, from: json)
            print("Retrieved info from defaults.json: \(defaultInfo.availableAmount), \(defaultInfo.payDays)")
            return defaultInfo
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
