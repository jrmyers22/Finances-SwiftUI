//
//  AddButtonView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct AddButtonView: View {
    @State private var addItemScreenIsShowing = false
    
    var body: some View {
        Button(action: {
            addItemScreenIsShowing = true
        }) {
            ZStack {
                Circle()
                    .strokeBorder(Color.black, lineWidth: 2)
                    .frame(width: 90, height: 90)
                Text("add")
                    .font(.title2)
                    .foregroundColor(Color.black)
            }
        }.sheet(isPresented: $addItemScreenIsShowing, onDismiss: {}, content: {
            AddItemView()
        })
    }
}

struct AddButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddButtonView()
    }
}
