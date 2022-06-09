//
//  CategoryView.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/14/21.
//

import SwiftUI

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var expItems: FetchedResults<ExpItem>
    
    @State private var addItemScreenIsShowing = false
    @State var showingDeleteAllAlert = false
    
    var categoryItemsExist = false
    
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
                            if expCat == category {
                                ExpenseRowView(accentColor: accentColor, expense: expItems[i])
                            } else if category == Constants.Categories.TOTAL {
                                ExpenseRowView(accentColor: decideColor(category: expItems[i].expCategory!), expense: expItems[i])
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
        if category == Constants.Categories.TOTAL {
            if expItems.count > 1 {
                showingDeleteAllAlert = true
            }
        }
        
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

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(category: "Drinks")
    }
}
