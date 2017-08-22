//
//  DataManager.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/21/17.
//  Copyright © 2017 付 旦. All rights reserved.
//

import Foundation
import CoreData


class DataManager : NSObject {
//    let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
//
//    lazy var psc : NSPersistentStoreCoordinator = {
//        let modelURL = Bundle.main.url(forResource: "VoiceMemo", withExtension: "momd")
//        let model = NSManagedObjectModel(contentsOf: modelURL!)!
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
//        return psc
//    }()
//    
//    lazy var context:NSManagedObjectContext = {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.persistentStoreCoordinator = self.psc
//        return context
//    }()
//    
//    
//
//    
//    lazy var recordings = [VoiceRecord]()
//    lazy var storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1
    
    var managedObjectContext: NSManagedObjectContext
    init(completionClosure: @escaping () -> ()) {
        //This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: "VoiceMemo", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError("Unable to resolve document directory")
            }
            let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
                DispatchQueue.main.sync(execute: completionClosure)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    func save(_ fileName : String, creationDate : Date, fileDescription : String? = nil) {
        let record = NSEntityDescription.insertNewObject(forEntityName: "VoiceRecord", into: managedObjectContext) as! VoiceRecord
        record.fileName = fileName
        record.creationDate = creationDate as NSDate
        record.fileDescription = fileDescription
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        

    }
    
    func fetch() {
        
        do {
            let fetchedRecords = try managedObjectContext.fetch(VoiceRecord.fetchRequest()) as! [VoiceRecord]
            print(fetchedRecords[0].fileName)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    
    
}



extension DataManager {
    class func documentDirectoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0]
        return documentDirectory
    }
}
