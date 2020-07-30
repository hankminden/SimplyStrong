//
//  AppDelegate.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/16/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    var window: UIWindow?


     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         // Override point for customization after application launch.
        
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        
        //let tabBar = self.window?.rootViewController as! UITabBarController
        //tabBar.selectedIndex = 1
        
        return true
     }

     func applicationWillResignActive(_ application: UIApplication) {
         // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
         // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
     }

     func applicationDidEnterBackground(_ application: UIApplication) {
         // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     }

     func applicationWillEnterForeground(_ application: UIApplication) {
         // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
     }

     func applicationDidBecomeActive(_ application: UIApplication) {
         // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Simply_Strong")
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
        return container
    }()

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
    
    
// -------------- UNUSED PARSING CSV CODE
    
 func parseExercisesCSV (contentsOfURL: NSURL, encoding: String.Encoding, error: NSErrorPointer) -> [(name:String, detail:String, price: String)]? {
    // Load the CSV file and parse it
     let delimiter = ","
     var items:[(name:String, detail:String, price: String)]?

     //if let content = String(contentsOfURL: contentsOfURL, encoding: encoding, error: error) {
     if let content = try? String(contentsOf: contentsOfURL as URL, encoding: encoding) {
         items = []
         let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]

         for line in lines {
             var values:[String] = []
             if line != "" {
                 // For a line with double quotes
                 // we use NSScanner to perform the parsing
                 if line.range(of: "\"") != nil {
                     var textToScan:String = line
                     var value:NSString?
                     var textScanner:Scanner = Scanner(string: textToScan)
                     while textScanner.string != "" {

                         if (textScanner.string as NSString).substring(to: 1) == "\"" {
                             textScanner.scanLocation += 1
                             textScanner.scanUpTo("\"", into: &value)
                             textScanner.scanLocation += 1
                         } else {
                             textScanner.scanUpTo(delimiter, into: &value)
                         }

                         // Store the value into the values array
                         values.append(value! as String)

                         // Retrieve the unscanned remainder of the string
                         if textScanner.scanLocation < textScanner.string.count {
                             textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                         } else {
                             textToScan = ""
                         }
                         textScanner = Scanner(string: textToScan)
                     }

                     // For a line without double quotes, we can simply separate the string
                     // by using the delimiter (e.g. comma)
                 } else  {
                     values = line.components(separatedBy: delimiter)
                 }

                 // Put the values into the tuple and add it to the items array
                 let item = (name: values[0], detail: values[1], price: values[2])
                 items?.append(item)
             }
         }
     }

     return items
 }
    
    func preloadDataForExercises () {
        // Retrieve data from the source file
        if let contentsOfURL = Bundle.main.url(forResource: "menudata", withExtension: "csv") {
            
            // Remove all the menu items before preloading
            removeExerciseData()
            
            var error:NSError?
            if let items = parseExercisesCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, error: &error) {
                // Preload the menu items
                    let managedObjectContext = self.persistentContainer.viewContext
                    for item in items {
                      /*  let exercise = NSEntityDescription.insertNewObjectForEntityForName("Exercises", inManagedObjectContext: managedObjectContext)
                        menuItem.name = item.name
                        menuItem.detail = item.detail
                        menuItem.price = (item.price as NSString).doubleValue
                        
                        managedObjectContext.save
                    }*/
                
            }
        }
    }
    }
    
    func removeExerciseData () {
         // Remove the existing items
         let managedObjectContext = self.persistentContainer.viewContext
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Exercises")
             
         do {
           let exercises = try managedObjectContext.fetch(fetchRequest)
             
             for exercise in exercises {
                 managedObjectContext.delete(exercise as! NSManagedObject)
                 do {
                     try managedObjectContext.save()
                     
                     
                 } catch let error as NSError {
                   print("Could not delete. \(error), \(error.userInfo)")
                 }
                 
             }
             
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
    
             
             
         
     }
    
    // -------------- UNUSED PARSING CSV CODE  

}

