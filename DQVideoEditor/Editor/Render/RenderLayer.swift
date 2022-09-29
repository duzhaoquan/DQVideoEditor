//
//  RenderLayer.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import AVFoundation

public class RenderLayer: Animatable {
    var timeRange: CMTimeRange
    var layerLevel: Int = 0
    var source: Source?
    var blendOpacity:Float = 1.0
    var transform: Transform = .identity
    public var blendMode: BlendMode = BlendModeNormal
    var audioConfiguration: AudioConfiguration = .init()
    public var operations: [BasicOperation] = []
    
    public init(timeRange: CMTimeRange,source:Source? = nil){
        self.timeRange = timeRange
        self.source = source
    }
    

    public var animations: [KeyframeAnimation]?
    
    public func updateAnimationValues(at time: CMTime) {
        if let blendOpacity = KeyframeAnimation.value(for: "blendOpacity", at: time, animations: animations) {
            self.blendOpacity = blendOpacity
        }
        transform.updateAnimationValues(at: time)
        for operation in operations {
            let operationStartTime = operation.timeRange?.start ?? CMTime.zero
            let operationInternalTime = time - operationStartTime
            operation.updateAnimationValues(at: operationInternalTime)
        }
            
    }
    

}

public class RenderLayerGroup: RenderLayer{
    var layers:[RenderLayer] = []
}
