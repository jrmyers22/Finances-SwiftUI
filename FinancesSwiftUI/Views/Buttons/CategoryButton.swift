//
//  CategoryButton.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct CategoryButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    @State private var categoryViewIsShowing = false
    
    var category: String
    var total: String
    var color: Color?
    
    var body: some View {
        Button(action: {
            categoryViewIsShowing = true
        }) {
            ZStack {
                if getCategoryTotal(category: category) == 0.0 {
                    RoundedRectangle(cornerRadius: 25.0)
                        .strokeBorder(color ?? Color.black, lineWidth: 2)
                        .frame(width: 125, height: 125)
                    VStack {
                        Text(category)
                            .bold()
                            .foregroundColor(color ?? Color.black)
                            .font(.title3)
                            Text(formatCategoryTotal())
                            .foregroundColor(decideColor(category: category))
                    }
                } else {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(color ?? Color.black)
                        .frame(width: 125, height: 125)
                    VStack {
                        Text(category)
                            .bold()
                            .foregroundColor(Color.white)
                            .font(.title3)
                            Text(formatCategoryTotal())
                                .foregroundColor(Color.white)
                    }
                }
            }
        }
        .sheet(isPresented: $categoryViewIsShowing, onDismiss: {}, content: {
            CategoryView(category: category)
        })
    }
    
    func getCategoryTotal(category: String) -> Double {
        var amt: Double = 0.0
        expItems.forEach { item in
            if category == Constants.Categories.DRINKS {
                if item.expCategory == Constants.Categories.DRINKS {
                    let expAmt: Double = Double(item.expAmount!) ?? 0.0
                    amt += expAmt
                }
            } else if category == Constants.Categories.FOOD {
                if item.expCategory == Constants.Categories.FOOD {
                    let expAmt: Double = Double(item.expAmount!) ?? 0.0
                    amt += expAmt
                }
            } else if category == Constants.Categories.GROCERY {
                if item.expCategory == Constants.Categories.GROCERY {
                    let expAmt: Double = Double(item.expAmount!) ?? 0.0
                    amt += expAmt
                }
            } else if category == Constants.Categories.TRANSPORT {
                if item.expCategory == Constants.Categories.TRANSPORT {
                    let expAmt: Double = Double(item.expAmount!) ?? 0.0
                    amt += expAmt
                }
            } else if category == Constants.Categories.MISC {
                if item.expCategory == Constants.Categories.MISC {
                    let expAmt: Double = Double(item.expAmount!) ?? 0.0
                    amt += expAmt
                }
            }
        }
        return amt
    }
    
    func formatCategoryTotal() -> String {
        let total: Double = getCategoryTotal(category: category)
        if String(total) == "0.0" {
            return "---"
        }
        
        if (total.truncatingRemainder(dividingBy: 1.0)) == 0.0 {
            // DOES NOT have numbers in the decimal places,
            // add a zero after the result
            return "$\(String(total))0"
        }
        return "$" + String(format: "%.2f", total)
    }
}

struct CategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        CategoryButton(category: "Drinks", total: "100.0")
    }
}
