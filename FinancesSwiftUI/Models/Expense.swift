//
//  Expense.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import Foundation

struct Expense {
    var description: String
    var category: String
    var amount: String
    var date: Date
    
    init(description: String, category: String, amount: String, date: Date) {
        self.description = description
        self.category = category
        self.amount = amount
        self.date = date
    }
}

struct PreviousExpense: Codable {
    var expDate: String
    var expDesc: String
    var expCategory: String
    var expAmount: String
    
    init(expDate: String, expDesc: String, expCategory: String, expAmount: String) {
        self.expDate = expDate
        self.expDesc = expDesc
        self.expCategory = expCategory
        self.expAmount = expAmount
    }
}

struct PreviousExpenseArray: Codable {
    var previousExpenses: [[PreviousExpense]]
}
