//
//  CardWithPieChart.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 6/9/22.
//

import SwiftUI

extension Int: Identifiable {
    public var id: Int { self }
}

struct CardWithPieChart: View {
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    @ObservedObject var numLogsThisSession: NumLogsThisSession = .shared
    
    @State private var historyItemScreenIsShowing = false
    @State var selectedExpense: Int? = nil
    
    var expenses: [[String: PreviousExpense]]
    
    var body: some View {
        ForEach(Array(expenses.enumerated()), id: \.offset) { index, element in
            ZStack {
                Text(getExpenseDateRange(idx: index))
                    .bold()
                    .font(.title2)
                    .padding(.leading, Constants.Views.SCREEN_WIDTH * 0.05)
                    .padding(.top, Constants.Views.SCREEN_HEIGHT * 0.4)
                    .foregroundColor(Color.gray)
                
                PieChartView(values: getTotalsPerCategory(idx: index), names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)})
                    .frame(width: Constants.Views.SCREEN_WIDTH * 0.8, height: Constants.Views.SCREEN_HEIGHT * 0.4, alignment: .center)
                    .padding(.bottom, Constants.Views.SCREEN_HEIGHT * 0.1)
                
            }.frame(width: Constants.Views.SCREEN_WIDTH * 0.9, height: Constants.Views.SCREEN_HEIGHT * 0.5, alignment: .center)
                .onTapGesture(count: 1) {
                    historyItemScreenIsShowing = true
                    self.selectedExpense = index
                }
                .sheet(item: self.$selectedExpense, content: { selectedExpense in
                    // INFO: Uses .sheet(item: Binding...) instead of .sheet(isPresented: Binding...) because this makes the
                    //       sheet re-draw when the item's state is changed. isPresented does not redraw.
                    PieChartWithList(values: getTotalsPerCategory(idx: selectedExpense), names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)}, title: getExpenseDateRange(idx: index), expenseGroupIdx: selectedExpense)
                })
        }
    }
    
    func getExpenseDateRange(idx: Int) -> String {
        let expenseDates: [String] = Array(expenses[idx].keys.sorted())
        var returnStr = ""
        if expenseDates.count > 1 && expenseDates[0].prefix(10) != expenseDates[expenseDates.count - 1].prefix(10) {
            // return the range of first expenseDate to last expenseDate
            let year1 = expenseDates[0].prefix(4)
            let month1 = expenseDates[0].prefix(7).suffix(2)
            let day1 = expenseDates[0].prefix(10).suffix(2)
            let year2 = expenseDates[expenseDates.count - 1].prefix(4)
            let month2 = expenseDates[expenseDates.count - 1].prefix(7).suffix(2)
            let day2 = expenseDates[expenseDates.count - 1].prefix(10).suffix(2)
            returnStr = "\(month1)/\(day1)/\(year1) - \(month2)/\(day2)/\(year2)"
        } else {
            // return just the first date
            let year = expenseDates[0].prefix(4)
            let month = expenseDates[0].prefix(7).suffix(2)
            let day = expenseDates[0].prefix(10).suffix(2)
            returnStr = "\(month)/\(day)/\(year)"
        }
        
        // format the dates
        return returnStr
    }
    
    func getTotalsPerCategory(idx: Int) -> [Double] {
        var foodTotal: Double = 0.0
        var drinkTotal: Double = 0.0
        var groceryTotal: Double = 0.0
        var transTotal: Double = 0.0
        var miscTotal: Double = 0.0
        if idx > (expenses.count - 1) {
            return []
        }
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
