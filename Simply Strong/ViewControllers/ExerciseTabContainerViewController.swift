//
//  ExerciseTabContainerViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/21/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class ExerciseTabContainerViewController: UIViewController {

    var doShowModal : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        /*if(doShowModal){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addSetVC = storyboard.instantiateViewController(withIdentifier: "addSetVC") as! AddSetViewController
            addSetVC.mainVC = self
            addSetVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
            self.present(addSetVC, animated: true) {
                   
            }
        }*/

        
    }
    
    func goBackHome() -> Void {
    
        self.tabBarController!.selectedIndex = 1
        doShowModal = true
    }
    

   

}
