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
        ForEach(0..<expenses.count) { idx in
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
                    
                    PieChartView(values: getTotalsPerCategory(idx: idx), names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)})
                        .frame(width: Constants.Views.SCREEN_WIDTH * 0.8, height: Constants.Views.SCREEN_HEIGHT * 0.4, alignment: .center)
                        .padding(.bottom, Constants.Views.SCREEN_HEIGHT * 0.1)
                    
                }.frame(width: Constants.Views.SCREEN_WIDTH * 0.9, height: Constants.Views.SCREEN_HEIGHT * 0.5, alignment: .center)
            }.sheet(isPresented: $historyItemScreenIsShowing, onDismiss: {}, content: {
                PieChartWithList(values: getTotalsPerCategory(idx: idx), names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)})
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
    
    func getTotalsPerCategory(idx: Int) -> [Double] {
        var foodTotal: Double = 0.0
        var drinkTotal: Double = 0.0
        var groceryTotal: Double = 0.0
        var transTotal: Double = 0.0
        var miscTotal: Double = 0.0
        for expenseKey in expenses[idx].keys {
            let expCat = expenses[idx][expenseKey]?.expCategory
            let expAmt = expenses[idx][expenseKey]?.expAmount
            if expCat == "Food" {
                foodTotal += Double(expAmt!) ?? 0.0
            } else if expCat == "Drinks" {
                drinkTotal += Double(expAmt!) ?? 0.0
            } else if expCat == "Grocery" {
                groceryTotal += Double(expAmt!) ?? 0.0
            } else if expCat == "Transport" {
                transTotal += Double(expAmt!) ?? 0.0
            } else if expCat == "Misc" {
                miscTotal += Double(expAmt!) ?? 0.0
            }
        }
        // TODO: Could use this to display a "Current" pie graph
        //        expItems.forEach { item in
        //            print(item)
        //            let expCat = item.expCategory!
        //            if expCat == "Food" {
        //                foodTotal += Double(item.expAmount!) ?? 0.0
        //            } else if expCat == "Drinks" {
        //                drinkTotal += Double(item.expAmount!) ?? 0.0
        //            } else if expCat == "Grocery" {
        //                groceryTotal += Double(item.expAmount!) ?? 0.0
        //            } else if expCat == "Transport" {
        //                transTotal += Double(item.expAmount!) ?? 0.0
        //            } else if expCat == "Misc" {
        //                miscTotal += Double(item.expAmount!) ?? 0.0
        //            }
        //        }
        return [foodTotal, drinkTotal, groceryTotal, transTotal, miscTotal]
    }
}

struct CardWithPieChart_Previews: PreviewProvider {
    static var previews: some View {
        let test: [[String: PreviousExpense]] = [["12/23/23": PreviousExpense(expDate: "12/23/23", expDesc: "desc", expCategory: "Food", expAmount: "123.21")]]
        CardWithPieChart(expenses: test)
    }
}
