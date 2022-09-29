//
//  ZoomBlur.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/26.
//

import CoreMedia

public class ZoomBlur: BasicOperation {
    public var blurSize: Float = 1.0 {
        didSet {
            uniformSettings["size"] = blurSize
        }
    }
    
    public var blurCenter: Position2D = Position2D.center {
        didSet {
            uniformSettings["center"] = blurCenter
        }
    }

    public init() {
        super.init(fragmentFunctionName: "zoomBlurFragment", numberOfInputs: 1)
        shouldInputSourceTexture = true
        
        {
            blurSize = 1.0
            blurCenter = Position2D.center
        }()
        
    }
    
    public override func updateAnimationValues(at time: CMTime) {
        if let blurSize = KeyframeAnimation.value(for: "blurSize", at: time, animations: animations) {
            self.blurSize = blurSize
        }
    }
}
