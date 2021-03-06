import SwiftUI

@available(OSX 10.15, *)
public struct PieChartWithList: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var numLogsThisSession: NumLogsThisSession = .shared
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    public let values: [Double]
    public let names: [String]
    public let formatter: (Double) -> String
    public let title: String
    public let expenseGroupIdx: Int
    
    public var colors: [Color]
    public var backgroundColor: Color
    
    public var widthFraction: CGFloat
    public var innerRadiusFraction: CGFloat
    
    @State private var activeIndex: Int = -1
    
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: String(format: "%.0f%%", value * 100 / sum), color: self.colors[i]))
            endDeg += degrees
        }
        return tempSlices
    }
    
    public init(values:[Double], names: [String], formatter: @escaping (Double) -> String, colors: [Color] = [Color("FoodCategoryColor"), Color("DrinkCategoryColor"), Color("GroceryCategoryColor"), Color("TransportationCategoryColor"), Color("MiscCategoryColor")], backgroundColor: Color = Color.white, widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.60, title: String, expenseGroupIdx: Int){
        self.values = values
        self.names = names
        self.formatter = formatter
        self.title = title
        self.expenseGroupIdx = expenseGroupIdx
        
        self.colors = colors
        self.backgroundColor = backgroundColor
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
    }
    
    public var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ZStack {
                        ForEach(0..<self.values.count){ i in
                            PieSlice(pieSliceData: self.slices[i])
                        }
                        .frame(width: widthFraction * Constants.Views.SCREEN_WIDTH, height: widthFraction * Constants.Views.SCREEN_WIDTH)
                        Circle()
                            .fill(self.backgroundColor)
                            .frame(width: widthFraction * Constants.Views.SCREEN_WIDTH * innerRadiusFraction, height: widthFraction * Constants.Views.SCREEN_WIDTH * innerRadiusFraction)
                        
                        VStack {
                            Text(self.activeIndex == -1 ? "Total" : names[self.activeIndex])
                                .font(.title)
                                .foregroundColor(Color.gray)
                            Text(self.formatter(self.activeIndex == -1 ? values.reduce(0, +) : values[self.activeIndex]))
                                .font(.title)
                        }
                        
                    }

                    HStack {
                        Text(title)
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                    PieChartRows(colors: self.colors, names: self.names, values: self.values.map { self.formatter($0) }, percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
                    Divider().padding()
                    Button(action: {
                        simpleSuccess()
                        removePreviousExpenseFromJSON(expenseGroupIdx: expenseGroupIdx)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Delete")
                            .foregroundColor(Color.red)
                            .fontWeight(.bold)
                    }
                }
                .background(self.backgroundColor)
                .foregroundColor(Color.black)
            }.padding()
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("Simple success vibration")
    }
    
    private func removePreviousExpenseFromJSON(expenseGroupIdx: Int) {
        
        let prevExpenses = getPreviousExpenses()
        var existingList: [Any] = prevExpenses["previousExpenses"]!
        let toRemove = abs((expenseGroupIdx - (existingList.count - 1)))
        if toRemove > existingList.count - 1 { return }
        existingList.remove(at: toRemove)
        var prevExpensesJSON: [String: Any] = [:]
        prevExpensesJSON["previousExpenses"] = existingList
        
        let url = getDocumentsDirectory().appendingPathComponent("previous-expenses.json")
        do {
            print("Serializing JSON data...")
            let jsonData = try JSONSerialization.data(withJSONObject: prevExpensesJSON, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            print("JSON STRING:")
            print (jsonString)
            try jsonString.write(to: url, atomically: true, encoding: .utf8)
            self.numLogsThisSession.count += 1
            print("Successfully wrote to previous-expenses.json")
        } catch {
            let error = error as NSError?
            fatalError("Unresolved Error: \(String(describing: error))")
        }
    }
    
    func updatePreviousExpenses() {
        print("UPDATING previous expenses json")
        // Get existing expItems, write them to a JSON array
        var expenseItemsAsJSON: [String: Any] = [:]
        for expense in expItems {
            var expenseItem: [String: String] = [:]
            expenseItem["expAmount"] = expense.expAmount
            expenseItem["expCategory"] = expense.expCategory
            expenseItem["expDate"] = String(describing: expense.expDate!)
            expenseItem["expDesc"] = expense.expDesc
            expenseItemsAsJSON["\(String(describing: expense.expDate!))"] = expenseItem
        }
        
        // Get the existing previous-expenses.json
        let prevExpenses = getPreviousExpenses()
        
        var prevExpensesJSON: [String: Any] = [:]
        if prevExpenses.isEmpty {
            // If nil,
            //    add JSON array to a parent array called "previous-expenses"
            //    write "previous-expenses" to file
            prevExpensesJSON["previousExpenses"] = [expenseItemsAsJSON]
        } else {
            var existingList: [Any] = prevExpenses["previousExpenses"]!
            existingList.append(expenseItemsAsJSON)
            prevExpensesJSON["previousExpenses"] = existingList
        }
        
        let url = getDocumentsDirectory().appendingPathComponent("previous-expenses.json")
        do {
            print("Serializing JSON data...")
            let jsonData = try JSONSerialization.data(withJSONObject: prevExpensesJSON, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            print("JSON STRING:")
            print (jsonString)
            try jsonString.write(to: url, atomically: true, encoding: .utf8)
            print("Successfully wrote to previous-expenses.json")
//            self.numLogsThisSession.count += 1
        } catch {
            let error = error as NSError?
            fatalError("Unresolved Error: \(String(describing: error))")
        }
    }

    // Get value from Documents directory defaults.json file
    func getPreviousExpenses() -> [String: [Any]] {
        print("Retrieving expenses from previous-expenses.json")
        let url = getDocumentsDirectory().appendingPathComponent("previous-expenses.json")
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            let jsonAsStr = jsonResult as? [String: [Any]] ?? [:]
            return jsonAsStr
        } catch {
            print("Error reading from the previous-expenses.json file")
            print(error)
        }
        
        return [:]
    }

    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct PieChartRows: View {
    var colors: [Color]
    var names: [String]
    var values: [String]
    var percents: [String]
    
    var body: some View {
        VStack {
            ForEach(0..<self.values.count){ i in
                Button (action: {
                    // TODO: Expand list
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .strokeBorder(self.colors[i], lineWidth: 2)
                            .frame(width: Constants.Views.SCREEN_WIDTH * 0.95,
                                   height: Constants.Views.SCREEN_HEIGHT * 0.075)
                        HStack {
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(self.colors[i])
                                .frame(width: 20, height: 20)
                            Text(self.names[i])
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(self.values[i])
                                Text(self.percents[i])
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct PieChartWithList_Previews: PreviewProvider {
    static var previews: some View {
        PieChartWithList(values: [1300, 500, 300, 100, 200], names: ["Food", "Drink", "Grocery", "Transportation", "Misc"], formatter: {value in String(format: "$%.2f", value)}, title: "Testing", expenseGroupIdx: 0)
    }
}

