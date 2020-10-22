//
//  SavedFoodsViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/1/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class SavedFoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StrongAlertViewDelegate {

    

    @IBOutlet weak var savedFoodsTable: UITableView!
    var foods : [NSManagedObject] = []
    weak var pvc : LogFoodViewController?
    var strongAlert : StrongAlertView?
    var rowToDelete : Int = 0
    
    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    let formatter2 = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter2.dateFormat = "HH:mm:ss a"

        savedFoodsTable.layer.cornerRadius = 18
        savedFoodsTable.layer.borderWidth = 3
        savedFoodsTable.layer.borderColor = borderGray.cgColor
        
        savedFoodsTable.delegate = self
        savedFoodsTable.dataSource = self
        
        strongAlert = StrongAlertView.init(frame: CGRect(x: (self.view.frame.size.width/2)-(360/2), y:-320, width: 360, height: 320))
        strongAlert?.delegate = self
        self.view.addSubview(strongAlert!)
        
        getSavedFoods()
        
    }
    

    func getSavedFoods() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Foods" )
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
         do {
             
             foods = try managedContext.fetch(fetchRequest)
             
             savedFoodsTable.reloadData()
             
         } catch let error as NSError {
             print("Could not fetch. \(error), \(error.userInfo)")
         }
        
    }
    
    func deleteFoodAtRow( row: Int) -> Void {
        
        let foodToDelete = foods[row]
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(foodToDelete)
        
        do {
            try managedContext.save()
            foods.remove(at: row)
            let indexPath = IndexPath(row: row, section: 0)
            savedFoodsTable.deleteRows(at: [indexPath], with: .fade)
            pvc?.loadFoodsEaten()
            
            //self.savedFoodsTable.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    //======================================
    //===  table view delegate methods =====
    //======================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let food = foods[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsCell", for: indexPath) as! FoodTableViewCell
        
     
        
        let timeNow = formatter2.string(from: food.value(forKey: "created") as! Date)
        
        cell.calories?.text = String(format: "%d", food.value(forKey: "calories") as! Int)
        cell.created?.text = timeNow
        cell.foodName?.text = food.value(forKey: "name") as? String
        
        return cell
        
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete {
            
            let foodToDelete = foods[indexPath.row]
            
            //get all foods consumed with this food in it
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                return
            }
                           
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let ofFoodPredicate = NSPredicate(format: "ofFood = %@",  foodToDelete)
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodsConsumed" )
            fetchRequest.predicate = ofFoodPredicate
            
            do {
                let foodsEaten = try managedContext.fetch(fetchRequest)
                
                if foodsEaten.count > 0 {
                    
                    rowToDelete = indexPath.row
                    strongAlert?.alertTitle.text = "Warning"
                    if(foodsEaten.count == 1){
                        strongAlert?.alertBody.text = "This food has one entry associated with it. Deleting this food will also delete that entry.  "
                    } else {
                        strongAlert?.alertBody.text = "This food has \(foodsEaten.count) entries associated with it. Deleting this food will also delete those entries."
                    }
                    strongAlert?.buttonOne.setTitle("Proceed", for: UIControl.State.normal)
                    strongAlert?.buttonTwo.setTitle("Cancel", for: UIControl.State.normal)
                    strongAlert?.showStrongAlert()
                    
                } else {
                    self.deleteFoodAtRow(row: indexPath.row)
                }
                
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
              
            }
            
        }
        
    }
    
    //=============================================
    //===  strong alert view delegate methods =====
    //=============================================
    
    func buttonOneTouchedDM() {
        deleteFoodAtRow(row: rowToDelete)
        strongAlert?.hideStrongAlert()
    }
    
    func buttonTwoTouchedDM() {
        strongAlert?.hideStrongAlert()
    }

}
