//
//  ExpenseRowView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct ExpenseRowView: View {
    //    let date: Date
    //    let category: String
    //    let amount: String
    let accentColor: Color
    let expense: ExpItem
    
    var body: some View {
        
        HStack {
            HStack {
                Text(expense.expDate!, style: .date)
                    .bold()
                    .font(.title3)
                    .padding(.leading)
                    .foregroundColor(accentColor)
                Text("|")
                Text(expense.expDesc!)
                    .font(.title2)
                    .padding(.top)
                    .padding(.bottom)
            }
            Spacer()
            Text("$\(expense.expAmount!)")
                .font(.title3)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
        }.background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(accentColor.opacity(0.4), lineWidth: 2)
                .frame(width: 380, height: 60)
                .padding(7)
                .background(Color.white).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        ).foregroundColor(Color.black).background(Color.white).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

//struct ExpenseRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpenseRowView(expense: ExpItem)
//    }
//}
