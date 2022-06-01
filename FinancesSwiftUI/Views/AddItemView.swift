//
//  AddItemView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var isEditingDesc = false
    @State private var isEditingAmount = false
    @State private var category = "Grocery"
    @State private var showingIncompleteAlert = false
    @State private var invalidAmountInput = false
    @State private var showingSuccessfulAlert = false
    let categories = ["Drinks", "Food", "Grocery", "Transport", "Misc"]
    
    var startCat: String
    
    init(startCategory: String? = "Drinks") {
        UITextField.appearance().backgroundColor = .lightGray
        UITextField.appearance().textColor = .white
        startCat = startCategory!
    }
    
    var body: some View {
        
        VStack {
            Text("New Expense")
                .font(.largeTitle)
                .fontWeight(.black)
                .padding(.top)
                .padding(.bottom, 50)
                .foregroundColor(Color.white)
            
            // Description Text Field
            HStack {
                Text("Description:")
                    .bold()
                    .font(.title3)
                    .padding(.leading)
                    .foregroundColor(Color.white)
                TextField(
                    "Marco's pizza, etc.",
                    text: $description
                ) { isEditing in
                    self.isEditingDesc = isEditing
                } onCommit: {}
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.white)
                .padding(.trailing)
                .font(.title)
            }
            
            // Category Picker
            Picker(selection: $category, label: Text("")) {
                ForEach(self.categories, id: \.self) { category in
                    HStack {
                        Text(category)
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                }
            }.onAppear {
                category = startCat
            }
            .pickerStyle(WheelPickerStyle())
            .background(Color.gray)
            .labelsHidden()
            
            // Amount Text Field
            HStack {
                Text("$")
                    .bold()
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.white)
                TextField(
                    "",
                    text: $amount
                ) { isEditing in
                    self.isEditingAmount = isEditing
                } onCommit: {}
                .frame(width: 130)
//                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.white)
                .padding(.leading, -5)
                .font(.title)
            }
            
            Spacer()
            
            // Add Item Button
            Button(action: {
                if description == "" || amount == "" {
                    showingIncompleteAlert = true
                } else if !amount.allSatisfy({ $0.isNumber || $0 == "." }) {
                    // Anything other than a number or a period
                    // NOT (amount is all numbers and ONE decimal)
                    invalidAmountInput = true
                } else {
                    addItem(description: description, category: category, amount: amount)
                    print("Added item to core data")
                    showingSuccessfulAlert = true
                }
            }) {
                Text("Add Item")
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
                Alert(title: Text("Not so fast!"), message: Text("The description and amount must be filled in."), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $invalidAmountInput) {
                Alert(title: Text("Not so fast!"), message: Text("The amount must only contain numbers and a decimal."), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $showingSuccessfulAlert) {
                Alert(title: Text("Success!"), message: Text("Expense has been added."), dismissButton: .default(Text("Ok"), action: {
                    hideKeyboard()
                    clearData()
                }
                ))
            }
            Spacer()
        }.background(Color.gray).edgesIgnoringSafeArea(.all)
    }
    
    private func clearData() {
        self.amount = ""
        self.description = ""
        self.category = "Grocery"
    }
    
    private func addItem(description: String, category: String, amount: String) {
        let newItem = ExpItem(context: viewContext)
        if amount.contains(".") {
            let numsAfterDecimal = String(amount[amount.firstIndex(of: ".")!...])
            if numsAfterDecimal.count == 2 {
                newItem.expAmount = amount + "0"
            } else if numsAfterDecimal.count == 1 {
                newItem.expAmount = amount + "00"
            } else if numsAfterDecimal.count > 3 {
                // get the index of the first decimal, drop the number of elements after the Hundreths (.00) place
                newItem.expAmount = String(amount.dropLast(numsAfterDecimal.count - 3))
            } else {
                newItem.expAmount = amount
            }
        } else {
            // doesn't contain decimal
            newItem.expAmount = amount + ".00"
        }
        newItem.expDesc = description
        newItem.expCategory = category
        newItem.expDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError?
            fatalError("Unresolved Error: \(String(describing: error))")
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
        AddItemView()
            .preferredColorScheme(.dark)
    }
}
