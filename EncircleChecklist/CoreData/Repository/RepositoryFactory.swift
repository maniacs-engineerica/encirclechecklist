//
//  RepositoryFactory.swift
//  Geofence
//
//  Created by Matias Cohen on 15/04/2021.
//

import UIKit

import CoreData

class RepositoryFactory {
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func itemRepository() -> CheckListItemRepository {
        return CheckListItemRepository(context: context)
    }
    
}
