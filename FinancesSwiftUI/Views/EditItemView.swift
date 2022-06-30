//
//  EditItemView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var numLogsThisSession: NumLogsThisSession = .shared
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    @State private var description: String
    @State private var amount: String
    @State private var id: String
    @State private var isEditingDesc = false
    @State private var isEditingAmount = false
    @State private var category: String
    @State private var showingIncompleteAlert = false
    @State private var invalidAmountInput = false
    @State private var showingSuccessfulAlert = false
    let categories = ["Drinks", "Food", "Grocery", "Transport", "Misc"]
    
    @State private var startCat: String
    
    // addItem(description: description, category: category, amount: amount)
    init(startCategory: String? = "Drinks", id: String, description: String, category: String, amount: String) {
        UITextField.appearance().backgroundColor = .lightGray
        UITextField.appearance().textColor = .white
        // _fullText = State(initialValue: list[letter]!)
        _startCat = State(initialValue: startCategory!)
        _id = State(initialValue: id)
        _description = State(initialValue: description)
        _category = State(initialValue: category)
        _amount = State(initialValue: amount)
    }
    
    var body: some View {
        
        VStack {
            Text("Edit Expense")
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
                    .font(.title)
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
                
                Button(action: {
                    hideKeyboard()
                }) {
                    Text("☑️")
                        .font(.title)
                        .padding(.leading)
                }
            }.padding(.leading, Constants.Views.SCREEN_WIDTH * 0.1)
            
            Spacer()
            
            // Edit Item Button
            Button(action: {
                self.numLogsThisSession.count += 1
                if description == "" || amount == "" {
                    showingIncompleteAlert = true
                } else if !amount.allSatisfy({ $0.isNumber || $0 == "." }) {
                    // Anything other than a number or a period
                    // NOT (amount is all numbers and ONE decimal)
                    invalidAmountInput = true
                } else {
                    EditItem(id: id, description: description, category: category, amount: amount)
                    print("Edited item in core data")
                    simpleSuccess()
                    showingSuccessfulAlert = true
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
                Alert(title: Text("Not so fast!"), message: Text("The description and amount must be filled in."), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $invalidAmountInput) {
                Alert(title: Text("Not so fast!"), message: Text("The amount must only contain numbers and a decimal."), dismissButton: .default(Text("Gotcha")))
            }
            .alert(isPresented: $showingSuccessfulAlert) {
                Alert(title: Text("Success!"), message: Text("Expense has been updated."), dismissButton: .default(Text("Ok"), action: {
                    hideKeyboard()
                    //                    presentationMode.wrappedValue.dismiss()
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                }
                                                                                                                  ))
            }
            Spacer()
        }.background(Color.gray).edgesIgnoringSafeArea(.all)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("Simple success vibration")
    }
    
    private func clearData() {
        self.amount = ""
        self.description = ""
        self.category = "Grocery"
    }
    
    private func EditItem(id: String, description: String, category: String, amount: String) {
        var existingItem: ExpItem = ExpItem()
        
        // TODO: Try this with a closure function to clean it up
        for item in expItems {
            if item.id == id { existingItem = item }
        }
        
        if existingItem.expDesc == "" { return; print("Can't find item to edit") }
        
        if amount.contains(".") {
            let numsAfterDecimal = String(amount[amount.firstIndex(of: ".")!...])
            if numsAfterDecimal.count == 2 {
                existingItem.expAmount = amount + "0"
            } else if numsAfterDecimal.count == 1 {
                existingItem.expAmount = amount + "00"
            } else if numsAfterDecimal.count > 3 {
                // get the index of the first decimal, drop the number of elements after the Hundreths (.00) place
                existingItem.expAmount = String(amount.dropLast(numsAfterDecimal.count - 3))
            } else {
                existingItem.expAmount = amount
            }
        } else {
            // doesn't contain decimal
            existingItem.expAmount = amount + ".00"
        }
        existingItem.expDesc = description
        existingItem.expCategory = category
        existingItem.expDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError?
            fatalError("Unresolved Error: \(String(describing: error))")
        }
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {

        EditItemView(id: "", description: "", category: "", amount: "")
            .preferredColorScheme(.dark)
    }
}
