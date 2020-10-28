//
//  ToastView.swift
//  Simply Strong
//
//  Created by Henry Minden on 9/21/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

protocol ToastViewDelegate {
    func toastTouched() -> Void
}

class ToastView: UIView {

    var delegate : ToastViewDelegate?
    
    @IBOutlet private var contentView:UIView?
    // other outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var toastContainer: UIView!
    
    let kTOAST_HEIGHT : CGFloat = 80
    let kTOAST_TOP_OFFSET : CGFloat = 18
    
    var beginY: CGFloat = 0
    var deltaY: CGFloat = 0
    
    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ToastView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        
        toastContainer.clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        
        
        gradientLayer.frame = content.bounds
        gradientLayer.colors = [UIColor.init(red: 0/255, green: 87/255, blue: 255/255, alpha: 1).cgColor,
                                UIColor.init(red: 84/255, green: 199/255, blue: 252/255, alpha: 1).cgColor]
        toastContainer.layer.insertSublayer(gradientLayer, at: 0)
        toastContainer.layer.cornerRadius = 18
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(recognizer:)))
        pan.minimumNumberOfTouches = 1
        self.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(recognizer:)))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if self.delegate != nil {
                self.delegate!.toastTouched()
            }
        }
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer)  {
        
        let touchLocation = recognizer.location(in: self)
        
        if recognizer.state == UIGestureRecognizer.State.began {
            beginY = touchLocation.y
        }
        
        if recognizer.state == UIGestureRecognizer.State.changed {
            deltaY = touchLocation.y - beginY
            if(self.frame.origin.y + deltaY < kTOAST_TOP_OFFSET){
                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + deltaY, width: self.frame.size.width, height: self.frame.size.height)
            }
        }
        
        if recognizer.state == UIGestureRecognizer.State.ended {
            
            let newPos = self.frame.origin.y + deltaY
            
            if(newPos < (kTOAST_TOP_OFFSET - 40)){
                hideToast()
            } else {
                showToast()
            }
            beginY = 0
        }
        

        
    }
    
    func showToast () {
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 18.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            self.frame = CGRect(x: self.frame.origin.x, y: self.kTOAST_TOP_OFFSET, width: self.frame.size.width, height: self.frame.size.height)
            
        }) { (finished) in
            
        }
        
    }
    
    func hideToast () {
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 18.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            self.frame = CGRect(x: self.frame.origin.x, y: -self.kTOAST_HEIGHT, width: self.frame.size.width, height: self.frame.size.height)
            
        }) { (finished) in
            
        }
        
    }

}
