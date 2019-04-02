//
//  CoreDataManager.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/20/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import CoreData
import Foundation

final class CoreDataManager {
    
    // MARK: - Vars
    static let instance = CoreDataManager()
    var artistIsInDataBase = false
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        }()
    
    // MARK: - CoreDataManager
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ArtistsPresentetion")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func objectIsInDataBase(objectName: String, forEntity entityName: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            if let results = try persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    if let resultName = result.value(forKey: "name") as? String, resultName == objectName {
                        return true
                    }
                }
            }
        } catch {
            print(error)
            return false
        }
        return false
    }
    
    func deleteObject(withName name: String, forEntity entity: String, completion: ()-> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            if let results = try persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    if let resultName = result.value(forKey: "name") as? String, resultName == name {
                        persistentContainer.viewContext.delete(result)
                        CoreDataManager.instance.saveContext()
                        completion()
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func addFavoriteArtist(withName name: String, withID id: String, withEventsCount count: Int, withImageDataURL url: String, completion: () -> Void) {
        if let entityDescription = NSEntityDescription.entity(forEntityName: "FavoriteArtist", in: persistentContainer.viewContext) {
            completion()
            DispatchQueue.global(qos: .userInteractive).async {
                let managedObject = NSManagedObject(entity: entityDescription, insertInto: self.persistentContainer.viewContext)
                managedObject.setValue(name, forKey: "name")
                managedObject.setValue(id, forKey: "id")
                managedObject.setValue(count, forKey: "upcoming_events_count")
                if let imageUrl = URL(string: url), let data = try? Data(contentsOf: imageUrl) as NSData {
                    managedObject.setValue(data, forKey: "image_data")
                }
                CoreDataManager.instance.saveContext()
            }
        }
    }
    
}
