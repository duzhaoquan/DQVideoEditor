//
//  BasicOperation.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/26.
//

import CoreMedia
import Metal

public func defaultVertexFunctionNameForInputs(_ inputCount:UInt) -> String {
    switch inputCount {
    case 0:
        return "passthroughVertex"
    case 1:
        return "oneInputVertex"
    case 2:
        return "twoInputVertex"
    default:
        return "passthroughVertex"
    }
}

//Half是用16位表示浮点数的一种数据类型
open class BasicOperation: Animatable {
    public let maximumInputs: UInt
    public var uniformSettings: ShaderUniformSettings
    public var enableOutputTextureRead = true
    public var shouldInputSourceTexture = false
    public var timeRange: CMTimeRange?
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String
    var inputTextures = [UInt: Texture]()
    let textureInputSemaphore = DispatchSemaphore(value:1)
    
    public init(vertexFunctionName: String? = nil, fragmentFunctionName: String, numberOfInputs: UInt = 1, operationName: String = #file) {
        self.maximumInputs = numberOfInputs
        self.operationName = operationName
        
        let concreteVertexFunctionName = vertexFunctionName ?? defaultVertexFunctionNameForInputs(numberOfInputs)
        //创建渲染管道，获取着色器函数对应的参数配置
        let (pipelineState, vertexUniforms, fragmentUniforms) = generateRenderPipelineState(vertexFunctionName:concreteVertexFunctionName,
                                                                       fragmentFunctionName:fragmentFunctionName,
                                                                                            oprationName:operationName)
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(vertexUnifroms: vertexUniforms, fragmentUniforms: fragmentUniforms)
    }
    
    public func addTexture(_ texture: Texture, at index: UInt) {
        inputTextures[index] = texture
    }
    
    public func renderTexture(_ outputTexture: Texture) {
        let _ = textureInputSemaphore.wait(timeout:DispatchTime.distantFuture)
        defer {
            textureInputSemaphore.signal()
        }
        
        if inputTextures.count >= maximumInputs {
            guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {
                return
            }
            
            commandBuffer.renderQuad(pipelineState: renderPipelineState,
                                     uniformSetting: uniformSettings,
                                     inputTexture: inputTextures,
                                     outputTeture: outputTexture,
                                     enableOutputTextureRead: enableOutputTextureRead)
            commandBuffer.commit()
        }
    }
    
    // MARK: - Animatable
    public var animations: [KeyframeAnimation]?
    public func updateAnimationValues(at time: CMTime) {}
}

