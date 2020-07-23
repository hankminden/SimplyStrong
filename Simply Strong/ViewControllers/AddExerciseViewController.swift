//
//  AddExerciseViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/20/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class AddExerciseViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var addExerciseButton: UIButton!
    @IBOutlet var exerciseNameTextField: UITextField!
    
    let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addExerciseButton.layer.cornerRadius = 18
        
        
        
        exerciseNameTextField.delegate = self
        exerciseNameTextField.layer.cornerRadius = 8
        exerciseNameTextField.layer.borderWidth = 3
        exerciseNameTextField.layer.borderColor = borderGray.cgColor
    }
    
    func saveExercise(named: String) -> Void {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Exercises", in: managedContext)!
        let exercise = NSManagedObject(entity: entity, insertInto: managedContext)
        
        exercise.setValue(named, forKeyPath: "Name")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
    }

    @IBAction func addExerciseTouched(_ sender: Any) {
        
        saveExercise(named: exerciseNameTextField.text!)
        self.dismiss(animated: true) {}
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
