//
//  Persistence.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 10/09/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<6 {
            let newAudio = Audio(context: viewContext)
            newAudio.timestamp = Date()
            newAudio.name = "Test"
            newAudio.path = "https://google.com"
            newAudio.duration = 0.1
            newAudio.fileSize = 0.2
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AudioRecording")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved successfully")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addAudio(name: String, path: URL, duration: Double, fileSize: Double, context: NSManagedObjectContext) {
        let newAudio = Audio(context: context)
        newAudio.timestamp = Date()
        newAudio.name = name
        newAudio.path = path.absoluteString
        newAudio.duration = duration
        newAudio.fileSize = fileSize

        save(context: context)
    }
    
    func deleteAudio(audio: Audio, context: NSManagedObjectContext) {
        context.delete(audio)

        save(context: context)
    }
}
