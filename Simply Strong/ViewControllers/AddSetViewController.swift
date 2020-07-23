//
//  AddSetViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/16/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class AddSetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    
    weak var mainVC : ExerciseTabContainerViewController?
   
    @IBOutlet var pickWorkoutButton: UIButton!
    @IBOutlet var addSetButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var repsDisplayLabel: UILabel!
    
    
    
    var repsCountValue: Int = 0
    var selectedWorkoutIndex = 0
    var selectedRepName: String = "Pull Ups"
    
    var exercises : [NSManagedObject] = []
    var workoutSets: [NSManagedObject] = []

    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)

    var repCache: [String: Int] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "Exercises")
        
        do {
          exercises = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let fetchRequest2 =
        NSFetchRequest<NSManagedObject>(entityName: "Sets")
        
        do {
          workoutSets = try managedContext.fetch(fetchRequest2)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var workoutName : String
        if(exercises.count > 0){
            let exercise = exercises[selectedWorkoutIndex]
            workoutName = exercise.value(forKey: "name") as! String
        } else {
            workoutName = ""
        }
        
        selectWorkoutName(workoutIndex: selectedWorkoutIndex, workoutName: workoutName)
        
        
        
     
        pickWorkoutButton.layer.cornerRadius = 18
        pickWorkoutButton.layer.borderWidth = 3
        pickWorkoutButton.layer.borderColor = borderGray.cgColor
        
        
        repsDisplayLabel.layer.cornerRadius = 18
        repsDisplayLabel.layer.borderWidth = 3
        repsDisplayLabel.layer.borderColor = borderGray.cgColor
        
        tableView.layer.cornerRadius = 18
        tableView.layer.borderWidth = 3
        tableView.layer.borderColor = borderGray.cgColor
        
        addSetButton.layer.cornerRadius = 18
        
    }
    
    //======================================
    //===  table view delegate methods =====
    //======================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutSetsTableViewCell

        let workoutSet = workoutSets[indexPath.row]
        cell.repsCount?.text =  String(format: "%d", workoutSet.value(forKey: "noReps") as! Int)
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm:ss a"
        let timeNow = formatter2.string(from: workoutSet.value(forKey: "created") as! Date)
        
        let exercise = workoutSet.value(forKeyPath: "ofExercise") as? NSManagedObject
        let repName = exercise?.value(forKey: "name") as! String
        
        cell.repName?.text = repName
        cell.timeDisplay?.text = timeNow

        return cell
        
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            // remove the item from the data model
         
            guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let setToDelete = workoutSets[indexPath.row]
            managedContext.delete(setToDelete)
            
            do {
                try managedContext.save()
                workoutSets.remove(at: indexPath.row)
                // delete the table view row
                tableView.deleteRows(at: [indexPath], with: .fade)
                      
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            

        }
    }
    
    //===== end table view delegate methods 
    
    func selectWorkoutName( workoutIndex: Int, workoutName: String) -> Void {
        
     
        
        selectedWorkoutIndex = workoutIndex
        selectedRepName = workoutName
        pickWorkoutButton.setTitle(workoutName, for: UIControl.State.normal)
        
        if repCache[selectedRepName] != nil {
            
            repsCountValue = repCache[selectedRepName]!
            repsDisplayLabel.text = String(format: "%d", repsCountValue)
            
        }
        
    }
    
    @IBAction func addSetTouched(_ sender: Any) {
        
        let today = Date()
        
        // save to core data
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Sets", in: managedContext)!
        let set = NSManagedObject(entity: entity, insertInto: managedContext)
        
        set.setValue(repsCountValue, forKeyPath: "noReps")
        set.setValue(today, forKeyPath: "created")
      
        
        if(exercises.count > 0){
            let exercise = exercises[selectedWorkoutIndex]
            set.setValue(exercise, forKeyPath: "ofExercise")
        }
        
        do {
            try managedContext.save()
            
            // update table
            workoutSets.append(set)
            tableView.reloadData()
            scrollToBottom()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        
    }
    


    @IBAction func repCountIncreaseTouched(_ sender: Any) {
        
        repsCountValue += 1
        repsDisplayLabel.text = String(format: "%d",repsCountValue)
        
        repCache[selectedRepName] = repsCountValue
        
    }
    
    @IBAction func repCountDecreaseTouched(_ sender: Any) {
        
        if(repsCountValue > 0){
            repsCountValue -= 1
            repsDisplayLabel.text = String(format: "%d",repsCountValue)
            repCache[selectedRepName] = repsCountValue
        }
        
    }
    @IBAction func pickWorkoutTouched(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerVC = storyboard.instantiateViewController(withIdentifier: "workoutPickerVC") as! WorkoutPickerViewController
        pickerVC.mainVC = self
      
        pickerVC.selectedWorkoutIndex = selectedWorkoutIndex
        self.present(pickerVC, animated: true) {
            
        }
        
    }
    @IBAction func addExerciseTouched(_ sender: Any) {
        
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let addExerciseVC = storyboard.instantiateViewController(withIdentifier: "addExerciseVC") as! AddExerciseViewController
    
        
          self.present(addExerciseVC, animated: true) {
              
          }
        
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.workoutSets.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    @IBAction func doneTouched(_ sender: Any) {
        
        self.mainVC?.doShowModal = false
        self.dismiss(animated: true) {
            
            self.mainVC?.goBackHome()
        }
        
    }
    
    
    
}

