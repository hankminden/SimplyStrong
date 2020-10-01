//
//  MainPageViewController.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/27/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController {

    lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "logFoodVC"),
            self.getViewController(withIdentifier: "homeVC"),
            self.getViewController(withIdentifier: "addSetVC")
        ]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        
        switch identifier {
        case "logFoodVC":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! LogFoodViewController
            vc.pvc = self
            return vc
        case "homeVC":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! HomeViewController
            vc.pvc = self
            return vc
        case "addSetVC":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! AddSetViewController
            vc.pvc = self
            return vc
        default:
            return UIViewController()
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        delegate   = self
        dataSource = self
        
        
        
        let firstVC = pages[1]
        setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        
        

   

        if let myView = view?.subviews.first as? UIScrollView {
            myView.canCancelContentTouches = false
        }
   
    }
    
    func setAllViewsNeedRefresh() {
        
        let logFoodVC = pages[0] as! LogFoodViewController
        let addSetVC = pages[2] as! AddSetViewController
        
        logFoodVC.needsRefresh = true
        addSetVC.needsRefresh = true
    }
    


}

extension MainPageViewController: UIPageViewControllerDataSource {
 
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        //guard previousIndex >= 0          else { return pages.last }
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        //guard nextIndex < pages.count else { return pages.first }
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    
}

extension MainPageViewController: UIPageViewControllerDelegate { }

