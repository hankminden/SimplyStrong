//
//  HomeViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/27/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBOutlet var logFoodButton: UIButton!
    @IBOutlet var logSetButton: UIButton!
    weak var pvc : MainPageViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    

    @IBAction func logFoodTouched(_ sender: Any) {
        
        let firstVC = pvc!.pages[0]
        pvc!.setViewControllers([firstVC], direction: .reverse, animated: true, completion: nil)
        
    }
    
    @IBAction func logSetTouched(_ sender: Any) {
        
        let firstVC = pvc!.pages[2]
        pvc!.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        
    }
    
}
