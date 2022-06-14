//
//  SettingsView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/31/22.
//

import SwiftUI

struct DefaultInfo: Codable {
    var availableAmount: String
    var payDays: String
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingIncompleteAlert = false
    @State private var showingInvalidAvailAmountAlert = false
    @State private var showingInvalidPayDatesAlert = false
    
    @State private var showingDetail = false
    @State private var availableAmount: String = ""
    @State private var isEditingAvailAmt = false
    @State private var payDays: String = ""
    @State private var isEditingPayDates = false
    
    // Unicorn easter egg
    @State private var angle = 0.0
    @State private var xPos = Constants.Views.SCREEN_WIDTH * 1.5
    @State private var yPos = Constants.Views.SCREEN_HEIGHT * 0.2
    @State private var showUnicorn = true
    @State private var randomizePlacement = true
    @State private var yPosOptionsList = [Constants.Views.SCREEN_HEIGHT * 0.2, Constants.Views.SCREEN_HEIGHT * 0.45, Constants.Views.SCREEN_HEIGHT * 0.65]
    
    init() {
        UITextField.appearance().backgroundColor = .lightGray
        UITextField.appearance().textColor = .white
    }
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color.white)
                        .padding(.top, Constants.Views.SCREEN_HEIGHT * 0.05)
                        .onTapGesture(count: 2, perform: {
                            print("show unicorn")
                            if showUnicorn {
                                angle -= 35
                                xPos = Constants.Views.SCREEN_WIDTH * 0.9
                            } else {
                                angle += 35
                                xPos = Constants.Views.SCREEN_WIDTH * 1.5
                            }
                            showUnicorn.toggle()
                        })
                }
                HStack {
                    Text("Starting Amount: $")
                        .bold()
                        .font(.headline)
                        .padding(.leading)
                        .padding(.top, 50)
                        .foregroundColor(Color.white)
                    TextField(
                        getDefaultInfo()?.availableAmount ?? "",
                        text: $availableAmount
                    ) { isEditing in
                        self.isEditingAvailAmt = isEditing
                    } onCommit: {}
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(Color.white)
                        .padding(.trailing)
                        .padding(.top, 50)
                        .font(.title2)
                        .frame(width: Constants.Views.SCREEN_WIDTH * 0.55, height: Constants.Views.SCREEN_HEIGHT * 0.05, alignment: .center)
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
                        text: $payDays
                    )
                    { isEditing in
                        self.isEditingPayDates = isEditing
                    } onCommit: {}
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(Color.white)
                        .padding(.trailing)
                        .font(.title2)
                    .frame(width: Constants.Views.SCREEN_WIDTH * 0.55, height: Constants.Views.SCREEN_HEIGHT * 0.05, alignment: .center)
                }
                // Add Item Button
                Button(action: {
                    if availableAmount == "" && payDays == "" {
                        showingIncompleteAlert = true
                    } else if !availableAmount.allSatisfy({ $0.isNumber }) {
                        showingInvalidAvailAmountAlert = true
                    } else if !payDays.allSatisfy({ $0.isNumber || $0 == "," }) {
                        // Anything other than a number or a comma
                        showingInvalidPayDatesAlert = true
                    } else if availableAmount != "" && payDays == "" {
                        setDefaultInfoForProperty(keyValue: ["availableAmount": availableAmount])
                        // Show successful alert
                        showingDetail = true
                    } else if availableAmount == "" && payDays != "" {
                        setDefaultInfoForProperty(keyValue: ["payDays": payDays])
                        showingDetail = true
                    } else if availableAmount != "" && payDays != "" {
                        setDefaultInfoForProperty(keyValue: ["availableAmount": availableAmount, "payDays": payDays])
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
                .padding(.top, 50)
                Spacer()
            }.background(Color.gray).edgesIgnoringSafeArea(.all)
            Image("unicorn")
                .resizable()
                .frame(width: Constants.Views.SCREEN_WIDTH * 0.6, height: Constants.Views.SCREEN_HEIGHT * 0.4, alignment: .center)
                .rotationEffect(.degrees(angle))
                .animation(.easeIn, value: angle)
                .position(x: xPos, y: randomizePlacement ? yPosOptionsList.randomElement()! : yPos)
        }
    }
    
    // Write JSON to Documents directory defaults.json file
    //   Retrieve what's in that file as DefaultInfo object,
    //   update desired value
    //   encode to JSON again
    //   write to file
    func setDefaultInfoForProperty(keyValue: [String: String]) {
        var defaultInfo = getDefaultInfo()
        if keyValue.keys.contains("availableAmount") {
            print("Attempting to set value for: availableAmount")
            defaultInfo?.availableAmount = keyValue["availableAmount"]!
        }
        
        if keyValue.keys.contains("payDays") {
            print("Attempting to set value for: payDays")
            defaultInfo?.payDays = keyValue["payDays"]!
        }
        
        let url = getDocumentsDirectory().appendingPathComponent("defaults.json")
        
        do {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(defaultInfo) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    try jsonString.write(to: url, atomically: true, encoding: .utf8)
                    print("Successfully wrote to defaults.json")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // Get value from Documents directory defaults.json file
    func getDefaultInfo() -> DefaultInfo? {
        
        let url = getDocumentsDirectory().appendingPathComponent("defaults.json")
        do {
            let input = try String(contentsOf: url)
            let json = input.data(using: .utf8)!
            let decoder = JSONDecoder()
            let defaultInfo = try decoder.decode(DefaultInfo.self, from: json)
            print("Retrieved info from defaults.json: \(defaultInfo.availableAmount), \(defaultInfo.payDays)")
            return defaultInfo
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().preferredColorScheme(.dark)
    }
}
