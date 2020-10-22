//
//  SuggestionManager.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/25/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

protocol SuggestionManagerDelegate {
    func foodSuggestionsFound() -> Void
    func foodSuggestionSelected( foodSelected: NSManagedObject ) -> Void
    func reloadSuggestionTable() -> Void
}

class SuggestionManager: NSObject, UITableViewDelegate, UITableViewDataSource {

  
    var foodSuggestions : [NSManagedObject] = []
    var delegate : SuggestionManagerDelegate

    init( withDelegate: SuggestionManagerDelegate) {
        delegate = withDelegate
        
    }
    
    func searchForFood ( searchTerm: String) -> Void {
        
        guard let appDelegate =
               UIApplication.shared.delegate as? AppDelegate else {
               return
           }
                          
           let managedContext = appDelegate.persistentContainer.viewContext
                          
           let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Foods" )
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
           do {
            let foodSuggestionsAttempt = try managedContext.fetch(fetchRequest)
            if foodSuggestionsAttempt.count > 0 {
                foodSuggestions = foodSuggestionsAttempt
                delegate.reloadSuggestionTable()
                delegate.foodSuggestionsFound()
            }
            
               
           } catch let error as NSError {
               print("Could not fetch. \(error), \(error.userInfo)")
           }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodSuggestionCell", for: indexPath) as! FoodSuggestionTableViewCell
        
        let food = foodSuggestions[indexPath.row]
        let foodName = food.value(forKey: "name") as! String
        let calories = food.value(forKey: "calories") as! Int
        
        cell.foodName?.text = foodName
        cell.calories?.text = String(format: "%d", calories)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let food = foodSuggestions[indexPath.row]
        
        delegate.foodSuggestionSelected( foodSelected: food)
        
    }
    

    
}
