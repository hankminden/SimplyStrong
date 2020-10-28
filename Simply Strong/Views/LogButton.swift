//
//  LogButton.swift
//  Simply Strong
//
//  Created by Henry Minden on 9/22/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class LogButton: UIButton {

    
    var particleLayer : CAEmitterLayer?
   
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        
        
    }
    
    func initParticleLayer(ptype : Int) {
       
        particleLayer = ParticleManager().createParticleEmitterOfType(ptype: ptype)
        particleLayer!.birthRate = 0.0
        self.layer.addSublayer(particleLayer!)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        if self.isEnabled {
            for touch in touches {
                
                let point = touch.location(in: self)
                
                particleLayer!.emitterPosition = point
                particleLayer!.birthRate = 1.0
                
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesMoved(touches, with: event)
        
        if self.isEnabled {
            for touch in touches {
                    
                let point = touch.location(in: self)
            
                particleLayer!.emitterPosition = point
                  
            }
        }
        

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        let timer2 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
            if self.particleLayer != nil {
                self.particleLayer!.birthRate = 0.0
            }
        }
        

        
        
    }

}
