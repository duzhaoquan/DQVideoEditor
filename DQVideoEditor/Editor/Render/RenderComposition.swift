//
//  RenderComposition.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import UIKit
import CoreMedia

public class RenderComposition {

    var backgroundColor: Color = Color.black {
        didSet{
            Color.clearColor = backgroundColor
        }
    }
    
    var frameDuration:CMTime = .init(value: 1, timescale: 30)
    var renderSize: CGSize = .init(width: 720, height: 1280)
    var layers: [RenderLayer] = []
    var animationLayer:CALayer?
    
    init(){}
    
}
