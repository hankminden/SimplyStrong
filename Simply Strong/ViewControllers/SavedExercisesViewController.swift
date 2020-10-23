//
//  SavedExercisesViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/23/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class SavedExercisesViewController: UIViewController, StrongAlertViewDelegate, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var savedExercisesTable: UITableView!
    var exercises : [NSManagedObject] = []
    var exerciseLookup : [String:Int] = [:]
    weak var pvc : AddSetViewController?
    var strongAlert : StrongAlertView?
    var rowToDelete : Int = 0
    
    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    let formatter2 = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter2.dateFormat = "dd-MMM-yyyy"

        savedExercisesTable.layer.cornerRadius = 18
        savedExercisesTable.layer.borderWidth = 3
        savedExercisesTable.layer.borderColor = borderGray.cgColor
        
        savedExercisesTable.delegate = self
        savedExercisesTable.dataSource = self
        
        strongAlert = StrongAlertView.init(frame: CGRect(x: (self.view.frame.size.width/2)-(360/2), y:-320, width: 360, height: 320))
        strongAlert?.delegate = self
        self.view.addSubview(strongAlert!)
        
        getSavedExercises()
    }
    
    func getSavedExercises() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Exercises" )
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
         do {
             
            exercises = try managedContext.fetch(fetchRequest)
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sets" )
            
            do {
                let exercisesDone = try managedContext.fetch(fetchRequest)
                
                for exerciseDone in exercisesDone {
                    
                    let reps = exerciseDone.value(forKey: "noReps") as! Int
                    let exercise = exerciseDone.value(forKeyPath: "ofExercise") as? NSManagedObject
                    let exerciseName = exercise?.value(forKey: "name") as! String
                    
                    if exerciseLookup[exerciseName] != nil {
                        let totalReps = exerciseLookup[exerciseName]
                        exerciseLookup[exerciseName] = totalReps! + reps
                    } else {
                        exerciseLookup[exerciseName] = reps
                    }
                }
                
                savedExercisesTable.reloadData()
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            
            savedExercisesTable.reloadData()
             
         } catch let error as NSError {
             print("Could not fetch. \(error), \(error.userInfo)")
         }
        
    }
    
    func deleteExerciseAtRow( row: Int) -> Void {
        
        let exerciseToDelete = exercises[row]
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(exerciseToDelete)
        
        do {
            try managedContext.save()
            exercises.remove(at: row)
            let indexPath = IndexPath(row: row, section: 0)
            savedExercisesTable.deleteRows(at: [indexPath], with: .fade)
            pvc?.loadExercises()
            pvc?.loadSets()
            
     
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    //======================================
    //===  table view delegate methods =====
    //======================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exercise = exercises[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsCell", for: indexPath) as! FoodTableViewCell
        
        let created = (exercise.value(forKey: "created") as? Date) ?? Date()
        
        let timeNow = formatter2.string(from: created)
        
        let exerciseName = exercise.value(forKey: "name") as? String
        let repsNo = exerciseLookup[exerciseName!] ?? 0
        
        cell.calories?.text = String(repsNo)
        cell.created?.text = timeNow
        cell.foodName?.text = exerciseName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
        header.textLabel?.font = UIFont(name: "Futura-Bold", size: 16)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Lifetime Total - Name - Created"
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete {
            
            let exerciseToDelete = exercises[indexPath.row]
            
            let name = exerciseToDelete.value(forKey: "name") as! String
            
            if exerciseLookup[name] != nil {
                
                rowToDelete = indexPath.row
                strongAlert?.alertTitle.text = "Warning"
                strongAlert?.alertBody.text = "This exercise has \(exerciseLookup[name] ?? 0) reps associated with it. Deleting this exercise will also delete those workout entries."
                strongAlert?.buttonOne.setTitle("Proceed", for: UIControl.State.normal)
                strongAlert?.buttonTwo.setTitle("Cancel", for: UIControl.State.normal)
                strongAlert?.showStrongAlert()
                
            } else {
                self.deleteExerciseAtRow(row: indexPath.row)
            }
            
        }
        
    }

    //=============================================
    //===  strong alert view delegate methods =====
    //=============================================
    
    func buttonOneTouchedDM() {
        deleteExerciseAtRow(row: rowToDelete)
        strongAlert?.hideStrongAlert()
    }
    
    func buttonTwoTouchedDM() {
        strongAlert?.hideStrongAlert()
    }
}
