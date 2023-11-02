//
//  CoreDataController.swift
//  C-Money
//
//  Created by Dongzheng Wu on 6/5/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, CoredataProtocol, NSFetchedResultsControllerDelegate{
    
    var defaultCategories: [Category]
    var listeners = MulticastDelegate<CoredataListener>()
    var persistentContainer: NSPersistentContainer
    var allCategoriesFetchedResultsController: NSFetchedResultsController<Category>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores(){ (description, error) in
            if let error = error {
                fatalError("Failed to loead core data stack with error: \(error)")
            }
        }
        defaultCategories = [Category()]
        super.init()
        if fetchAllCategories().count == 0{
            createDefaultCategories()
        }
    }
    
    func addCategory(categoryName: String) -> Category {
        let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: persistentContainer.viewContext) as! Category
        category.categoryName = categoryName
        category.createDate = Date.now
        
        return category
    }
    
    func deleteCategory(category: Category) {
        persistentContainer.viewContext.delete(category)
    }
    
    func fetchAllCategories() -> [Category] {
        if allCategoriesFetchedResultsController == nil {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            allCategoriesFetchedResultsController = NSFetchedResultsController<Category>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allCategoriesFetchedResultsController?.delegate = self
            
            do {
                try allCategoriesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Reqeust Failed: \(error)")
            }
        }
        if let categories = allCategoriesFetchedResultsController?.fetchedObjects {
            return categories
        }
        return [Category]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allCategoriesFetchedResultsController {
            listeners.invoke() {
                listner in
                if listner.coredataListenerType == .category || listner.coredataListenerType == .all {
                    listner.onCategoryChange(change: .update, categories: fetchAllCategories())
                }
            }
        }
    }
    
    func addListener(listener: CoredataListener) {
        listeners.addDelegate(listener)
        
        if listener.coredataListenerType == .category || listener.coredataListenerType == .all {
            listener.onCategoryChange(change: .update, categories: fetchAllCategories())
        }
    }
    
    func removeListener(listener: CoredataListener) {
        listeners.removeDelegate(listener)
    }
    
    func cleanup(){
        if persistentContainer.viewContext.hasChanges {
            do{
                try persistentContainer.viewContext.save()
            }catch{
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func createDefaultCategories() {
        let _ = addCategory(categoryName: "Income")
        let _ = addCategory(categoryName: "Transport")
        let _ = addCategory(categoryName: "Rent")
        cleanup()
    }
}
