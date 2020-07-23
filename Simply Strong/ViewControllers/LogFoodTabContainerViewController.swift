//
//  LogFoodTabContainerViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/21/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class LogFoodTabContainerViewController: UIViewController {

    var doShowModal : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if(doShowModal){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logFoodVC = storyboard.instantiateViewController(withIdentifier: "logFoodVC") as! LogFoodViewController
            logFoodVC.mainVC = self
            logFoodVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
            self.present(logFoodVC, animated: true) {
                   
            }
        }

        
    }
    
    func goBackHome() -> Void {
    
        self.tabBarController!.selectedIndex = 1
        doShowModal = true
    }

 

}
