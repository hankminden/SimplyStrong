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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIDocumentPickerDelegate,UINavigationControllerDelegate {

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
    
    var pickingMode: Int = 0 // 0: none, 1: folder, 2: files
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        toastView = ToastView.init(frame: CGRect(x: self.view.frame.origin.x, y: -80, width: self.view.frame.size.width, height: 80))
        self.view.addSubview(toastView!)
        
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
            cell.settingLabel.text = "Back up data to local folder"
            cell.settingImage.image = UIImage(imageLiteralResourceName: "backUp")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
            cell.settingLabel.text = "Back up data to iCloud folder"
            cell.settingImage.image = UIImage(imageLiteralResourceName: "backUpToCloud")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
            cell.settingLabel.text = ""
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell
            cell.settingLabel.text = "Restore from backup folder"
            cell.settingImage.image = UIImage(imageLiteralResourceName: "restore")
            return cell
            

        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
        
            switch indexPath.row {
            case 0:
                backupToLocal()
                break
            case 1:
                backupToCloud()
                break
            case 2:
                break
            case 3:
                restoreFromStore()
                break
   
            default:
                break
            }
        
        default:
            break
        }
        
    }

    func backupToLocal() {
        
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupName = "Backup" + dayStringFromTime()
        let backupUrl = backUpFolderUrl.appendingPathComponent( backupName )
        
        let container = NSPersistentContainer(name: "Simply_Strong")
        
        do {
            try container.copyPersistentStores(to:backupUrl, overwriting: true)
            
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



        //let importMenu = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        importMenu.delegate = self
        //importMenu.modalPresentationStyle = .formSheet
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
            
            //let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
            let backupName = "StrngBck" + dayStringFromTime()
            let backupUrl = myURL.appendingPathComponent( backupName )
            
            //let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
            //let backupUrl = driveURL!.appendingPathComponent( backupName )
            
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
                

            break;
        default:
            break;
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
    


}
