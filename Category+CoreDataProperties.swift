//
//  Category+CoreDataProperties.swift
//  C-Money
//
//  Created by Dongzheng Wu on 6/5/2023.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var createDate: Date?

}

extension Category : Identifiable {

}
