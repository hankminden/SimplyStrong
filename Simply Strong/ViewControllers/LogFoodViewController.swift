//
//  LogFoodViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/21/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData


struct FoodDay {
    var date : String
    var foodsEaten : [NSManagedObject] = []
    var totalDailyCalories : Int
}

class LogFoodViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SuggestionManagerDelegate {

    
    

    weak var pvc : MainPageViewController?
    //weak var mainVC : LogFoodTabContainerViewController?
    var selectedFood : NSManagedObject?
    var calSelected : Int = 0
    var foods : [NSManagedObject] = []
    var foodsEaten : [NSManagedObject] = []
    @IBOutlet var homeButton: UIButton!
    
    var totalFoodDays = 0
    var organizedFoodDays: [FoodDay] = []
    
    @IBOutlet var logFoodTable: UITableView!
    
    @IBOutlet var foodSuggestionTable: UITableView!
    var suggestionTableMgr: SuggestionManager?
    var foodSuggestionTableHidden = true
    
    @IBOutlet var foodSuggestionHeight: NSLayoutConstraint!
    @IBOutlet var topSupportString: NSLayoutConstraint!
    
    @IBOutlet var caloriePicker: UIPickerView!
    @IBOutlet var logFoodButton: UIButton!
    @IBOutlet var foodTextField: UITextField!
    @IBOutlet var calorieDisplay: UILabel!
    
    let pickerRows = [Int](0 ... 99)
    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        //setup food suggestion table
        //foodSuggestionTable.alpha = 0
        suggestionTableMgr = SuggestionManager( withDelegate: self)
        foodSuggestionTable.delegate = suggestionTableMgr
        foodSuggestionTable.dataSource = suggestionTableMgr
        foodSuggestionTable.layer.cornerRadius = 8
        foodSuggestionTable.layer.borderWidth = 3
        foodSuggestionTable.layer.borderColor = borderGray.cgColor
        
        caloriePicker.delegate = self
        logFoodTable.delegate = self
        logFoodTable.dataSource = self
        
        foodTextField.delegate = self
        foodTextField.layer.cornerRadius = 8
        foodTextField.layer.borderWidth = 3
        foodTextField.layer.borderColor = borderGray.cgColor
        
        logFoodButton.layer.cornerRadius = 18
        
        logFoodTable.layer.cornerRadius = 18
        logFoodTable.layer.borderWidth = 3
        logFoodTable.layer.borderColor = borderGray.cgColor
        
        //load foods eaten
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
                       
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodsConsumed" )
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sort]
       
        do {
            
            foodsEaten = try managedContext.fetch(fetchRequest)
            organizeDailyFoodsIntoSections(foodsEaten: foodsEaten)
            logFoodTable.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    @IBAction func homeTouched(_ sender: Any) {
        
        let firstVC = pvc!.pages[1]
        pvc!.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        
    }
    
    @IBAction func doneTouched(_ sender: Any) {
        
        /*self.mainVC?.doShowModal = false
         self.dismiss(animated: true) {
             
             self.mainVC?.goBackHome()
         }*/
        
    }
    
    @IBAction func logFoodTouched(_ sender: Any) {
        
        //make sure text field isn't empty
        if self.foodTextField.text != "" {
            //get the selected food object
            
            //see if food with the name in field exists in db
            guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext =
              appDelegate.persistentContainer.viewContext
            
            var foodName : String
            if(selectedFood != nil){
                foodName = selectedFood?.value(forKey: "name") as! String
            } else {
                foodName = ""
            }
            
            if(selectedFood == nil || foodTextField.text != foodName) {
                
                
                
                let fetchRequest =
                  NSFetchRequest<NSManagedObject>(entityName: "Foods" )
                
                
                fetchRequest.predicate = NSPredicate(format: "name == %@", foodTextField.text!)
                
                do {
                  let food = try managedContext.fetch(fetchRequest)
                    
                    //if doesn't exist add it
                    if(food.count == 0){
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Foods", in: managedContext)!
                        let newfood = NSManagedObject(entity: entity, insertInto: managedContext)
                        
                        newfood.setValue(self.calSelected, forKeyPath: "calories")
                        newfood.setValue(NSDate(), forKeyPath: "created")
                        newfood.setValue(self.foodTextField.text, forKeyPath: "name")
                        
                        do {
                            try managedContext.save()
                            
                            selectedFood = newfood
                            //now add the food to foods consumed
                            
                            self.saveToFoodsConsumed(context: managedContext, ofFood: newfood)
                            
                            
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    } else {
                        
                        //food exists, save it to foods consumed
                        
                        let ofFood = food.first
                        
                        selectedFood = ofFood
                        
                        self.setPickerToCalorieValue(value: ofFood?.value(forKey: "calories") as! Int)
                        
                        self.saveToFoodsConsumed(context: managedContext, ofFood: ofFood!)
                       
                    }
                    
                } catch let error as NSError {
                  print("Could not fetch. \(error), \(error.userInfo)")
                }
            } else {
                
                self.saveToFoodsConsumed(context: managedContext, ofFood: selectedFood!)
                
            }
        
        }
        
    
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let foodDay = organizedFoodDays[section]
        let foodArray = foodDay.foodsEaten
        
        return foodArray.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return totalFoodDays
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let foodDay = organizedFoodDays[indexPath.section]
    
        if indexPath.row < foodDay.foodsEaten.count {
            
            return 38
            
        } else {
            
            return 28
            
        }
        
    }
    
    //only workout set rows should be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let foodDay = organizedFoodDays[indexPath.section]
        if indexPath.row < foodDay.foodsEaten.count {
            return true
        }
        
        return false
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           
        let foodDay = organizedFoodDays[section]
    
        return foodDay.date
           
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let foodDay = organizedFoodDays[indexPath.section]
        let foodArray = foodDay.foodsEaten
        
        if indexPath.row < foodArray.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodLogCell", for: indexPath) as! FoodsEatenTableViewCell

            let foodEaten = foodArray[indexPath.row]
            
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "HH:mm:ss a"
            let timeNow = formatter2.string(from: foodEaten.value(forKey: "created") as! Date)
            
            let food = foodEaten.value(forKeyPath: "ofFood") as? NSManagedObject
            let foodName = food?.value(forKey: "name") as! String
            
            cell.caloriesLabel?.text =  String(format: "%d", food?.value(forKey: "calories") as! Int)
            
            cell.foodName?.text = foodName
            cell.dateEaten?.text = timeNow

            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieTotalCell", for: indexPath) as! CalorieTotalTableViewCell
            
            cell.totalCalories?.text = String(format: "%d", foodDay.totalDailyCalories)
            cell.totalCaloriesLabel?.text = "Total Daily Calories"
            
            return cell
            
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
                    
                    let currentFoodDay = organizedFoodDays[i]
                    indexToDelete += currentFoodDay.foodsEaten.count
                    
                }
            }

            
            indexToDelete += indexPath.row
            
            let setToDelete = foodsEaten[indexToDelete]
            let foodDay = organizedFoodDays[indexPath.section]
            let foodEatenArray = foodDay.foodsEaten
            
            var sectionToDelete = -1
            //if this is the last set in the day we need to delete the whole section
            if foodEatenArray.count == 1 {
                sectionToDelete = indexPath.section
            }
            
            managedContext.delete(setToDelete)
            
            do {
                try managedContext.save()
                foodsEaten.remove(at: indexToDelete)
                organizeDailyFoodsIntoSections(foodsEaten: foodsEaten)
                if sectionToDelete > -1 {
                    let indexSet = IndexSet(arrayLiteral: indexPath.section)
                    tableView.deleteSections(indexSet, with: .fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
        
                logFoodTable.reloadData()
                
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            
            

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let foodDay = organizedFoodDays[indexPath.section]
        
        //only should be able to select workout set rows
        if indexPath.row < foodDay.foodsEaten.count {
            let selectedFoodEaten = foodDay.foodsEaten[indexPath.row]
            let food = selectedFoodEaten.value(forKeyPath: "ofFood") as! NSManagedObject
            let foodName = food.value(forKey: "name") as! String
            let calories = food.value(forKey: "calories") as! Int
            
            selectedFood = food
            setPickerToCalorieValue(value: calories)
            foodTextField.text = foodName
        }
        
    }
    
    //======================================
    //===  picker view delegate methods ====
    //======================================
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerRows.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.textColor = UIColor(red: 84.0/255.0, green: 199.0/255.0, blue: 252.0/255.0, alpha: 1.0)
            pickerLabel?.font = UIFont(name: "Futura-Bold", size: 22)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }

        pickerLabel?.text = fetchLabelForRowNumber(row: row, component: component)

        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let caloriesSelected = ( pickerView.selectedRow(inComponent: 0) * 100) + pickerView.selectedRow(inComponent: 1)
        self.calSelected = caloriesSelected
        self.calorieDisplay.text = String(format: "%d Calories", caloriesSelected)
        
    }
    
    func fetchLabelForRowNumber(row: Int, component: Int) -> String {
        
        var retStr = ""
        
        if component == 0 {
            retStr = String(format: "%d", pickerRows[row])
        } else if component == 1 {
            
            if pickerRows[row] < 10 {
                retStr = String(format: "0%d", pickerRows[row])
            } else {
                retStr = String(format: "%d", pickerRows[row])
            }
            
        }
        
        return retStr
        
    }
    
    //===== end picker view delegate methods
    
    func organizeDailyFoodsIntoSections( foodsEaten: [NSManagedObject]) -> Void {
        
        organizedFoodDays = []
        
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE,  MMM d, yyyy"
           
        var lastDay = 0
        var lastMonth = 0
        var lastYear = 0
        var dayCounter = 0
        var totalCals = 0
        
        var foodsEatenArray : [NSManagedObject] = []
           
        var lastDayString : String = ""
        
        for foodEaten in foodsEaten {
              
            let created = foodEaten.value(forKey: "created") as! Date
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
                  
                  
                //copy arrays
                let copyOfFoodsEatenArray = foodsEatenArray
          
              
                let currentFoodDay = FoodDay(date: lastDayString, foodsEaten: copyOfFoodsEatenArray, totalDailyCalories: totalCals)
                organizedFoodDays.append(currentFoodDay)
                  
                //start a new day dict
                lastDay = day!
                lastMonth = month!
                lastYear = year!
                dayCounter += 1
           
                foodsEatenArray = []
                totalCals = 0
                  
            }
              
            let food = foodEaten.value(forKey: "ofFood") as! NSManagedObject
            let calories = food.value(forKey: "calories") as! Int
            
            totalCals += calories
            
            foodsEatenArray.append(foodEaten)
            lastDayString = dateString
              
              
        }
          
          
        //we gotta put the last day into the workout day array (if there are any sets from today)
        if foodsEatenArray.count > 0 {
              
            dayCounter += 1
                        
            //copy arrays to day dict
            let copyOfFoodsEatenArray = foodsEatenArray
     
              
            let currentFoodDay = FoodDay(date: lastDayString, foodsEaten: copyOfFoodsEatenArray, totalDailyCalories: totalCals)
            organizedFoodDays.append(currentFoodDay)
            organizedFoodDays.append(currentFoodDay)
        }
         
          
        totalFoodDays = dayCounter
        
        
    }
    
    func setPickerToCalorieValue(value: Int) -> Void {
        
        let remainder = value % 100
        let hundreds = (value - remainder) / 100
        
        self.caloriePicker.selectRow(hundreds, inComponent: 0, animated: true)
        self.caloriePicker.selectRow(remainder, inComponent: 1, animated: true)
        
        self.calorieDisplay.text = String(format: "%d Calories", value)
        
        
    }
    
    func saveToFoodsConsumed(context: NSManagedObjectContext, ofFood: NSManagedObject) -> Void {
        
        let entity = NSEntityDescription.entity(forEntityName: "FoodsConsumed", in: context)!
        let newfoodConsumed = NSManagedObject(entity: entity, insertInto: context)
        
        newfoodConsumed.setValue(ofFood, forKeyPath: "ofFood")
        newfoodConsumed.setValue(NSDate(), forKeyPath: "created")
        
        do {
            try context.save()
            
            foodsEaten.append(newfoodConsumed)
            organizeDailyFoodsIntoSections(foodsEaten: foodsEaten)
            logFoodTable.reloadData()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        suggestionTableMgr?.searchForFood(searchTerm: textField.text!)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideFoodSuggestionTable()
        return true
    }
    
    func showFoodSuggestionTable() -> Void {
        
        self.topSupportString.constant = -102
        self.foodSuggestionHeight.constant = 180
        self.view.setNeedsUpdateConstraints()

       
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 18.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            //self.foodSuggestionTable.alpha = 1
            self.view.layoutIfNeeded()
            
        }) { (true) in
            self.foodSuggestionTableHidden = false
        }
        
    }
    
    func hideFoodSuggestionTable() -> Void {

        
        self.topSupportString.constant = 40
        self.foodSuggestionHeight.constant = 0
        self.view.setNeedsUpdateConstraints()
    
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 18.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            //self.foodSuggestionTable.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { (true) in
            self.foodSuggestionTableHidden = true
        }
        
    }
    
    //==========================================
    //===  food suggestion delegate methods ====
    //==========================================
    
    func foodSuggestionsFound() {
        
        if foodSuggestionTableHidden {
            showFoodSuggestionTable()
        }
        
    }
    
    func foodSuggestionSelected(foodSelected: NSManagedObject) {
        
        
        let foodName = foodSelected.value(forKey: "name") as! String
        let calories = foodSelected.value(forKey: "calories") as! Int
        
        selectedFood = foodSelected
        setPickerToCalorieValue(value: calories)
        foodTextField.text = foodName
        
        hideFoodSuggestionTable()
        foodTextField.resignFirstResponder()
        
    }
  
    func reloadSuggestionTable() {
        
        foodSuggestionTable.reloadData()
        
    }
    

    
}
