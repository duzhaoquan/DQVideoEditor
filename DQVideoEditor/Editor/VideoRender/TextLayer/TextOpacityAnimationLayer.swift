//
//  TextOpacityAnimationLayer.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/10/11.
//

import AVFoundation

class TextOpacityAnimationLayer: TextAnimationLayer {

    override func addAnimations(to layers: [CATextLayer]) {
        var beginTime = AVCoreAnimationBeginTimeAtZero
        let durationTimeInterval = 0.125
        
        for layer in layers {
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 10
            animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
            animationGroup.fillMode = .both
            animationGroup.isRemovedOnCompletion =  false
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 0.0
            opacityAnimation.toValue = 1.0
            opacityAnimation.duration = durationTimeInterval
            opacityAnimation.beginTime = beginTime
            opacityAnimation.fillMode = .both
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 0.0
            scaleAnimation.toValue = 1.0
            scaleAnimation.duration = durationTimeInterval
            scaleAnimation.beginTime = beginTime
            scaleAnimation.fillMode = .both
            
            animationGroup.animations = [opacityAnimation, scaleAnimation]
            layer.add(animationGroup, forKey: "animationGroup")
            
            beginTime += durationTimeInterval
            
        }
    }
}
