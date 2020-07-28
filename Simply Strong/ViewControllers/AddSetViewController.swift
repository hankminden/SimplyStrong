//
//  AddSetViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/16/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

struct WorkoutDay {
    var setTypes : [String]
    var setDict = [String: Int]()
    var setArray : [NSManagedObject]
    var date : String
}

class AddSetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    weak var pvc : MainPageViewController?
    //weak var mainVC : ExerciseTabContainerViewController?
   
    @IBOutlet var pickWorkoutButton: UIButton!
    @IBOutlet var addSetButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var repsDisplayLabel: UILabel!
    
    @IBOutlet var homeButton: UIButton!
    
    
    var repsCountValue: Int = 0

    var selectedExercise : NSManagedObject?
    
    var exercises : [NSManagedObject] = []
    var workoutSets: [NSManagedObject] = []
    
    var totalDaysOfWorkouts = 0
    var organizedWorkoutSets: [WorkoutDay] = []
    
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
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest2.sortDescriptors = [sort]
        
        do {
            
            workoutSets = try managedContext.fetch(fetchRequest2)
        
            organizeSetsIntoSections(workoutSets: workoutSets)
            self.tableView.reloadData()
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
       
        if(exercises.count > 0){
            let exercise = exercises[0]
           
            selectedExercise = exercise
            selectWorkoutName(exercise: exercise)
        } else {
            pickWorkoutButton.setTitle("", for: UIControl.State.normal)
        }
        
        
        
        
        
     
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
        header.textLabel?.font = UIFont(name: "Futura-Bold", size: 16)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .center
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return totalDaysOfWorkouts
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let workoutDay = organizedWorkoutSets[indexPath.section]
        let setArray = workoutDay.setArray
        
        if indexPath.row < setArray.count {
            
            return 38
            
        } else {
            
            return 28
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let workoutDay = organizedWorkoutSets[section]
        
        let setArray = workoutDay.setArray
        let setTypes = workoutDay.setTypes
        
        return setArray.count + setTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let workoutDay = organizedWorkoutSets[indexPath.section]
        let setArray = workoutDay.setArray
        
        if indexPath.row < setArray.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutSetsTableViewCell

            let workoutSet = setArray[indexPath.row]
            cell.repsCount?.text =  String(format: "%d", (workoutSet as AnyObject).value(forKey: "noReps") as! Int)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "HH:mm:ss a"
            let timeNow = formatter2.string(from: (workoutSet as AnyObject).value(forKey: "created") as! Date)
            
            let exercise = (workoutSet as AnyObject).value(forKeyPath: "ofExercise") as? NSManagedObject
            let repName = exercise?.value(forKey: "name") as! String
            
            cell.repName?.text = repName
            cell.timeDisplay?.text = timeNow
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutTotalCell", for: indexPath) as! WorkoutTotalTableViewCell
            
            let setTypes = workoutDay.setTypes
            let setDict = workoutDay.setDict
            let setTypeIndex = indexPath.row - setArray.count
            
            let setType = setTypes[setTypeIndex]
            let totalReps = setDict[setType]
            
            cell.totalRepCount?.text = String(format: "%d", totalReps!)
            cell.totalRepName?.text = String(format: "Total %@", setType)
            
            return cell
            
        }
        


        //return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let workoutDay = organizedWorkoutSets[section]
 
        return workoutDay.date
        
    }
    
    
    //only workout set rows should be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let workoutDay = organizedWorkoutSets[indexPath.section]
        if indexPath.row < workoutDay.setArray.count {
            return true
        }
        
        return false
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let workoutDay = organizedWorkoutSets[indexPath.section]
        
        //only should be able to select workout set rows
        if indexPath.row < workoutDay.setArray.count {
             let selectedSet = workoutDay.setArray[indexPath.row]
             let exercise = selectedSet.value(forKeyPath: "ofExercise") as! NSManagedObject
             let exerciseName = exercise.value(forKey: "name") as! String
            
             repCache[exerciseName] = selectedSet.value(forKey: "noReps") as? Int
             selectWorkoutName(exercise: exercise)
        }
        

     
        
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
            
            
            //find set to delete
            var indexToDelete = 0
            if(indexPath.section > 0){
                for i in 0 ... indexPath.section - 1 {
                    
                    let currentWorkoutDay = organizedWorkoutSets[i]
                    indexToDelete += currentWorkoutDay.setArray.count
                    
                }
            }

            
            indexToDelete += indexPath.row
            
            let workoutDay = organizedWorkoutSets[indexPath.section]
            let setDict = workoutDay.setDict
            let setArray = workoutDay.setArray
            
            let setToDelete = workoutSets[indexToDelete]
            let repsInSet = setToDelete.value(forKey: "noReps") as! Int
            
            let exercise = setToDelete.value(forKey: "ofExercise") as! NSManagedObject
            let exerciseName = exercise.value(forKey: "name") as! String
            
            //if this set is the only thing contributing to the total in that section we need to delete the total row
            var totalIndexToDelete = -1
            var sectionToDelete = -1
            
            //if this is the last set in the day we need to delete the whole section
            if setArray.count == 1 {
                sectionToDelete = indexPath.section
            } else if setDict[exerciseName]! as Int == repsInSet {
                
                let setTypes = workoutDay.setTypes
                for j in 0 ... setTypes.count - 1 {
                    
                    if exerciseName == setTypes[j] {
                        totalIndexToDelete = j
                    }
                    
                }
                totalIndexToDelete += workoutDay.setArray.count
                
            }
            
            managedContext.delete(setToDelete)
            
            do {
                try managedContext.save()
                workoutSets.remove(at: indexToDelete)
                // delete the table view row
                organizeSetsIntoSections(workoutSets: workoutSets)
                if sectionToDelete > -1 {
                    let indexSet = IndexSet(arrayLiteral: indexPath.section)
                    tableView.deleteSections(indexSet, with: .fade)
                } else if totalIndexToDelete > -1 {
                    let indexPath2 = IndexPath(row: totalIndexToDelete, section: indexPath.section)
                    tableView.deleteRows(at: [indexPath,indexPath2], with: .fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    

    
    //===== end table view delegate methods 
    
    //======================================
    //===  linked IBActions            =====
    //======================================
    
    @IBAction func addSetTouched(_ sender: Any) {
        
        if selectedExercise != nil  && repsCountValue > 0 {
            
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
              set.setValue(selectedExercise, forKeyPath: "ofExercise")
              
             
              
              do {
                  try managedContext.save()
                  
                  // update table
                  workoutSets.append(set)
                  organizeSetsIntoSections(workoutSets: workoutSets)
                    self.tableView.reloadData()
                  scrollToBottom()
              } catch let error as NSError {
                  print("Could not save. \(error), \(error.userInfo)")
              }
            
        }
        
        
        
        
        
    }
    

    @IBAction func homeTouched(_ sender: Any) {
        
        let firstVC = pvc!.pages[1]
        pvc!.setViewControllers([firstVC], direction: .reverse, animated: true, completion: nil)
        
    }
    
    @IBAction func repCountIncreaseTouched(_ sender: Any) {
        
        repsCountValue += 1
        repsDisplayLabel.text = String(format: "%d",repsCountValue)
        let selectedRepName = selectedExercise?.value(forKey: "name") as! String
        repCache[selectedRepName] = repsCountValue
        
    }
    
    @IBAction func repCountDecreaseTouched(_ sender: Any) {
        
        if(repsCountValue > 0){
            repsCountValue -= 1
            repsDisplayLabel.text = String(format: "%d",repsCountValue)
            let selectedRepName = selectedExercise?.value(forKey: "name") as! String
            repCache[selectedRepName] = repsCountValue
        }
        
    }
    @IBAction func pickWorkoutTouched(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerVC = storyboard.instantiateViewController(withIdentifier: "workoutPickerVC") as! WorkoutPickerViewController
        pickerVC.mainVC = self
      
        for (index, exercise) in exercises.enumerated() {
          
            let selectedExerciseName = selectedExercise?.value(forKey: "name") as! String
            let currentExerciseName = exercise.value(forKey: "name") as! String
            
            if selectedExerciseName == currentExerciseName {
                
                pickerVC.selectedWorkoutIndex = index
                
            }
        }
        
        
        self.present(pickerVC, animated: true) {
            
        }
        
    }
    @IBAction func addExerciseTouched(_ sender: Any) {
        
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let addExerciseVC = storyboard.instantiateViewController(withIdentifier: "addExerciseVC") as! AddExerciseViewController
    
        
          self.present(addExerciseVC, animated: true) {
              
          }
        
    }
    
    @IBAction func doneTouched(_ sender: Any) {
        
        /*self.mainVC?.doShowModal = false
        self.dismiss(animated: true) {
            
            self.mainVC?.goBackHome()
        }*/
        
    }
    
    //===== end linked IBActions
    
    func scrollToBottom(){
        
        if totalDaysOfWorkouts > 0 {
            DispatchQueue.main.async {
                let lastSection = self.totalDaysOfWorkouts - 1
                let lastWorkout = self.organizedWorkoutSets[lastSection]
                let lastRowIndex = lastWorkout.setArray.count + lastWorkout.setTypes.count - 1
                let indexPath = IndexPath(row: lastRowIndex, section: lastSection)
                
         
                
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
        
        

    }
    
    
    func selectWorkoutName( exercise: NSManagedObject) -> Void {
        
     
        
        selectedExercise = exercise
        let selectedRepName = selectedExercise?.value(forKey: "name") as! String
        pickWorkoutButton.setTitle(selectedRepName, for: UIControl.State.normal)
        
        if repCache[selectedRepName] != nil {
            
            repsCountValue = repCache[selectedRepName]!
            repsDisplayLabel.text = String(format: "%d", repsCountValue)
            
        }
        
    }
    
    func organizeSetsIntoSections( workoutSets: [NSManagedObject]) -> Void {
        
        organizedWorkoutSets = []
        
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE,  MMM d, yyyy"
        
        var lastDay = 0
        var lastMonth = 0
        var lastYear = 0
        var dayCounter = 0
     
        var setTypes : [String] = []
        var setDict: [String: Int] = [:]
        var setArray : [NSManagedObject] = []
        
        var lastDayString : String = ""
        
        for workoutSet in workoutSets {
            
            let created = workoutSet.value(forKey: "created") as! Date
            let components = calendar.dateComponents([.month, .day, .year], from: created)
         
            let day = components.day
            let month = components.year
            let year = components.year
            let dateString = dateFormatter.string(from: created)
            
            
            
            if lastDay == 0 {
                //this is first iteration
                lastDay = day!
                lastMonth = month!
                lastYear = year!
                
            }
            
            if day != lastDay || month != lastMonth || year != lastYear {
                
                
                
                //copy arrays to day dict
                let copyOfSetTypes = setTypes
                let copyOfSetDict = setDict
                let copyOfSets = setArray
      
            
                let currentWorkoutDay = WorkoutDay(setTypes: copyOfSetTypes, setDict: copyOfSetDict, setArray: copyOfSets, date: lastDayString)
                organizedWorkoutSets.append(currentWorkoutDay)
                
                //start a new day dict
                lastDay = day!
                lastMonth = month!
                lastYear = year!
                dayCounter += 1
         
                setTypes = []
                setDict = [:]
                setArray = []
                
            }
            
            let noReps = workoutSet.value(forKey: "noReps") as! Int
            let exercise = workoutSet.value(forKey: "ofExercise") as! NSManagedObject
            let exerciseName = exercise.value(forKey: "name") as! String
            
            if setDict[exerciseName] == nil {
                setDict[exerciseName] = noReps
                setTypes.append(exerciseName)
            } else {
                var prevReps = setDict[exerciseName]
                prevReps! += noReps
                setDict[exerciseName] = prevReps
            }
            setArray.append(workoutSet)
            lastDayString = dateString
            
            
        }
        
        
        //we gotta put the last day into the workout day array (if there are any sets from today)
        if setArray.count > 0 {
            
            dayCounter += 1
                      
            //copy arrays to day dict
            let copyOfSetTypes = setTypes
            let copyOfSetDict = setDict
            let copyOfSets = setArray
            
            let currentWorkoutDay = WorkoutDay(setTypes: copyOfSetTypes, setDict: copyOfSetDict, setArray: copyOfSets, date: lastDayString)
                             organizedWorkoutSets.append(currentWorkoutDay)
        }
       
        
        totalDaysOfWorkouts = dayCounter
        
        
    }
    
    
}

