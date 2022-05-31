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
                    .frame(width: 90, height: 90)
                Text(buttonText)
                    .font(.title2)
                    .foregroundColor(buttonText == "add" ? Color.black : Color.gray)
            }
        }.sheet(isPresented: $addItemScreenIsShowing, onDismiss: {}, content: {
            AddItemView()
        })
        .sheet(isPresented: $settingsScreenIsShowing, onDismiss: {}, content: {
            SettingsView()
        })
    }
    
    private func getPlistAvailableAmount() -> String {
        guard let path = Bundle.main.path(forResource: "Defaults", ofType: "plist") else {return "0.0"}
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {return "0.0"}
        return (plist["availableAmount"] ?? "0.00") as String
    }
    
    private func setPlistAvailableAmount(preferences: [String: String]) {
        guard let path = Bundle.main.path(forResource: "Defaults", ofType: "plist") else {return}
        let url = URL(fileURLWithPath: path)
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(preferences) {
            if FileManager.default.fileExists(atPath: path) {
                // Update an existing plist
                try? data.write(to: url)
                print("Saved to EXISTING Defaults file: \(getPlistAvailableAmount())")
            } else {
                // Create a new plist
                FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                print("Saved to NEW Defaults file: \(getPlistAvailableAmount())")
            }
        }
    }
}

struct AddButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddButtonView()
    }
}
