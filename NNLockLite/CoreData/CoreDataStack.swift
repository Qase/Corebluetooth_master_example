//
//  CoreDataStack.swift
//  NNLockLite
//
//  Created by David Nemec on 10/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import CoreData
import QuantiLogger

class CoreDataStack {
    public static let shared = CoreDataStack()
    
    var persistentContainerContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer {
        return _persistentContainer
    }

    // MARK: - Core Data stack
    fileprivate lazy var _persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.undoManager = nil
        return container
    }()
    
    
    func fetch<T>(with fetchRequest: NSFetchRequest<T>) -> [T]? {
        
        var ret: [T]? = []
        
        persistentContainerContext.performAndWait {
            do {
                let results = try self.persistentContainerContext.fetch(fetchRequest)
                ret = results
            } catch {
                QLog("Error \(error) during fetch with fetch request \(fetchRequest)", onLevel: .error)
                ret = nil
            }
        }
        
        return ret
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataStack {
    func devicesFetchedResultsController() -> NSFetchedResultsController<Device> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Device> = Device.orderedFetchRequest()
        fetchRequest.fetchBatchSize = 10
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchController
    }
    
    func deviceWith(uuidString: String) -> Device? {
        let fetchRequest: NSFetchRequest<Device> = Device.orderedFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier=%@", uuidString)
        fetchRequest.fetchLimit = 1
        guard let results = fetch(with: fetchRequest) else {
            return nil
        }
        
        return results.first
        
        
    }
    
    func getAllDevices() -> [Device] {
        let fetchRequest: NSFetchRequest<Device> = Device.orderedFetchRequest()
        
        guard let results = fetch(with: fetchRequest) else {
            return []
        }
        
        return results
    }
}
