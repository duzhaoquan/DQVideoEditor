//
//  BlendOpration.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/27.
//

import Foundation
import simd


public class BlendOperation: BasicOperation {
    public var modelView: float4x4 = float4x4.identity() {
        didSet {
            uniformSettings["modelView"] = modelView
        }
    }
    
    public var projection: float4x4 = float4x4.identity() {
        didSet {
            uniformSettings["projection"] = projection
        }
    }
    
    public var blendMode: BlendMode = BlendModeNormal {
        didSet {
            uniformSettings["blendMode"] = blendMode
        }
    }
    
    public var blendOpacity: Float = 1.0 {
        didSet {
            uniformSettings["blendOpacity"] = blendOpacity
        }
    }
    
    public init() {
        super.init(vertexFunctionName: "blendOperationVertex", fragmentFunctionName: "blendOperationFragment", numberOfInputs: 1)
        
        ({
            blendMode = BlendModeNormal
            blendOpacity = 1.0
        })()
    }
}
