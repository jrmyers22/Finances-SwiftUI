//
//  Persistence.swift
//  FinancesSwiftUI
//
//  Created by Jacob Myers on 5/24/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "ExpItems")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved Error: \(error)")
            }
        }
    }
}
