//
//  LogFoodViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/21/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class LogFoodViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    


    weak var mainVC : LogFoodTabContainerViewController?
    var selectedFood : NSManagedObject?
    var calSelected : Int = 0
    var foods : [NSManagedObject] = []
    var foodsEaten : [NSManagedObject] = []
    
    @IBOutlet var logFoodTable: UITableView!
    @IBOutlet var caloriePicker: UIPickerView!
    @IBOutlet var logFoodButton: UIButton!
    @IBOutlet var foodTextField: UITextField!
    @IBOutlet var calorieDisplay: UILabel!
    
    let pickerRows = [Int](0 ... 99)
    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
       
        do {
            
            foodsEaten = try managedContext.fetch(fetchRequest)
            
            logFoodTable.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    

    @IBAction func doneTouched(_ sender: Any) {
        
        self.mainVC?.doShowModal = false
         self.dismiss(animated: true) {
             
             self.mainVC?.goBackHome()
         }
        
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
            
            if(selectedFood == nil) {
                
                
                
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodsEaten.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodLogCell", for: indexPath) as! FoodsEatenTableViewCell

        let foodEaten = foodsEaten[indexPath.row]
        
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm:ss a"
        let timeNow = formatter2.string(from: foodEaten.value(forKey: "created") as! Date)
        
        let food = foodEaten.value(forKeyPath: "ofFood") as? NSManagedObject
        let foodName = food?.value(forKey: "name") as! String
        
        cell.caloriesLabel?.text =  String(format: "%d", food?.value(forKey: "calories") as! Int)
        
        cell.foodName?.text = foodName
        cell.dateEaten?.text = timeNow

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
            let setToDelete = foodsEaten[indexPath.row]
            managedContext.delete(setToDelete)
            
            do {
                try managedContext.save()
                foodsEaten.remove(at: indexPath.row)
                // delete the table view row
                tableView.deleteRows(at: [indexPath], with: .fade)
                      
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            
            

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let foodEaten = foodsEaten[indexPath.row]
        let food = foodEaten.value(forKeyPath: "ofFood")
        
        selectedFood = food as! NSManagedObject
    
        setPickerToCalorieValue(value: selectedFood?.value(forKey: "calories") as! Int)
        foodTextField.text = selectedFood?.value(forKey: "name") as! String
        
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

            pickerLabel?.font = UIFont(name: "Futura", size: 18)
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
            logFoodTable.reloadData()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
  
}
