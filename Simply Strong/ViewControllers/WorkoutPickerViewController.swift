//
//  WorkoutPickerViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/18/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData

class WorkoutPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    

    weak var mainVC : AddSetViewController?
    var exercises : [NSManagedObject] = []
    //var workoutNames = [String]()
    var selectedWorkoutIndex = 0
    
    @IBOutlet var workoutPicker: UIPickerView!
    @IBOutlet var selectButton: UIButton!
    
    
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

        selectButton.layer.cornerRadius = 18
        
        workoutPicker.delegate = self
        workoutPicker.dataSource = self
        
        workoutPicker.selectRow(selectedWorkoutIndex, inComponent: 0, animated: false)
        
       
    }
    

    //======================================
    //===  picker view delegate methods ====
    //======================================
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exercises.count
    }

    

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if exercises.count > 0 {
            let exercise = exercises[row]
            mainVC?.selectWorkoutName(exercise :exercise)
        }

        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()

            pickerLabel?.font = UIFont(name: "Futura", size: 18)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }

        pickerLabel?.text = fetchLabelForRowNumber(row: row)

        return pickerLabel!;
    }
    
    func fetchLabelForRowNumber(row: Int) -> String {
        
        let exercise = exercises[row]
        return (exercise.value(forKey: "name") as? String)!
        
    }
    
    //===== end picker view delegate methods
    

    
    @IBAction func selectTouched(_ sender: Any) {
        
        self.dismiss(animated: true) {}
        
    }
}
