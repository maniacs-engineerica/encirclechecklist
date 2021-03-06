//
//  Repository.swift
//  Geofence
//
//  Created by Matias Cohen on 15/04/2021.
//

import UIKit

import CoreData
import FirebaseCrashlytics

class Repository<Entity: NSManagedObject> {

    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create() -> Entity {
        let entityName = String(describing: Entity.self)
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Entity
    }
    
    func get(predicate: NSPredicate? = nil) throws -> [Entity]{
        let entityName = String(describing: Entity.self)
        let request = NSFetchRequest<Entity>(entityName: entityName)
        request.predicate = predicate
        return try context.fetch(request)
    }
    
    func save() -> Bool{
        do {
            try context.save()
            return true
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            return false
        }
    }
    
    func delete(object: Entity) -> Bool {
        context.delete(object)
        return save()
    }
}
