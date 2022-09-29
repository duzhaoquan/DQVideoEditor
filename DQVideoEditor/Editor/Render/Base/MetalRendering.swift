//
//  MetalRendering.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import Foundation
import Metal

public let standardImageVertices:[Float] = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]
public let standardTextureCoordinates: [Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]

extension MTLCommandBuffer{
    
    func renderQuad(pipelineState:MTLRenderPipelineState,
                    uniformSetting:ShaderUniformSettings? = nil,
                    inputTexture: [UInt: Texture],
                    imageVertices: [Float] = standardImageVertices,
                    textureCoodinates: [Float] = standardTextureCoordinates,
                    outputTeture: Texture,
                    enableOutputTextureRead:Bool){
        //渲染过程描述符
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = outputTeture.texture
        renderPass.colorAttachments[0].clearColor = Color.mtlClearColor
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = enableOutputTextureRead ? .load : .clear
        //获取渲染命令编码器
        guard let renderEncoder = self.makeRenderCommandEncoder(descriptor: renderPass)
        else{
            fatalError("could not create render encoder")
        }
        //设置视口
        renderEncoder.setFrontFacing(.counterClockwise)
        //设置渲染管道
        renderEncoder.setRenderPipelineState(pipelineState)
        //设置顶点位置（此处设置的是标准的顶点位置，restorShaderSettings中设置具体的顶点和片元位置）
        renderEncoder.setVertexBytes(imageVertices, length: imageVertices.count * MemoryLayout<Float>.size, index: 0)
        //渲染纹理
        for textureIndex in 0..<inputTexture.count{
            renderEncoder.setVertexBytes(textureCoodinates, length: textureCoodinates.count * MemoryLayout<Float> .size, index: 1 + textureIndex)
            renderEncoder.setFragmentTexture(inputTexture[UInt(textureIndex)]!.texture, index: textureIndex)
        }
        //设置具体滤镜的参数
        uniformSetting?.restorShaderSettings(renderEncoder: renderEncoder)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)//二维图像四个顶点
        renderEncoder.endEncoding()
    }
    
    
    func clearTexture(_ outputTexture: Texture) {
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = outputTexture.texture
        renderPass.colorAttachments[1].clearColor = Color.mtlClearColor
        renderPass.colorAttachments[2].storeAction = .store
        renderPass.colorAttachments[3].loadAction = .clear
        
        guard let renderEncoder = self.makeRenderCommandEncoder(descriptor: renderPass) else{
            fatalError("Could not create render encoder")
        }
        renderEncoder.endEncoding()
    }
}

func generateRenderPipelineState(vertexFunctionName:String, fragmentFunctionName:String, oprationName:String) -> (MTLRenderPipelineState, [String: UniformInfor], [String: UniformInfor]){
    //获取顶点着色器函数
    guard let vertexFunction = sharedMetalRenderingDevice.shaderLibrary.makeFunction(name: vertexFunctionName) else{
        fatalError("\(oprationName):could not compile vertex function \(vertexFunctionName)")
    }
    //获取片元着色器函数
    guard let fragmentFuntion = sharedMetalRenderingDevice.shaderLibrary.makeFunction(name: fragmentFunctionName) else{
        fatalError("\(oprationName): could not compile fragment function \(fragmentFunctionName)")
    }
    //配置渲染管道描述符
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
    descriptor.rasterSampleCount = 1
    descriptor.vertexFunction = vertexFunction
    descriptor.fragmentFunction = fragmentFuntion
    
    do {
        //创建渲染管道
        var reflection: MTLAutoreleasedRenderPipelineReflection?
        let pipLinState = try sharedMetalRenderingDevice.device.makeRenderPipelineState(descriptor: descriptor,options: [.bufferTypeInfo, .argumentInfo],reflection: &reflection)
        //获取着色器函数 参数类型，以便之后传惨
        var vertexUniforms: [String: UniformInfor] = [:]
        var fragmentUniforms = [String : UniformInfor]()
        if #available(iOS 16.0, *) {
            if let vertexBudings = reflection?.vertexBindings as? [MTLBufferBinding]{
                for bufferBuding in vertexBudings {
                    let uniformInfor = UniformInfor(locationIndex: bufferBuding.index, dataSize: bufferBuding.bufferDataSize)
                    vertexUniforms[bufferBuding.name] = uniformInfor
                }

            }
            //片元着色器中参数 banging中有 MTLTextureBinding 和 MTLBufferBinding，需要过滤一下
            if let fragmentBudings = reflection?.fragmentBindings.compactMap({$0 as? MTLBufferBinding}) as? [MTLBufferBinding]{
                for bufferBuding in fragmentBudings {
                    let uniformInfor = UniformInfor(locationIndex: bufferBuding.index, dataSize: bufferBuding.bufferDataSize)
                    fragmentUniforms[bufferBuding.name] = uniformInfor
                }

            }
            
        } else {
            if let vertexArguments = reflection?.vertexArguments  {
                for vertexArgument in vertexArguments where vertexArgument.type == .buffer {
                    let uniformInfor = UniformInfor(locationIndex: vertexArgument.index, dataSize: vertexArgument.bufferDataSize)
                    vertexUniforms[vertexArgument.name] = uniformInfor
                }
                
            }
            
            if let fragmentArguments = reflection?.fragmentArguments {
                for fragmentArgument in fragmentArguments where fragmentArgument.type == .buffer {
                    let uniformInfor = UniformInfor(locationIndex: fragmentArgument.index, dataSize: fragmentArgument.bufferDataSize)
                    fragmentUniforms[fragmentArgument.name] = uniformInfor
                }
            }
        }
        
        return (pipLinState, vertexUniforms, fragmentUniforms)
        
    } catch  {
        fatalError("Could not create render pipeline state for vertex:\(vertexFunctionName), fragment:\(fragmentFunctionName), error:\(error)")
    }
    
}
