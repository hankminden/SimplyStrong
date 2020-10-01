//
//  SavedFoodsViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/1/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class SavedFoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var savedFoodsTable: UITableView!
    var foods : [NSManagedObject] = []
    
    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savedFoodsTable.layer.cornerRadius = 18
        savedFoodsTable.layer.borderWidth = 3
        savedFoodsTable.layer.borderColor = borderGray.cgColor
        
        savedFoodsTable.delegate = self
        savedFoodsTable.dataSource = self
        
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
    
    //======================================
    //===  table view delegate methods =====
    //======================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let food = foods[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodsCell", for: indexPath) as! FoodTableViewCell
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm:ss a"
        let timeNow = formatter2.string(from: food.value(forKey: "created") as! Date)
        
        cell.calories?.text = String(format: "%d", food.value(forKey: "calories") as! Int)
        cell.created?.text = timeNow
        cell.foodName?.text = food.value(forKey: "name") as? String
        
        return cell
        
    }
    

}
