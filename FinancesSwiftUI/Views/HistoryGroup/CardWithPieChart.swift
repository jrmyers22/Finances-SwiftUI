//
//  CardWithPieChart.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 6/9/22.
//

import SwiftUI

struct CardWithPieChart: View {
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    @State private var historyItemScreenIsShowing = false
    
    var expenses: [[String: PreviousExpense]]
    
    var body: some View {
        ForEach(0..<expenses.count) { _ in
            Button(action: {
                historyItemScreenIsShowing = true
            }) {
                ZStack {
                    Text(getFirstExpenseDate())
                        .bold()
                        .font(.title2)
                        .padding(.leading, Constants.Views.SCREEN_WIDTH * 0.05)
                        .padding(.top, Constants.Views.SCREEN_HEIGHT * 0.4)
                        .foregroundColor(Color.gray)
                    
                    PieChartView(values: getTotalsPerCategory(), names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)})
                        .frame(width: Constants.Views.SCREEN_WIDTH * 0.8, height: Constants.Views.SCREEN_HEIGHT * 0.4, alignment: .center)
                        .padding(.bottom, Constants.Views.SCREEN_HEIGHT * 0.1)
                    
                }.frame(width: Constants.Views.SCREEN_WIDTH * 0.9, height: Constants.Views.SCREEN_HEIGHT * 0.5, alignment: .center)
            }.sheet(isPresented: $historyItemScreenIsShowing, onDismiss: {}, content: {
                PieChartWithList(values: getTotalsPerCategory(), names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)})
            })
        }
    }
    
    // TODO: Get the range of first and last dates to return as the title
    func getFirstExpenseDate() -> String {
        var expenseDates: [String] = Array(expenses[0].keys)
        for key in expenseDates {
            return String(key.prefix(10))
        }
        return ""
    }
    
    func getTotalsPerCategory() -> [Double] {
        var foodTotal: Double = 0.0
        var drinkTotal: Double = 0.0
        var groceryTotal: Double = 0.0
        var transTotal: Double = 0.0
        var miscTotal: Double = 0.0
        expItems.forEach { item in
            print(item)
            let expCat = item.expCategory!
            if expCat == "Food" {
                foodTotal += Double(item.expAmount!) ?? 0.0
            } else if expCat == "Drinks" {
                drinkTotal += Double(item.expAmount!) ?? 0.0
            } else if expCat == "Grocery" {
                groceryTotal += Double(item.expAmount!) ?? 0.0
            } else if expCat == "Transport" {
                transTotal += Double(item.expAmount!) ?? 0.0
            } else if expCat == "Misc" {
                miscTotal += Double(item.expAmount!) ?? 0.0
            }
        }
        return [foodTotal, drinkTotal, groceryTotal, transTotal, miscTotal]
    }
}

struct CardWithPieChart_Previews: PreviewProvider {
    static var previews: some View {
        let test: [[String: PreviousExpense]] = [["12/23/23": PreviousExpense(expDate: "12/23/23", expDesc: "desc", expCategory: "Food", expAmount: "123.21")]]
        CardWithPieChart(expenses: test)
    }
}
