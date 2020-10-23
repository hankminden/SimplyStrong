//
//  CSVImportManager.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/22/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum CSVImportError: Error {
    case incorrectCSVFormat
    case internalFault
    case fileReadError
}

class CSVImportManager {
    
    func importExerciseTableFromCSV(csvPath: String) throws -> [Int] {
        
        var processedRows = 0
        var duplicateRows = 0
        var failedRows = 0
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            throw CSVImportError.internalFault
         
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            var contents = try String(contentsOfFile: csvPath, encoding: .utf8)
            contents = cleanRows(file: contents)
            var csvArray = csv(data: contents)
            
            if csvArray.count > 0 {
                
                let headerRow = csvArray[0]
                if headerRow[0] != "Exercise Name" {
                 
                    throw CSVImportError.incorrectCSVFormat
                   
                    
                } else {
                     
                    for i in 1 ... csvArray.count - 1 {
                        
                        var exerciseName: String? = nil
                        
                        let row = csvArray[i]
                        if row.count > 0 {
                            exerciseName = String(row[0])
                        } else {
                            failedRows += 1
                            continue
                        }
                     
                        
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Exercises" )
                        fetchRequest.predicate = NSPredicate(format: "name == %@", exerciseName!)
                        
                        do {
                            let foods = try managedContext.fetch(fetchRequest)
                            
                            if foods.count > 0 {
                              //we found a food with matching name, mark as duplicate and continue looping
                              duplicateRows += 1
                            } else {
                                
                                //go ahead and insert this food into the food table
                                let entity = NSEntityDescription.entity(forEntityName: "Exercises", in: managedContext)!
                                let newexercise = NSManagedObject(entity: entity, insertInto: managedContext)
                                
                            
                                newexercise.setValue(NSDate(), forKeyPath: "created")
                                newexercise.setValue(exerciseName, forKeyPath: "name")
                                
                                do {
                                    try managedContext.save()
                                    processedRows += 1
                                } catch  {
                                    failedRows += 1
                                }
                                
                            }
                            
                            
                        } catch  {
                            failedRows += 1
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
                
            }
            
        } catch  {
            throw CSVImportError.fileReadError
        }
        
        return [processedRows,duplicateRows,failedRows]
        
    }
    
    func importFoodTableFromCSV(csvPath: String) throws -> [Int] {
        
        var processedRows = 0
        var duplicateRows = 0
        var failedRows = 0
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            throw CSVImportError.internalFault
         
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            var contents = try String(contentsOfFile: csvPath, encoding: .utf8)
            contents = cleanRows(file: contents)
            var csvArray = csv(data: contents)
            
            if csvArray.count > 0 {
                
                let headerRow = csvArray[0]
                if headerRow[0] != "Food Name" || headerRow[1] != "Calories"  {
                 
                    throw CSVImportError.incorrectCSVFormat
                   
                    
                } else {
                     
                    for i in 1 ... csvArray.count - 1 {
                        
                        var foodName: String? = nil
                        var calories: Int? = nil
                        
                        let row = csvArray[i]
                        if row.count > 0 {
                            foodName = String(row[0])
                        } else {
                            failedRows += 1
                            continue
                        }
                        if row.count > 1 {
                            calories = Int(row[1]) ?? 0
                        } else {
                            failedRows += 1
                            continue
                        }
                        calories = Int(row[1]) ?? 0
                        
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Foods" )
                        fetchRequest.predicate = NSPredicate(format: "name == %@", foodName!)
                        
                        do {
                            let foods = try managedContext.fetch(fetchRequest)
                            
                            if foods.count > 0 {
                              //we found a food with matching name, mark as duplicate and continue looping
                              duplicateRows += 1
                            } else {
                                
                                //go ahead and insert this food into the food table
                                let entity = NSEntityDescription.entity(forEntityName: "Foods", in: managedContext)!
                                let newfood = NSManagedObject(entity: entity, insertInto: managedContext)
                                
                                newfood.setValue(calories, forKeyPath: "calories")
                                newfood.setValue(NSDate(), forKeyPath: "created")
                                newfood.setValue(foodName, forKeyPath: "name")
                                
                                do {
                                    try managedContext.save()
                                    processedRows += 1
                                } catch  {
                                    failedRows += 1
                                }
                                
                            }
                            
                            
                        } catch  {
                            failedRows += 1
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
                
            }
            
        } catch  {
            throw CSVImportError.fileReadError
        }
        
        return [processedRows,duplicateRows,failedRows]
        
    }
        
    
    func csv(data: String) -> [[String]] {
        
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            var columns = row.components(separatedBy: ",")
            
            result.append(columns)
            
        }
        
        return result
    }

    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
}
