//
//  HomeViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/27/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData
import Charts



class HomeViewController: UIViewController, ChartViewDelegate {

    

    weak var pvc : MainPageViewController?
    var calorieData : BarChartData?
    var workoutChartData : LineChartData?
    var workoutChartXAxisLabels : [String] = []
    var foodChartXAxisLabels : [String] = []
    
    
    @IBOutlet var calorieBarChart: BarChartView!
    @IBOutlet var workoutLineChart: LineChartView!
    @IBOutlet var logFoodButton: UIButton!
    @IBOutlet var logSetButton: UIButton!
    
    @IBOutlet var workoutViewContainer: UIView!
    @IBOutlet var calorieChartContainer: UIView!
    
    var workoutDayLookup : [String:Int] = [:]
    var foodDayLookup : [String:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
        
        calorieChartContainer.layer.cornerRadius = 18
        calorieChartContainer.layer.borderWidth = 3
        calorieChartContainer.layer.borderColor = borderGray.cgColor
        //calorieChartContainer.backgroundColor = .white
        calorieChartContainer.clipsToBounds = true
        
        workoutViewContainer.layer.cornerRadius = 18
        workoutViewContainer.layer.borderWidth = 3
        workoutViewContainer.layer.borderColor = borderGray.cgColor
        //workoutViewContainer.backgroundColor = .white
        workoutViewContainer.clipsToBounds = true
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupAllViews()
        

    }
    
    func setupAllViews() {
        
        let foodDays = getLastWeekTotalCalories()
        
        setupCalorieChart(foodDays: foodDays)
                
        let workOutDays = getLastWeekWorkouts()
        
        if workOutDays.count > 0 {
            setupWorkoutChart( workoutDays: workOutDays)
        } else {
            
            let blankWorkoutDay = WorkoutDay(setTypes: ["Push Ups","Pull Ups","Crunches","Body Weight Squats"], setDict: ["Push Ups":0,"Pull Ups":0,"Crunches":0,"Body Weight Squats":0], setArray: [], dateString: "", date: Date())
            let blankWorkouts = [blankWorkoutDay]
            
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local
            let components = calendar.dateComponents([.month, .day, .year], from: Date())
            let day = components.day!
            let month = components.month!
            let year = components.year!
            let key = String(format: "%d_%d_%d", day, month, year)
            workoutDayLookup[key] = 0
            setupWorkoutChart(workoutDays: blankWorkouts)
            
        }
        
    }

    @IBAction func testButtonTouched(_ sender: Any) {
        
      
        let entry7 = self.calorieData?.dataSets[0].entryForIndex(7)?.y
        var phase = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if phase > 1000.0 {
                print("done invalidating timer")
                
                timer.invalidate()
                return
            }
            
            self.calorieData?.dataSets[0].entryForIndex(7)?.y = entry7! + phase
            
            if(phase > 400){
                self.calorieBarChart.leftAxis.axisMaximum = entry7! + phase
                self.calorieBarChart.rightAxis.axisMaximum = entry7! + phase
                
            }
            
       
            self.calorieBarChart.notifyDataSetChanged()
            
            phase += 10
        }
        
        
    }
    @IBAction func logFoodTouched(_ sender: Any) {
        
        let firstVC = pvc!.pages[0]
        pvc!.setViewControllers([firstVC], direction: .reverse, animated: true, completion: nil)
        
    }
    
    @IBAction func logSetTouched(_ sender: Any) {
        
        let firstVC = pvc!.pages[2]
        pvc!.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        
    }
    
    func setupWorkoutChart( workoutDays : [WorkoutDay]) -> Void {
        
        workoutLineChart.delegate = self
        
        workoutLineChart.chartDescription?.enabled = true
        workoutLineChart.chartDescription?.font = UIFont(name: "Futura", size: 10)!
        workoutLineChart.chartDescription?.text = "Total Daily Workouts"
        //workoutLineChart.chartDescription?.position = CGPoint.init(x: 0.0, y: 0.0)

        workoutLineChart.leftAxis.enabled = false
        workoutLineChart.rightAxis.drawAxisLineEnabled = false
        workoutLineChart.xAxis.drawAxisLineEnabled = false
        
        
        
        workoutLineChart.drawBordersEnabled = false
        workoutLineChart.setScaleEnabled(true)
        
        workoutLineChart.leftAxis.labelFont = UIFont(name: "Futura", size: 8)!
        workoutLineChart.rightAxis.labelFont = UIFont(name: "Futura", size: 8)!
        workoutLineChart.legend.font = UIFont(name: "Futura", size: 10)!
        
        
        
        workoutLineChart.animate(yAxisDuration: 1 , easingOption: ChartEasingOption.linear)
        
        organizeAndChartWorkoutWeek( lastWeekWorkouts: workoutDays)
        
        workoutLineChart.xAxis.labelPosition = .bottom
        workoutLineChart.xAxis.labelFont = UIFont(name: "Futura", size: 8)!
        workoutLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:workoutChartXAxisLabels)
        workoutLineChart.data = workoutChartData
        
        workoutLineChart.clipsToBounds = false
        
    }
    
    func setupCalorieChart( foodDays : [FoodDay]) -> Void {
        
        calorieBarChart.delegate = self
        
        calorieBarChart.chartDescription?.enabled = true
        calorieBarChart.chartDescription?.font = UIFont(name: "Futura", size: 10)!
        calorieBarChart.chartDescription?.text = "Total Daily Calories"
      
        calorieBarChart.maxVisibleCount = 60
        calorieBarChart.pinchZoomEnabled = false
        calorieBarChart.drawBarShadowEnabled = false
        
        calorieBarChart.leftAxis.enabled = false
        calorieBarChart.rightAxis.drawAxisLineEnabled = false
        calorieBarChart.xAxis.drawAxisLineEnabled = false
        
        
        let xAxis = calorieBarChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: "Futura", size: 8)!

        calorieBarChart.leftAxis.labelFont = UIFont(name: "Futura", size: 8)!
        calorieBarChart.rightAxis.labelFont = UIFont(name: "Futura", size: 8)!
        calorieBarChart.legend.enabled = false

        calorieBarChart.fitBars = true
        calorieBarChart.xAxis.granularity = 1
        
        organizeAndChartCaloriesConsumed(lastWeekFoodConsumed: foodDays)
        
        calorieBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:foodChartXAxisLabels)
        
        calorieBarChart.animate(yAxisDuration: 1 , easingOption: ChartEasingOption.linear)
        calorieBarChart.data = calorieData
        
        calorieBarChart.clipsToBounds = false
        
    }
    
    func getLastWeekTotalCalories() -> [FoodDay] {
        
        guard let appDelegate =
             UIApplication.shared.delegate as? AppDelegate else {
             return []
         }
                        
         let managedContext = appDelegate.persistentContainer.viewContext
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        //get start of day 7 days ago
        let today = calendar.startOfDay(for: Date())
        let dateFrom = calendar.date(byAdding: .day, value: -7, to: today)
        let fromPredicate = NSPredicate(format: "created >= %@",  dateFrom! as NSDate)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodsConsumed" )
        
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = fromPredicate
                        
     
        
         do {
             
            let foodsEaten = try managedContext.fetch(fetchRequest)
             
            var organizedFoodDays : [FoodDay] = []
               
            let calendar = NSCalendar.current
            let dateFormatter = DateFormatter()
           
            dateFormatter.dateFormat = "EEE"
                  
            var lastDay = 0
            var lastMonth = 0
            var lastYear = 0
            var dayCounter = 0
            var totalCals = 0
            
            var day : Int = 0
            var month : Int = 0
            var year : Int = 0
               
            var foodsEatenArray : [NSManagedObject] = []
                  
            var lastDayString : String = ""
            var lastCreated : Date = Date()
            
            for foodEaten in foodsEaten {
                     
                let created = foodEaten.value(forKey: "created") as! Date
                let components = calendar.dateComponents([.month, .day, .year], from: created)
                
                day = components.day!
                month = components.month!
                year = components.year!
                let dateString = dateFormatter.string(from: created)
                     
                     
                if lastDay == 0 {
                    //this is first iteration
                    lastDay = day
                    lastMonth = month
                    lastYear = year
                         
                }
                     
                if day != lastDay || month != lastMonth || year != lastYear {
                         
                    let key = String(format: "%d_%d_%d", lastDay, lastMonth, lastYear)
                    foodDayLookup[key] = dayCounter
                    
                       //copy arrays
                    let copyOfFoodsEatenArray = foodsEatenArray
                 
                     
                    let currentFoodDay = FoodDay(date: lastCreated, dateString: lastDayString, foodsEaten: copyOfFoodsEatenArray, totalDailyCalories: totalCals)
                       organizedFoodDays.append(currentFoodDay)
                         
                    //start a new day dict
                    lastDay = day
                    lastMonth = month
                    lastYear = year
                    dayCounter += 1
                  
                    foodsEatenArray = []
                    totalCals = 0
                         
                }
                     
                let food = foodEaten.value(forKey: "ofFood") as! NSManagedObject
                let calories = food.value(forKey: "calories") as! Int
                   
                totalCals += calories
                   
                foodsEatenArray.append(foodEaten)
                lastDayString = dateString
                lastCreated = created
                     
            }
                 
                 
            //we gotta put the last day into the workout day array (if there are any sets from today)
            if foodsEatenArray.count > 0 {
                     
                let key = String(format: "%d_%d_%d", day,month,year)
                foodDayLookup[key] = dayCounter
                
                dayCounter += 1
                               
                //copy arrays to day dict
                let copyOfFoodsEatenArray = foodsEatenArray
                
              
                     
                let currentFoodDay = FoodDay(date: lastCreated, dateString: lastDayString, foodsEaten: copyOfFoodsEatenArray, totalDailyCalories: totalCals)
                organizedFoodDays.append(currentFoodDay)
              
            }
                
            
            
            
            //totalFoodDays = dayCounter
            return organizedFoodDays
             
         } catch let error as NSError {
             print("Could not fetch. \(error), \(error.userInfo)")
            return []
         }
        
        
        
    }
    
    func getLastWeekWorkouts() -> [WorkoutDay] {
        
        guard let appDelegate =
             UIApplication.shared.delegate as? AppDelegate else {
             return []
        }
                        
        let managedContext = appDelegate.persistentContainer.viewContext
                    
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        //get start of day 7 days ago
        let today = calendar.startOfDay(for: Date())
        let dateFrom = calendar.date(byAdding: .day, value: -7, to: today)
        let fromPredicate = NSPredicate(format: "created >= %@",  dateFrom! as NSDate)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sets" )
        
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = fromPredicate
        
        do {
            
            let setsCompleted = try managedContext.fetch(fetchRequest)
            
            var organizedSets : [WorkoutDay] = []
           
            //let calendar = NSCalendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
               
            var lastDay = 0
            var lastMonth = 0
            var lastYear = 0
            var dayCounter = 0
            
            var day : Int = 0
            var month : Int = 0
            var year : Int = 0
            
            var setTypes : [String] = []
            var setDict: [String: Int] = [:]
            var setArray : [NSManagedObject] = []
               
            var lastDayString : String = ""
            var lastCreated : Date = Date()
               
            for workoutSet in setsCompleted {
                   
                   let created = workoutSet.value(forKey: "created") as! Date
                   let components = calendar.dateComponents([.month, .day, .year], from: created)
                
                    day = components.day!
                    month = components.month!
                    year = components.year!
                   let dateString = dateFormatter.string(from: created)
                   
                   
                   
                   if lastDay == 0 {
                       //this is first iteration
                       lastDay = day
                       lastMonth = month
                       lastYear = year
                       
                   }
                   
                   if day != lastDay || month != lastMonth || year != lastYear {
                       
                        let key = String(format: "%d_%d_%d", lastDay, lastMonth, lastYear)
                        workoutDayLookup[key] = dayCounter
                       
                       //copy arrays to day dict
                       let copyOfSetTypes = setTypes
                       let copyOfSetDict = setDict
                       let copyOfSets = setArray
             
                   
                       let currentWorkoutDay = WorkoutDay(setTypes: copyOfSetTypes, setDict: copyOfSetDict, setArray: copyOfSets, dateString: lastDayString, date: lastCreated)
                       organizedSets.append(currentWorkoutDay)
                       
                       //start a new day dict
                       lastDay = day
                       lastMonth = month
                       lastYear = year
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
                   lastCreated = created
                   
               }
               
               
               //we gotta put the last day into the workout day array (if there are any sets from today)
               if setArray.count > 0 {
                   
                    let key = String(format: "%d_%d_%d", day,month,year)
                    workoutDayLookup[key] = dayCounter
                
                   dayCounter += 1
                             
                   //copy arrays to day dict
                   let copyOfSetTypes = setTypes
                   let copyOfSetDict = setDict
                   let copyOfSets = setArray
                   
                   let currentWorkoutDay = WorkoutDay(setTypes: copyOfSetTypes, setDict: copyOfSetDict, setArray: copyOfSets, dateString: lastDayString, date: lastCreated)
                                    organizedSets.append(currentWorkoutDay)
               }
              
               
                //totalDaysOfWorkouts = dayCounter
                return organizedSets
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
           return []
        }
        
    }
    
    func organizeAndChartCaloriesConsumed( lastWeekFoodConsumed: [FoodDay]) {
        
        var daysOfThisWeekArray : [String] = []
             
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let today = calendar.startOfDay(for: Date())
             
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        var vals : [BarChartDataEntry] = []
        var foodChartCustomColors : [NSUIColor] = []
        
        //loop from today to seven days ago
        for i in 0 ... 7 {
                 
            let dateFrom = calendar.date(byAdding: .day, value: -(7-i), to: today)
            let components = calendar.dateComponents([.month, .day, .year], from: dateFrom!)
                 
            let day = components.day!
            let month = components.month!
            let year = components.year!
                 
            let key = String(format: "%d_%d_%d", day, month, year)
            let dateString = dateFormatter.string(from: dateFrom!)
                 
            daysOfThisWeekArray.append(key)
            if i == 7 {
                foodChartXAxisLabels.append("Today")
                foodChartCustomColors.append(UIColor.darkGray)
            } else {
                foodChartXAxisLabels.append(dateString)
                foodChartCustomColors.append(UIColor(red: 84.0/255.0, green: 199.0/255.0, blue: 252.0/255.0, alpha: 1.0))
            }
        
            if foodDayLookup[key] != nil {
                     
                let fooddayindex = foodDayLookup[key]
                let foodday = lastWeekFoodConsumed[fooddayindex!] as FoodDay
                let entry = BarChartDataEntry(x : Double(i), y: Double(foodday.totalDailyCalories))
                vals.append(entry)
                    
            } else {
                
                let entry = BarChartDataEntry(x : Double(i), y: Double(0))
                vals.append(entry)
                
            }
                 
        }
        let set = BarChartDataSet(entries: vals, label: "Total Daily Calories")
        set.colors = foodChartCustomColors
        calorieData = BarChartData(dataSet: set)
        
    }
    
    func organizeAndChartWorkoutWeek( lastWeekWorkouts: [WorkoutDay]) {
        
        
        
        var weeklyExerciseTotals : [String:Int] = [:]
        var weeklyExerciseNamesArray : [String] = []
        var daysOfThisWeekArray : [String] = []
             
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let today = calendar.startOfDay(for: Date())
             
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
             
            
             
             //loop from today to seven days ago
             for i in 0 ... 7 {
                 
                 let dateFrom = calendar.date(byAdding: .day, value: -(7-i), to: today)
                 let components = calendar.dateComponents([.month, .day, .year], from: dateFrom!)
                 
                 
                 let day = components.day!
                 let month = components.month!
                 let year = components.year!
                 
                 let key = String(format: "%d_%d_%d", day, month, year)
                 let dateString = dateFormatter.string(from: dateFrom!)
                 
                 daysOfThisWeekArray.append(key)
                 if i == 7 {
                     workoutChartXAxisLabels.append("Today")
                 } else {
                     workoutChartXAxisLabels.append(dateString)
                 }
        
                 
                 
                 if workoutDayLookup[key] != nil {
                     
                     let workoutIndex = workoutDayLookup[key]
                     let workoutday = lastWeekWorkouts[workoutIndex!] as WorkoutDay
                     let exerciseNames = workoutday.setTypes
                     
                     for j in 0 ... exerciseNames.count - 1 {
                         
                         let exerciseName = exerciseNames[j] as String
                         let dailyTotal = workoutday.setDict[exerciseName]
                         
                         if weeklyExerciseTotals[exerciseName] != nil {
                             weeklyExerciseTotals[exerciseName]! += dailyTotal!
                         } else {
                             weeklyExerciseTotals[exerciseName] = dailyTotal
                             weeklyExerciseNamesArray.append(exerciseName)
                         }
                         
                         
                     }
                   
                 }
                 
             }
             
             var chartDataSets : [LineChartDataSet] = []
             //let data = LineChartData(dataSets : chartDataSets)
             
             let setColors = [NSUIColor.init(red: 27/255, green: 38/255, blue: 44/255, alpha: 1.0),
                              NSUIColor.init(red: 15/255, green: 76/255, blue: 117/255, alpha: 1.0),
                              NSUIColor.init(red: 50/255, green: 130/255, blue: 184/255, alpha: 1.0),
                              NSUIColor.init(red: 187/255, green: 226/255, blue: 250/255, alpha: 1.0)]
             
             //now we know all of the exercises done this week we can create the graphs
             let wc = weeklyExerciseNamesArray.count - 1
             for k in 0 ... wc {
                 
                 let exerciseName = weeklyExerciseNamesArray[k]
                 
                 var vals : [ChartDataEntry] = []
                 
                 for l in 0 ... daysOfThisWeekArray.count - 1 {
                     
                     let key = daysOfThisWeekArray[l]
                     
                     if workoutDayLookup[key] != nil {
                         
                         let workoutIndex = workoutDayLookup[key]
                         let workoutday = lastWeekWorkouts[workoutIndex!] as WorkoutDay
                         let dailyTotal = (workoutday.setDict[exerciseName] ?? 0) as Int
                         let entry = ChartDataEntry(x : Double(l), y: Double(dailyTotal))
                         vals.append(entry)
                         
                     } else {
                         let entry = ChartDataEntry(x : Double(l), y: Double(0))
                         vals.append(entry)
                     }
                     
                 }
                 
                 let set = LineChartDataSet(entries: vals, label: exerciseName)
                 set.mode = .cubicBezier
                 if(k > 3){
                     set.setColor(setColors[k % 4])
                 } else {
                     set.setColor(setColors[k])
                 }
                 
                 set.circleRadius = 1
               
                 set.drawCircleHoleEnabled = false
                 chartDataSets.append(set)
                 
             }
             
             workoutChartData = LineChartData(dataSets: chartDataSets)
        
    }
     
    
    @IBAction func settingsTouched(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
        settingsVC.pvc = pvc
        settingsVC.homevc = self
        
        self.present(settingsVC, animated: true) {
              
        }
        
    }
}
