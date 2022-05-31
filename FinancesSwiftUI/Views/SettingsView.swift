//
//  SettingsView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/31/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingIncompleteAlert = false
    @State private var showingInvalidAvailAmountAlert = false
    @State private var showingInvalidPayDatesAlert = false
    
    @State private var showingDetail = false
    @State private var availableAmount: String = ""
    @State private var isEditingAvailAmt = false
    @State private var payDates: String = ""
    @State private var isEditingPayDates = false
    
    init() {
        UITextField.appearance().backgroundColor = .lightGray
        UITextField.appearance().textColor = .white
    }
    
    var body: some View {
        VStack {
            ZStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(Color.white)
                    .padding()
            }
            Spacer()
            HStack {
                Text("Available Amount: $")
                    .bold()
                    .font(.headline)
                    .padding(.leading)
                    .foregroundColor(Color.white)
                TextField(
                    getPlistValue(key: "availableAmount"),
                    text: $availableAmount
                ) { isEditing in
                    self.isEditingAvailAmt = isEditing
                } onCommit: {}
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.white)
                .padding(.trailing)
                .font(.title2)
            }
            HStack {
                Text("Pay Dates:                  ")
                    .bold()
                    .font(.headline)
                    .padding(.leading)
                    .foregroundColor(Color.white)
                Spacer()
                TextField(
                    "ex. 1st, 15th = 1,15",
                    text: $payDates
                ) { isEditing in
                    self.isEditingPayDates = isEditing
                } onCommit: {}
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.white)
                .padding(.trailing)
                .font(.title2)
            }
            Spacer()
            // Add Item Button
            Button(action: {
                let existingAvailableAmount = getPlistValue(key: "availableAmount")
                let existingPayDays = getPlistValue(key: "payDays")
                if availableAmount == "" && payDates == "" {
                    showingIncompleteAlert = true
                } else if !availableAmount.allSatisfy({ $0.isNumber }) {
                    showingInvalidAvailAmountAlert = true
                } else if !payDates.allSatisfy({ $0.isNumber || $0 == "," }) {
                    // Anything other than a number or a comma
                    showingInvalidPayDatesAlert = true
                } else if availableAmount != "" && payDates == "" {
                    setPlistProperty(property: ["availableAmount": availableAmount, "payDays": existingPayDays])
                    // Show successful alert
                    showingDetail = true
                } else if availableAmount == "" && payDates != "" {
                    setPlistProperty(property: ["payDays": payDates, "availableAmount": existingAvailableAmount])
                    showingDetail = true
                } else if availableAmount != "" && payDates != "" {
                    setPlistProperty(property: ["payDays": payDates, "availableAmount": availableAmount])
                    showingDetail = true
                }
            }) {
                Text("Update")
                    .bold()
                    .font(.title3)
                    
                    .padding(20.0)
                    .background(
                        Color.green
                    )
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
            }
            .alert(isPresented: $showingIncompleteAlert) {
                Alert(title: Text("Not so fast!"), message: Text("Either available amount or pay dates must be filled in."), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $showingInvalidAvailAmountAlert) {
                Alert(title: Text("Not so fast!"), message: Text("Available Amount should only include numbers, no other characters."), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $showingInvalidPayDatesAlert) {
                Alert(title: Text("Not so fast!"), message: Text("Pay dates should be numbers (dates) separated by commas. For example, if you get paid on the 1st and 15th you would enter \"1,15\""), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $showingDetail) {
                
                return availableAmount != "" ? Alert(title: Text("Value Updated"), message: Text("Tap the \"Available\" text for the number to refresh"), dismissButton: .default(Text("Gotcha")) {
                    presentationMode.wrappedValue.dismiss()
                }) : Alert(title: Text("Value Updated"), message: Text("Pay Dates refreshed."), dismissButton: .default(Text("Gotcha")) {
                    
                    presentationMode.wrappedValue.dismiss()
                })
            }
            .padding(.bottom, 50)
        }.background(Color.gray).edgesIgnoringSafeArea(.all)
    }
    
    private func getPlistValue(key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Defaults", ofType: "plist") else {return "0.0"}
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {return "0.0"}
        return (plist[key] ?? "") as String
    }
    
    private func setPlistProperty(property: [String: String]) {
        guard let path = Bundle.main.path(forResource: "Defaults", ofType: "plist") else {return}
        let url = URL(fileURLWithPath: path)
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(property) {
            if FileManager.default.fileExists(atPath: path) {
                // Update an existing plist
                try? data.write(to: url)
                print("Saved to EXISTING Defaults file: \(getPlistValue(key: "availableAmount"))")
            } else {
                // Create a new plist
                FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                print("Saved to NEW Defaults file: \(getPlistValue(key: "availableAmount"))")
            }
        }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().preferredColorScheme(.dark)
    }
}
