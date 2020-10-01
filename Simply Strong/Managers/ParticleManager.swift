//
//  ParticleManager.swift
//  Simply Strong
//
//  Created by Henry Minden on 9/22/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit
import QuartzCore

class ParticleManager: NSObject {
    
    
    func createParticleEmitterOfType ( ptype: Int ) -> CAEmitterLayer {
        
        let emitterLayer = CAEmitterLayer()
        
        switch ptype {
        case 0:
            
            emitterLayer.emitterZPosition = 1; // 3
            emitterLayer.emitterShape = CAEmitterLayerEmitterShape.point;
            emitterLayer.renderMode = CAEmitterLayerRenderMode.additive;
             
            let emitterCell = CAEmitterCell()
            emitterCell.contents = UIImage.init(named: "bicep")?.cgImage
        
            emitterCell.scale = 0.8
            emitterCell.scaleRange = 0.2
            emitterCell.alphaSpeed = -1/1.8;
            emitterCell.emissionRange = CGFloat.pi / 4
            emitterCell.emissionLongitude = -CGFloat.pi / 2
            emitterCell.spin = 0.8
            emitterCell.spinRange = 5.6
            emitterCell.lifetime = 5.8
            emitterCell.birthRate = 4
            emitterCell.velocity = 48
            emitterCell.velocityRange = 8
            emitterCell.yAcceleration = 8
        
            emitterLayer.emitterCells = [emitterCell]
            
        case 1:
                
            emitterLayer.emitterZPosition = 1; // 3
            emitterLayer.emitterShape = CAEmitterLayerEmitterShape.point;
            emitterLayer.renderMode = CAEmitterLayerRenderMode.backToFront;
                 
            let emitterCell = CAEmitterCell()
            emitterCell.contents = UIImage.init(named: "leafyGreens")?.cgImage
            
            emitterCell.scale = 0.8
            emitterCell.scaleRange = 0.2
            emitterCell.alphaSpeed = -1/1.8;
            emitterCell.emissionRange = CGFloat.pi / 4
            emitterCell.emissionLongitude = -CGFloat.pi / 2
            emitterCell.spin = 0.8
            emitterCell.spinRange = 5.6
            emitterCell.lifetime = 5.8
            emitterCell.birthRate = 4
            emitterCell.velocity = 48
            emitterCell.velocityRange = 8
            emitterCell.yAcceleration = 8
            
            emitterLayer.emitterCells = [emitterCell]
        
        default:
            break
        }
        
        return emitterLayer
    }

}
