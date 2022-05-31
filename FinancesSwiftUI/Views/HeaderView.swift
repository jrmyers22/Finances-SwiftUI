//
//  HeaderView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    
    @State private var categoryViewIsShowing = false
    @State private var nextPayDateAlertIsShowing = false
    @State private var dailyBreakdownViewIsShowing = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    categoryViewIsShowing = true
                }) {
                    VStack {
                        Text("Total Exp:")
                            .font(.title3).foregroundColor(Color.black)
                        Text("$\(getTotal(), specifier: "%.2f")")
                            .bold()
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(Color.black)
                    }.padding()
                        .foregroundColor(.black)
                }.sheet(isPresented: $categoryViewIsShowing, onDismiss: {}, content: {
                    CategoryView(category: "Total")
                })
                Spacer()
                Button(action: {
                    nextPayDateAlertIsShowing = true
                }) {
                    Text(getDate())
                        .font(.title3)
                        .foregroundColor(Color.black)
                }.alert(isPresented: $nextPayDateAlertIsShowing) {
                    Alert(title: Text("Pay Day: \(getNextPayDay())"), message: Text("\"Daily Breakdown\" value is based off of this date."), dismissButton: .default(Text("Gotcha")))
                }
                
                Spacer()
                Button(action: {
                    dailyBreakdownViewIsShowing = true
                }) {
                    VStack {
                        Text("Available:")
                            .font(.title3)
                            .foregroundColor(Color.black)
                        if getRemaining() < 0.0 {
                            Text("-$\(getRemaining() * -1.0, specifier: "%.2f")")
                                .bold()
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(Color.red)
                        } else {
                            Text("$\(getRemaining(), specifier: "%.2f")")
                                .bold()
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(Color.black)
                        }
                    }.padding()
                }.alert(isPresented: $dailyBreakdownViewIsShowing) {
                    Alert(title: Text("Daily Breakdown"),
                          message: Text("You can spend $\(getDailyBreakdown(), specifier: "%.2f") today."),
                          primaryButton: .default(Text("Change starting amount")) {
                            print("Changing starting amount to __")
                            var preferences = [String: String]()
                            preferences["availableAmount"] = "1000.00"
                            setPlistAvailableAmount(preferences: preferences)
                    },
                          secondaryButton: .cancel(Text("Gotcha")))
                }
            }
        }
    }
    
    private func getNextPayDay() -> String {
        var payDate = ""
        let date = getDate()
        
        // TODO: Update this to account for paydays other than 15th and the 30th
        // Didn't want to deal with the date formatter
        let month = Int(date.dropLast(6))
        let day = Int((date.dropFirst(3)).dropLast(3))!
        let year = Int(date.dropFirst(6))
        
        if day >= 1 && day < 15 {
            payDate = "\(month!)/15/\(year!)"
        } else if day >= 15 && day < 30 {
            payDate = "\(month!)/30/\(year!)"
        } else if day == 30 && month == 12 {
            payDate = "\(month! + 1)/30/\(year! + 1)"
        } else if day == 30 {
            payDate = "\(month! + 1)/30/\(year!)"
        }
        
        return payDate
    }
    
    private func getDailyBreakdown() -> Double {
        let remainingFunds = getRemaining()
        if remainingFunds < 0 { return 0.0 }
        
        let date = getDate()
        let day = Int((date.dropFirst(3)).dropLast(3))! // didn't want to deal with the dateFormatter()
        var daysLeft = 0
        
        if day >= 1 && day < 15 {
            daysLeft = 15 - day
        } else if day >= 15 && day < 30 {
            daysLeft = 30 - day
        } else if day == 15 || day == 30 {
            daysLeft = 1
        } else if day == 31 {
            daysLeft = 16
        }
        
        let dailySpend = remainingFunds / Double(daysLeft)
        
        return dailySpend
    }
    
    private func getRemaining() -> Double {
        let totalExp = getTotal()
        
        let plistAvailAmount = getPlistAvailableAmount()
        print("Got from plist: \(plistAvailAmount)")
        guard let availableAmt = Double(plistAvailAmount) else {return 0.0}
        
        let difference: Double = availableAmt - totalExp
        
        return difference
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
    
    private func getTotal() -> Double {
        var totalAmount: Double = 0.0
        for item in expItems {
            totalAmount += Double(item.expAmount ?? "0.00") ?? 0.0
        }
        return totalAmount
    }
    
    private func getDate() -> String {
        let date = Date()
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        
        // Set Date Format
        dateFormatter.dateFormat = "MM/dd/YY"
        
        // Convert Date to String
        return dateFormatter.string(from: date)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
