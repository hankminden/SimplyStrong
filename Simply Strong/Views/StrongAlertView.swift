//
//  StrongAlertView.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/16/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

protocol StrongAlertViewDelegate {
    func buttonOneTouchedDM() -> Void
    func buttonTwoTouchedDM() -> Void
    
}

class StrongAlertView: UIView {

    @IBOutlet private var contentView: UIView?
    var delegate : StrongAlertViewDelegate?

    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertBody: UILabel!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    
    let kALERT_HEIGHT : CGFloat = 340
    let kALERT_TOP_OFFSET : CGFloat = 180
    
    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StrongAlertView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        
        contentView?.clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView!.bounds
        gradientLayer.colors = [UIColor.init(red: 0/255, green: 87/255, blue: 255/255, alpha: 1).cgColor,
                                UIColor.init(red: 84/255, green: 199/255, blue: 252/255, alpha: 1).cgColor]
        contentView!.layer.insertSublayer(gradientLayer, at: 0)
        contentView!.layer.cornerRadius = 18
        
        buttonOne?.clipsToBounds = true
        buttonOne!.layer.cornerRadius = 10
        buttonTwo?.clipsToBounds = true
        buttonTwo!.layer.cornerRadius = 10
        
    }
    
    func showStrongAlert () {
        
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 8.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            self.frame = CGRect(x: self.frame.origin.x, y: self.kALERT_TOP_OFFSET, width: self.frame.size.width, height: self.frame.size.height)
            
        }) { (finished) in
            
        }
        
    }
    
    func hideStrongAlert () {
        
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 8.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            self.frame = CGRect(x: self.frame.origin.x, y: -self.kALERT_HEIGHT, width: self.frame.size.width, height: self.frame.size.height)
            
        }) { (finished) in
            
        }
        
    }
    
    @IBAction func buttonOneTouched(_ sender: Any) {
        
        if(delegate != nil){
            delegate?.buttonOneTouchedDM()
        }
        
    }
    
    @IBAction func buttonTwoTouched(_ sender: Any) {
        
        if(delegate != nil){
            delegate?.buttonTwoTouchedDM()
        }
        
    }
    
}
