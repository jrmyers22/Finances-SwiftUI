//
//  ExpenseArrays.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/18/21.
//

import Foundation

class ExpenseArrays {
    struct Drinks {
        var items: [Expense] = []
        
        init(items: [Expense]) {
            self.items = items
        }
    }
    
    struct Misc {
        var items: [Expense] = []
        
        init(items: [Expense]) {
            self.items = items
        }
    }
}
