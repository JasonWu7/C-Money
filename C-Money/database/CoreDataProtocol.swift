//
//  CoreDataProtocol.swift
//  C-Money
//
//  Created by Dongzheng Wu on 6/5/2023.
//

import Foundation

enum CoredataChange {
    case add
    case remove
    case update
}

enum CoredataListenerType {
    case category
    case all
}

protocol CoredataListener: AnyObject {
    var coredataListenerType: CoredataListenerType {get set}
    func onCategoryChange(change: CoredataChange, categories: [Category])
}

protocol CoredataProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: CoredataListener)
    func removeListener(listener: CoredataListener)
    
    func addCategory(categoryName: String) -> Category
    func deleteCategory(category: Category)
    
    var defaultCategories: [Category] {get}
    
}
