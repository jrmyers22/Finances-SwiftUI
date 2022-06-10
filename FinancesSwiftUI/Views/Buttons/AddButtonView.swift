//
//  AddButtonView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct AddButtonView: View {
    @State private var addItemScreenIsShowing = false
    @State private var settingsScreenIsShowing = false
    
    var buttonText = "No text"
    
    var body: some View {
        Button(action: {
            if buttonText == "add" {
                addItemScreenIsShowing = true
            } else if buttonText == "settings" {
                settingsScreenIsShowing = true
            }
        }) {
            ZStack {
                Circle()
                    .strokeBorder(buttonText == "add" ? Color.black : Color.gray, lineWidth: 2)
                    .frame(width: 60, height: 60)
//                Text(buttonText)
//                    .font(.title2)
//                    .foregroundColor(buttonText == "add" ? Color.black : Color.gray)
                Image(systemName: "plus")
                    .resizable()
                    .foregroundColor(buttonText == "add" ? Color.black : Color.gray)
                    .frame(width: 35, height: 35)
            }
        }.sheet(isPresented: $addItemScreenIsShowing, onDismiss: {}, content: {
            AddItemView(startCategory: "Grocery")
        })
        .sheet(isPresented: $settingsScreenIsShowing, onDismiss: {}, content: {
            SettingsView()
        })
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct AddButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddButtonView()
    }
}
