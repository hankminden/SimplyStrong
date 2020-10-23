//
//  SettingsViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 9/15/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import MobileCoreServices
import CloudKit
import StoreKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIDocumentPickerDelegate,UINavigationControllerDelegate, ToastViewDelegate {

    enum CopyPersistentStoreErrors: Error {
        case invalidDestination(String)
        case destinationError(String)
        case destinationNotRemoved(String)
        case copyStoreError(String)
        case invalidSource(String)
    }
    
    weak var pvc : MainPageViewController?
    weak var homevc : HomeViewController?
    var toastView : ToastView?
    var filesDestination : String?
    var products: [SKProduct] = []
    var pickingMode: Int = 0 // 0: none, 1: folder, 2: files
    var proModePurchased : Bool = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        toastView = ToastView.init(frame: CGRect(x: self.view.frame.origin.x, y: -80, width: self.view.frame.size.width, height: 80))
        toastView?.delegate = self
        self.view.addSubview(toastView!)
        
        filesDestination = nil
        
        fetchProductsFromAppStore()
        
        //add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.handlePurchaseNotification(_:)),
                                               name: .IAPManagerPurchaseNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.handlePurchaseFailedNotification(_:)),
                                               name: .IAPManagerPurchaseFailedNotification,
                                               object: nil)
        
        //check to see if IAP has been purchased
        if UserDefaults.standard.value(forKey: "simply_strong_iap_0") != nil {
            proModePurchased =  UserDefaults.standard.value(forKey: "simply_strong_iap_0") as! Bool
        }
        
        #if targetEnvironment(simulator)
            proModePurchased = true
        #endif
     
    
    }
    
    func fetchProductsFromAppStore() {
        
        SimplyStrongProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
            }
        }
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        activityIndicator.stopAnimating()
      guard
        let productID = notification.object as? String
      else { return }

        if productID == "simply_strong_iap_0" {
            
            toastView?.titleLabel.text = "Pro Mode Unlocked"
            toastView?.bodyText.text = "You can now utilize all pro features and functionality!"
            toastView?.showToast()
            
            proModePurchased = true
            tableView.reloadData()
        }
    }
    
    
    
    @objc func handlePurchaseFailedNotification(_ notification: Notification) {
        
        toastView?.titleLabel.text = "Pro Mode Unlocked"
        toastView?.bodyText.text = "You can now utilize all pro features and functionality!"
        toastView?.showToast()
        
        activityIndicator.stopAnimating()
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 3
        case 1:
            return 5
        case 2:
            return 2
        case 3:
            if proModePurchased {
                return 1
            } else {
                return 2
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Backup User Data"
        case 1:
            return "Export to CSV"
        case 2:
            return "Import from CSV"
        case 3:
            return "Unlock All Pro Features"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Back up data to local folder"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "backUp")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Back up data to iCloud folder"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "backUpToCloud")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Restore from backup folder"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "restore")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Export food table"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "exportFoodsCSV")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Export food log"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "exportFoodLogCSV")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Export exercise table"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "exportFoodsCSV")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Export exercise log"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "exportFoodLogCSV")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Export all data"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "exportAllCSV")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Import food table"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "restore")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingLabel.text = "Import exercise table"
                cell.settingImage.image = UIImage(imageLiteralResourceName: "restore")
                if !proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                } else {
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingImage.image = UIImage(imageLiteralResourceName: "purchase")
                if proModePurchased {
                    cell.settingLabel.textColor = .lightGray
                    cell.settingLabel.text = "Pro mode unlocked"
                } else {
                    cell.settingLabel.text = "One-time purchase of $4.99"
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
                cell.settingImage.image = UIImage(imageLiteralResourceName: "restorePurchase")
                if !proModePurchased {
                    cell.settingLabel.text = "Restore purchase"
                    cell.settingLabel.textColor = .darkGray
                }
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
        
            switch indexPath.row {
            case 0:
                if proModePurchased {
                    backupToLocal()
                } else { showPuchaseMessage() }
                break
            case 1:
                if proModePurchased {
                    backupToCloud()
                } else { showPuchaseMessage() }
                break
            case 2:
                if proModePurchased {
                    restoreFromStore()
                } else { showPuchaseMessage() }
                break
            default:
                break
            }
        case 1:
            
            switch indexPath.row {
            case 0:
                if proModePurchased {
                    backupToCSV(filename: "FoodTable", csvType: 0)
                } else { showPuchaseMessage() }
                break
            case 1:
                if proModePurchased {
                    backupToCSV(filename: "FoodLog", csvType: 1)
                } else { showPuchaseMessage() }
                break
            case 2:
                if proModePurchased {
                    backupToCSV(filename: "ExerciseTable", csvType: 2)
                } else { showPuchaseMessage() }
                break
            case 3:
                if proModePurchased {
                    backupToCSV(filename: "ExerciseLog", csvType: 3)
                } else { showPuchaseMessage() }
                break
            case 4:
                if proModePurchased {
                    backupToCSV(filename: "FoodTable", csvType: 0)
                    backupToCSV(filename: "FoodLog", csvType: 1)
                    backupToCSV(filename: "ExerciseTable", csvType: 2)
                    backupToCSV(filename: "ExerciseLog", csvType: 4)
                } else { showPuchaseMessage() }
                break
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                if proModePurchased {
                    importFromFoodCSV()
                } else { showPuchaseMessage() }
                break
            case 1:
                if proModePurchased {
                    importFromExerciseCSV()
                } else { showPuchaseMessage() }
                break
            default:
                break
            }
            break
        case 3:
            switch indexPath.row {
            case 0:
                if !proModePurchased {
                    purchaseProVersion()
                }
                break
            case 1:
                restoreProVersion()
                break
            default:
                break
            }
        default:
            break
        }
        
    }
    
    func importFromFoodCSV() {
        
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.comma-separated-values-text"], in: .open)
        importMenu.delegate = self
   
        self.present(importMenu, animated: true, completion: nil)
        self.pickingMode = 3
        
    }
    
    func importFromExerciseCSV() {
        
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.comma-separated-values-text"], in: .open)
        importMenu.delegate = self
   
        self.present(importMenu, animated: true, completion: nil)
        self.pickingMode = 4
        
    }
    
    func showPuchaseMessage(){
        toastView?.titleLabel.text = "Pro Mode Required"
        toastView?.bodyText.text = "A one-time purchase of $4.99 will unlock this functionality forever"
        toastView?.showToast()
    }

    func backupToCSV(filename: String , csvType: Int) {
        
        let exportFolderBaseUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let exportFolderName = "ExportCSV" + dayStringFromTime()
        
        let exportFolder = exportFolderBaseUrl.appendingPathComponent(exportFolderName)
        let exportedCSVpath = exportFolderBaseUrl.appendingPathComponent(exportFolderName, isDirectory: true).appendingPathComponent(filename, isDirectory: false).appendingPathExtension("csv")
        
        
       
        var csvText : String?
        var successMessage : String = ""
        
        switch csvType {
        case 0: //
            csvText = getSavedFoodsCSVText()
            successMessage = "Your saved foods table was saved to SimplyStrong\\\(exportFolderName)\\\(filename).csv which can be accessed using the Files App."
            break
        case 1:
            csvText = getFoodLogCSVText()
            successMessage = "Your food log was saved to SimplyStrong\\\(exportFolderName)\\\(filename).csv which can be accessed using the Files App."
        case 2:
            csvText = getExerciseTableCSVText()
            successMessage = "Your exercise table was saved to SimplyStrong\\\(exportFolderName)\\\(filename).csv which can be accessed using the Files App."
        case 3:
            csvText = getExerciseLogCSVText()
            successMessage = "Your exercise log was saved to SimplyStrong\\\(exportFolderName)\\\(filename).csv which can be accessed using the Files App."
        case 4:
            csvText = getExerciseLogCSVText()
            successMessage = "All data was exported to SimplyStrong\\\(exportFolderName) which can be accessed using the Files App."
        default:
            break
        }
        
       
        
        if csvText == nil {
            toastView?.titleLabel.text = "Export Failed"
            toastView?.bodyText.text = "Unable to generate CSV file"
            toastView?.showToast()
            return
        }

        
        do {
            if !FileManager.default.fileExists(atPath: exportFolder.path){
                try FileManager.default.createDirectory(at: exportFolder, withIntermediateDirectories: false, attributes: nil)
            }
            
            try csvText!.write(to: exportedCSVpath as URL, atomically: true, encoding: String.Encoding.utf8)
            
            filesDestination = exportFolder.path
            
            toastView?.titleLabel.text = "Export Successful"
            toastView?.bodyText.text = successMessage
            toastView?.showToast()
            
        } catch {
            toastView?.titleLabel.text = "Export Failed"
            toastView?.bodyText.text = "\(error)"
            toastView?.showToast()
            print(error)
        }
        
    }
    

    
    func backupToLocal() {
        
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupName = "Backup" + dayStringFromTime()
        let backupUrl = backUpFolderUrl.appendingPathComponent( backupName )
        
        let container = NSPersistentContainer(name: "Simply_Strong")
        
        do {
            try container.copyPersistentStores(to:backupUrl, overwriting: true)
            
            filesDestination = backupUrl.path
            
            toastView?.titleLabel.text = "Backup Successful"
            toastView?.bodyText.text = "All personal data was backed up to a local folder named SimplyStrong\\\(backupName) which can be accessed using the Files App."
            toastView?.showToast()
            
        } catch  {
            toastView?.titleLabel.text = "Backup Failed"
            toastView?.bodyText.text = "\(error)"
            toastView?.showToast()
        }
        
    }
    
    func backupToCloud() {
                
        let backupName = "Backup" + dayStringFromTime()
        let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        let backupUrl = driveURL!.appendingPathComponent( backupName )
        
        let container = NSPersistentContainer(name: "Simply_Strong")
        
        do {
            try container.copyPersistentStores(to:backupUrl, overwriting: true)
            
            filesDestination = backupUrl.path
            
            toastView?.titleLabel.text = "Backup Successful"
            toastView?.bodyText.text = "All personal data was backed up to an iCloud folder named SimplyStrong\\\(backupName) which can be accessed using the Files App."
            toastView?.showToast()
            
        } catch  {
            toastView?.titleLabel.text = "Backup Failed"
            toastView?.bodyText.text = "\(error)"
            toastView?.showToast()
        }
        
    }
    
    func backup(){
        
        
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
        self.pickingMode = 1
   

    }

    func restoreFromStore(){

        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        importMenu.delegate = self
   
        self.present(importMenu, animated: true, completion: nil)
        self.pickingMode = 2

    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        
        
        switch self.pickingMode {
        case 1:
            
            let backupName = "StrngBck" + dayStringFromTime()
            let backupUrl = myURL.appendingPathComponent( backupName )
            
            let container = NSPersistentContainer(name: "Simply_Strong")
            
            do {
                try container.copyPersistentStores(to:backupUrl, overwriting: true)
                
                toastView?.titleLabel.text = "Backup Successful"
                toastView?.bodyText.text = "All personal data was backed up to a folder named \(backupName) which can be accessed using the Files App."
                toastView?.showToast()
                
            } catch  {
                toastView?.titleLabel.text = "Backup Failed"
                toastView?.bodyText.text = "\(error)"
                toastView?.showToast()
            }

            
        case 2:
                let storeFolderUrl = FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask).first!
                let storeUrl = storeFolderUrl.appendingPathComponent("Simply_Strong.sqlite")
                
                guard
                    controller.documentPickerMode == .open,
                    
                    myURL.startAccessingSecurityScopedResource()
                else {
                    return
                }
                defer {
                    myURL.stopAccessingSecurityScopedResource()
                }
                
                let backupFile = myURL.appendingPathComponent("Simply_Strong.sqlite")
                
                let backupFilePath = backupFile.path
                
                if FileManager.default.fileExists(atPath: backupFilePath){
                        let container = NSPersistentContainer(name: "Simply_Strong")
                        do{
              
                            try container.persistentStoreCoordinator.replacePersistentStore(at: storeUrl,destinationOptions: nil,withPersistentStoreFrom: backupFile,sourceOptions: nil, ofType: NSSQLiteStoreType)
                          
                            guard let appDelegate =
                              UIApplication.shared.delegate as? AppDelegate else {
                                return
                            }
                            
                            appDelegate.persistentContainer  = {
                    
                                   let container = NSPersistentContainer(name: "Simply_Strong")
                                   container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                                       if let error = error as NSError? {
                               
                                           fatalError("Unresolved error \(error), \(error.userInfo)")
                                       }
                                   })
                                   return container
                            }()
                            
                            pvc?.setAllViewsNeedRefresh()
                            
                            toastView?.titleLabel.text = "Restore Successful"
                            toastView?.bodyText.text = "All personal data was restored from \(backupFilePath)."
                            toastView?.showToast()
                            
                        } catch {
                            toastView?.titleLabel.text = "Restore Failed"
                            toastView?.bodyText.text = "\(error)"
                            toastView?.showToast()
                        }
                } else {
                    toastView?.titleLabel.text = "Restore Failed"
                    toastView?.bodyText.text = "Folder must be in SimplyStrong folder (local or iCloud) and contain valid backup files"
                    toastView?.showToast()
                }
                

            break
        case 3:
            importFoodTableCSV(csvPath: myURL.path)
            break
        case 4:
            importExerciseTableCSV(csvPath: myURL.path)
            break
        default:
            break
        }

    }

    func importExerciseTableCSV(csvPath: String) {
        
        activityIndicator.startAnimating()
        
        do {
            let csvImportManager = CSVImportManager()
            let result = try csvImportManager.importExerciseTableFromCSV(csvPath: csvPath)
            
            activityIndicator.stopAnimating()
            
            toastView?.titleLabel.text = "Import Success"
            toastView?.bodyText.text = "Added \(result[0]) row(s) to Saved Exercise Table. Skipped \(result[1]) duplicated row(s)."
            toastView?.showToast()
            
            
        } catch CSVImportError.fileReadError {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "File Read Error for file \(csvPath)"
            toastView?.showToast()
            
        } catch CSVImportError.internalFault {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "Internal fault encountered. Please try again and contact support if problem is not resolved."
            toastView?.showToast()
            
        } catch CSVImportError.incorrectCSVFormat {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "CSV file is incorrectly formatted, please use the Simply Strong Food Table export format"
            toastView?.showToast()
            
        } catch {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "Unknown error. Please try again and contact support if problem is not resolved."
            toastView?.showToast()
            
        }
        
    }
    
    func importFoodTableCSV(csvPath: String) {
        
        activityIndicator.startAnimating()
        
        do {
            let csvImportManager = CSVImportManager()
            let result = try csvImportManager.importFoodTableFromCSV(csvPath: csvPath)
            
            activityIndicator.stopAnimating()
            
            toastView?.titleLabel.text = "Import Success"
            toastView?.bodyText.text = "Added \(result[0]) row(s) to Saved Food Table. Skipped \(result[1]) duplicated row(s)."
            toastView?.showToast()
            
            
        } catch CSVImportError.fileReadError {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "File Read Error for file \(csvPath)"
            toastView?.showToast()
            
        } catch CSVImportError.internalFault {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "Internal fault encountered. Please try again and contact support if problem is not resolved."
            toastView?.showToast()
            
        } catch CSVImportError.incorrectCSVFormat {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "CSV file is incorrectly formatted, please use the Simply Strong Food Table export format"
            toastView?.showToast()
            
        } catch {
            
            activityIndicator.stopAnimating()
            toastView?.titleLabel.text = "Import Failed"
            toastView?.bodyText.text = "Unknown error. Please try again and contact support if problem is not resolved."
            toastView?.showToast()
            
        }
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        //dismiss(animated: true, completion: nil)
    }
    
    func dayStringFromTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "ddMMMYYYY"
        return dateFormatter.string(from: Date())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            homevc?.setupAllViews()
        }
    }
    
    func getSavedFoodsCSVText() -> String? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Foods" )
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
         do {
             
            let foods = try managedContext.fetch(fetchRequest)
             
            var csvText = "Food Name,Calories,Date Created\n"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE MMM d yyyy HH:mm:ss a"
            
            for food in foods {
                
                let name = food.value(forKey: "name") as! String
                
                let nameStripped = name.replacingOccurrences(of: ",", with: "")
                
                let calories  = String(format: "%d", food.value(forKey: "calories") as! Int)
                let created = formatter.string(from: food.value(forKey: "created") as! Date)
                
                let newLine = "\(nameStripped),\(calories),\(created)\n"
                csvText.append(newLine)
                
            }
            
            return csvText
          
             
         } catch let error as NSError {
             print("Could not fetch. \(error), \(error.userInfo)")
            return nil
         }
        
    }
    
    func getExerciseTableCSVText() -> String? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Exercises" )
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            
           let exercises = try managedContext.fetch(fetchRequest)
            
           var csvText = "Exercise Name,Date Created\n"
           
           let formatter = DateFormatter()
           formatter.dateFormat = "EEEE MMM d yyyy HH:mm:ss a"
           
           for exercise in exercises {
               
                let name = exercise.value(forKey: "name") as! String
               
                let nameStripped = name.replacingOccurrences(of: ",", with: "")
               
                let created = (exercise.value(forKey: "created") as? Date) ?? Date()
                let createdString = formatter.string(from: created)
               
                let newLine = "\(nameStripped),\(createdString)\n"
                csvText.append(newLine)
               
           }
           
           return csvText
         
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
           return nil
        }
        
    }
    
    func getFoodLogCSVText() -> String? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodsConsumed" )
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            
           let foodsEaten = try managedContext.fetch(fetchRequest)
            
           var csvText = "Food Eaten,Calories,Date Eaten\n"
           
           let formatter = DateFormatter()
           formatter.dateFormat = "EEEE MMM d yyyy HH:mm:ss a"
           
           for foodEaten in foodsEaten {
               
                let food = foodEaten.value(forKeyPath: "ofFood") as? NSManagedObject
                let foodName = food?.value(forKey: "name") as! String
               
               let nameStripped = foodName.replacingOccurrences(of: ",", with: "")
               
               let calories  = String(format: "%d", food?.value(forKey: "calories") as! Int)
               let created = formatter.string(from: foodEaten.value(forKey: "created") as! Date)
               
               let newLine = "\(nameStripped),\(calories),\(created)\n"
               csvText.append(newLine)
               
           }
           
           return csvText
         
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
           return nil
        }
        
    }
    
    func getExerciseLogCSVText() -> String? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
                       
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sets" )
        let sort = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            
            let exercisesDone = try managedContext.fetch(fetchRequest)
            
            var csvText = "Exercise Name,Reps Completed,Date Completed\n"
           
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE MMM d yyyy HH:mm:ss a"
           
            var exerciseLookup : [String:Int] = [:]
            
            for exerciseDone in exercisesDone {
               
                let exercise = exerciseDone.value(forKeyPath: "ofExercise") as? NSManagedObject
                let exerciseName = exercise?.value(forKey: "name") as! String
               
                let nameStripped = exerciseName.replacingOccurrences(of: ",", with: "")
               
                let reps = exerciseDone.value(forKey: "noReps") as! Int
                let repsString  = String(format: "%d", reps)
                let created = formatter.string(from: exerciseDone.value(forKey: "created") as! Date)
               
                let newLine = "\(nameStripped),\(repsString),\(created)\n"
                csvText.append(newLine)
                
                if exerciseLookup[exerciseName] != nil {
                    let totalReps = exerciseLookup[exerciseName]
                    exerciseLookup[exerciseName] = totalReps! + reps
                } else {
                    exerciseLookup[exerciseName] = reps
                }
               
           }
            
            for (key, reps) in exerciseLookup {
                let newLine = "\(key),\(reps),Total \n"
                csvText.append(newLine)
            }
           
           return csvText
         
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
           return nil
        }
        
    }

    func purchaseProVersion() {
        
        if products.count > 0 {
            
            let product = products[0]
            SimplyStrongProducts.store.buyProduct(product)
            activityIndicator.startAnimating()
            
        } else {
            toastView?.titleLabel.text = "Purchase Failed"
            toastView?.bodyText.text = "Unable to retrieve products from App Store. Please contact support."
            toastView?.showToast()
        }
        
    }
    
    func restoreProVersion() {
        SimplyStrongProducts.store.restorePurchases()
        activityIndicator.startAnimating()
    }
    
    //======================================
    //===  toast view delegate methods =====
    //======================================
    
    func toastTouched() {
        
        if filesDestination != nil {
            let filesURL = URL(string: "shareddocuments://\(filesDestination!)")!
            if UIApplication.shared.canOpenURL(filesURL) {
                UIApplication.shared.open(filesURL, options: [:]) { success in
                    print(success)
                }
            }
        }
        
    }
}
