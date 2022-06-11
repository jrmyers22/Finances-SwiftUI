//
//  HistoryMainView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 6/9/22.
//

import SwiftUI

struct HistoryMainView: View {
    
    var body: some View {
        NavigationView {
            
            if getPreviousExpenses()["previousExpenses"]?.count ?? 0 != 0 {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(0..<(getPreviousExpenses()["previousExpenses"]!.count)) {_ in
                            CardWithPieChart(expenses: getPreviousExpenses()["previousExpenses"]!)
                        }
                    }.padding()
                }.navigationTitle(Text("History"))
            } else {
                VStack {
                    Spacer()
                    Text("No saved expense history.\nSave a snapshot of your expenses in the \"Total\" screen.")
                    Spacer()
                }
            }
        }
    }
    
    //    func displayChartsOrText(): View {
    //        if getPreviousExpenses()["previousExpenses"]?.count ?? 0 != 0 {
    //            return CardWithPieChart(expenses: getPreviousExpenses()["previousExpenses"]!)
    //        } else {
    //            return Text("No saved expense history.")
    //        }
    //    }
    
    // Get value from Documents directory defaults.json file
    func getPreviousExpenses() -> [String: [[String: PreviousExpense]]] {
        print("Retrieving expenses from previous-expenses.json")
        let url = getDocumentsDirectory().appendingPathComponent("previous-expenses.json")
        do {
            let input = try String(contentsOf: url)
            let json = input.data(using: .utf8)!
            let decoder = JSONDecoder()
            let previousExpenses = try decoder.decode([String:[[String: PreviousExpense]]].self, from: json)
            print(previousExpenses)
            return previousExpenses
        } catch {
            print("Error reading from the previous-expenses.json file")
            print(error)
        }
        
        return [:]
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct HistoryMainView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryMainView()
    }
}