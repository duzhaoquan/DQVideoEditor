//
//  KeyframeAnimation.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import UIKit
import CoreMedia
 
public struct KeyframeAnimation {
    var keyPath: String
    var values: [Float]
    var keyTimes: [CMTime]
    var timingFuntions: [TimingFunction]
    
    init(keyPath: String,values: [Float],keyTimes: [CMTime],timingFunction: [TimingFunction]){
        self.keyPath = keyPath
        self.values = values
        self.keyTimes = keyTimes
        self.timingFuntions = timingFunction
    }
    
    func value(at time:CMTime) -> Float?{
        let timeValue = time.seconds
        for i in 0..<keyTimes.count - 1 {
            let start = keyTimes[i].seconds
            let end = keyTimes[i + 1].seconds
            if i == 0 && timeValue < start {
                return values[0]
            }
            if i == keyTimes.count - 2 && timeValue > end {
                return values[i+1]
            }
            if timeValue >= start && timeValue <= end {
                let progress = Float(timeValue - start) / Float(end - start)
                let normalizedValue = timingFuntions[i].value(at: progress)
                let fromValue = values[i]
                let toValue = values[i + 1]
                
                let value = fromValue + normalizedValue * (toValue - fromValue)
                return value
            }
        }
        return nil
    }
    
    static func value(for keyPath: String,at time: CMTime,animations: [KeyframeAnimation]?) -> Float?{
        guard let animations = animations else {
            return nil
        }
        
        if let animation = animations.first(where: { $0.keyPath == keyPath}) {
            return animation.value(at: time)
        }
        
        return nil
    }

}
public protocol Animatable {
    var animations: [KeyframeAnimation]? { get set }
    mutating func updateAnimationValues(at time: CMTime)
}
