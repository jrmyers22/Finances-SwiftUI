//
//  CategoryView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI
import AlertToast

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    @ObservedObject var numLogsThisSession: NumLogsThisSession = .shared
    
    @State private var addItemScreenIsShowing = false
    @State var showingDeleteAllAlert = false
    @State var showingSaveToHistoryAlert = false
    @State var successfulSave = false
    
    @State var expenseToEdit: Expense?
    
    var category: String!
    
    init(category: String) {
        self.category = category
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .white
        UITableView.appearance().backgroundColor = .white
    }
    
    var body: some View {
        let accentColor = decideColor(category: category)
        ZStack {
            VStack {
                ZStack {
                    Text(category)
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color.white)
                }
                NavigationView {
                    List {
                        // need \.self when iterating through a non-constant range of items
                        ForEach(0..<expItems.count, id: \.self) { i in
                            let expCat = expItems[i].expCategory!
                            Group {
                                if expCat == category {
                                    ExpenseRowView(accentColor: accentColor, expense: expItems[i])
                                } else if category == Constants.Categories.TOTAL {
                                    ExpenseRowView(accentColor: decideColor(category: expItems[i].expCategory!), expense: expItems[i])
                                }
                            }.onTapGesture {
                                print("Should display an edit view here...")
                                if expItems[i].id == nil {
                                    expItems[i].id = UUID().uuidString
                                }
                                expenseToEdit = Expense(id: expItems[i].id!,
                                                        description: expItems[i].expDesc!,
                                                        category: expItems[i].expCategory!,
                                                        amount: expItems[i].expAmount!,
                                                        date: expItems[i].expDate!)
                            }
                            .sheet(item: $expenseToEdit,
                                    onDismiss: nil) { expense in
                                EditItemView(startCategory: expense.category,
                                             id: expense.id,
                                             description: expense.description,
                                             category: expense.category,
                                             amount: expense.amount)
                             }
                        }.onDelete(perform: deleteExpItems)
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .navigationBarItems(leading: Text("Testing"))
                }
            }.padding(.top, 30).background(accentColor).edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                if category == "Total" {
                    VStack {
                        // Show the Save button
                        Button(action: {
                            // Show an alert which asks if they want to
                            //     save to the History view
                            if expItems.count > 0 {
                                showingSaveToHistoryAlert = true
                            }
                        }) {
                            Image(systemName: "tag")
                                .resizable()
                                .frame(width: Constants.Views.SCREEN_WIDTH * 0.075, height: Constants.Views.SCREEN_WIDTH * 0.075, alignment: .center)
                                .foregroundColor(Color.white)
                                .padding(.top, 40)
                                .padding(.trailing, 30)
                        }
                        .alert(isPresented: $showingSaveToHistoryAlert) {
                            Alert(title: Text("Save to History?"),
                                  message: Text("This date range will be available in the \"History\" tab."),
                                  primaryButton: .default(Text("Save"), action: {
                                        print("Saving all expenses to file")
                                        updatePreviousExpenses()
                                        simpleSuccess()
                                        successfulSave = true
                                    }),
                                  secondaryButton: .cancel(Text("Cancel")))
                        }
                        Spacer()
                    }
                } else {
                    // Show the Add button
                    AddButton(category: category)
                }
            }.toast(isPresenting: $successfulSave){
                
                // `.alert` is the default displayMode
                // TODO: Haptic Feedback "Success"
                AlertToast(type: .regular, title: "Saved!")
                
                //Choose .hud to toast alert from the top of the screen
                //AlertToast(displayMode: .hud, type: .regular, title: "Message Sent!")
            }
            // Floating "Remove all expenses" button
            if category == "Total" {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(.gray)
                                .frame(width: Constants.Views.SCREEN_WIDTH * 0.2, height: Constants.Views.SCREEN_WIDTH * 0.2)
                            Image(systemName: "list.bullet.indent")
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 35, height: 25)
                                .onTapGesture(count: 1) {
                                    showingDeleteAllAlert = true
                                }
                        }.padding(.trailing, 50)
                    }.padding(.bottom, 50)
                }.alert(isPresented: $showingDeleteAllAlert) {
                    Alert(title: Text("Delete all expenses?"),
                          message: Text("This will remove all expenses on this screen. Your History will not be affected."),
                          primaryButton: .destructive(Text("Delete All"), action: {
                                print("Deleting all expenses")
                                // delete all expenses
                                simpleSuccess()
                                withAnimation {
                                    deleteAllItems()
                                }
                          }),
                          secondaryButton: .cancel(Text("Cancel")))

                }
            }
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("Simple success vibration")
    }
    
    private func deleteAllItems() {
        expItems.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError?
            fatalError("Unresolved Error: \(String(describing: error))")
        }
    }
    
    private func deleteExpItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { expItems[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let error = error as NSError?
                fatalError("Unresolved Error: \(String(describing: error))")
            }
        }
    }
    
    // Get existing expItems
    // Write them to a JSON array
    // Get the existing previous-expenses.json
    // If nil,
    //    add JSON array to a parent array called "previous-expenses"
    //    write "previous-expenses" to file
    // else
    //    get the parent array "previous-expenses"
    //    serialize into a swift array
    //    add the existing expItems JSON array to the previous-expenses array
    //    write "previous-expenses to file
    func updatePreviousExpenses() {
        print("UPDATING previous expenses json")
        // Get existing expItems, write them to a JSON array
        var expenseItemsAsJSON: [String: Any] = [:]
        for expense in expItems {
            var expenseItem: [String: String] = [:]
            expenseItem["expAmount"] = expense.expAmount
            expenseItem["expCategory"] = expense.expCategory
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/yyyy"
//            let result = dateFormatter.string(from: expense.expDate!)
            expenseItem["expDate"] = String(describing: expense.expDate!)
            
            expenseItem["expDesc"] = expense.expDesc
//            expenseItemsAsJSON.append(expenseItem)
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
            self.numLogsThisSession.count += 1
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

struct AddButton: View {
    @State private var addItemScreenIsShowing = false
    var category: String!
    
    var body: some View {
        VStack {
            Button(action: {
                addItemScreenIsShowing = true
            }) {
                Text("+")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .padding(.top, 30)
                    .padding(.trailing, 30)
                    .edgesIgnoringSafeArea(.all)
            }.sheet(isPresented: $addItemScreenIsShowing, onDismiss: {}, content: {
                AddItemView(startCategory: category)
            })
            Spacer()
        }
    }
}

func decideColor(category: String) -> Color {
    var accentColor: Color
    if category == "Drinks" {
        accentColor = Color("DrinkCategoryColor")
    } else if category == "Food" {
        accentColor = Color("FoodCategoryColor")
    } else if category == "Grocery" {
        accentColor = Color("GroceryCategoryColor")
    } else if category == "Transport" {
        accentColor = Color("TransportationCategoryColor")
    } else if category == "Misc" {
        accentColor = Color("MiscCategoryColor")
    } else {
        // For the "Total" list
        accentColor = Color.black
    }
    return accentColor
}

//struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryView(category: "Total")
//    }
//}
