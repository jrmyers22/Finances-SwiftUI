//
//  HeaderView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI
import Foundation

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
                    Alert(title: Text("Next Pay Day: \(getNextPayDay())"), message: Text("\"Daily Breakdown\" value is based off of this date."), dismissButton: .default(Text("Gotcha")))
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
                    let dailyBreakdown = getDailyBreakdown()
                    return Alert(title: Text("Daily Breakdown: $\(dailyBreakdown, specifier: "%.2f")"),
                                 message: Text("You can spend $\(dailyBreakdown, specifier: "%.2f") today. You can change initial Available Amount in the Settings screen."),
                                 dismissButton: .default(Text("Gotcha")))
                }
            }
        }
    }
    
    // Returns format like ["1", "15"]
    private func getPayDays() -> [String] {
        let payDaysString = getDefaultInfo()?.payDays
        var payDaysArray: [String] = []
        if payDaysString!.contains(",") {
            payDaysArray = payDaysString!.components(separatedBy: ",")
        } else {
            payDaysArray = [payDaysString!]
        }
        return payDaysArray
    }
    
    private func getNextPayDay() -> String {
        var payDate = ""
        let date = getDate()
        let payDayArray = getPayDays()
        if payDayArray.count == 1 && payDayArray[0] == "" {
            print("Invalid payday array")
            return ""
        }
        
        // TODO: Update this to account for paydays other than 15th and the 30th
        // Didn't want to deal with the date formatter
        let month = Int(date.dropLast(6))
        let day = Int((date.dropFirst(3)).dropLast(3))!
        let year = Int(date.dropFirst(6))
        var nextPayDay: Int = -1
        
        for payday in payDayArray {
            if Int(payday)! > day {
                nextPayDay = Int(payday)!
                break
            }
        }
        
        if nextPayDay != -1 {
            payDate = "\(month!)/\(nextPayDay)/\(year!)"
        } else if nextPayDay == -1 && month! < 12 {
            payDate = "\(month! + 1)/\(payDayArray[0])/\(year!)"
        } else if nextPayDay == -1 && month! == 12 {
            payDate = "\(month! + 1)/\(payDayArray[0])/\(year! + 1)"
        }
        
        return payDate
    }
    
    private func getDailyBreakdown() -> Double {
        let remainingFunds = getRemaining()
        if remainingFunds < 0 { return 0.0 }
        
        let dateStr = getDate()
        let dateStrItems = dateStr.components(separatedBy: "/")
        let day = Int(dateStr.components(separatedBy: "/")[1])! // didn't want to deal with the dateFormatter()
        
        let nextPayDayString = getNextPayDay()
        let dateItems = nextPayDayString.components(separatedBy: "/")
        let nextPayDay = Int(dateItems[1])!
        
        let dateComponents = DateComponents(year: Int(dateStrItems[2]), month: Int(dateStrItems[0]))
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        let numDaysLeftInCurrentMonth = numDays - Int(dateStrItems[1])!
        
        var daysLeft = 0
        if day < nextPayDay {
            daysLeft = nextPayDay - day
        } else if day >= nextPayDay {
            daysLeft = nextPayDay + numDaysLeftInCurrentMonth
        }
        
        let dailySpend = remainingFunds / Double(daysLeft)
        
        return dailySpend
    }
    
    private func getRemaining() -> Double {
        let totalExp = getTotal()
        
        let storedAvailAmount = getDefaultInfo()?.availableAmount
        print("Got availAmount from storage: \(storedAvailAmount!)")
        guard let availableAmt = Double(storedAvailAmount!) else {return 0.0}
        
        let difference: Double = availableAmt - totalExp
        
        return difference
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

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
