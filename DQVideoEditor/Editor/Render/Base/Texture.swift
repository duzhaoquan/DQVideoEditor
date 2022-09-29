//
//  Texture.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/14.
//

import AVFoundation
import Metal
import CoreVideo
import MetalKit

public class Texture {

    let texture: MTLTexture
    var width:Int{
        return texture.width
    }
    var height:Int{
        return texture.height
    }
    
    init(texture: MTLTexture) {
        self.texture = texture
    }
    
    public class func makeTexture(pixelBuffer: CVPixelBuffer,
                                  pixelFormat: MTLPixelFormat = .bgra8Unorm,
                                  width: Int? = nil,
                                  height: Int? = nil,
                                  plane: Int = 0) -> Texture? {
        guard let iosurface = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() else {
            return nil
        }

        let textureWidth: Int, textureHeight: Int
        if let width = width, let height = height {
            textureWidth = width
            textureHeight = height
        } else {
            textureWidth = CVPixelBufferGetWidth(pixelBuffer)
            textureHeight = CVPixelBufferGetHeight(pixelBuffer)
        }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: textureWidth,
                                                                  height: textureHeight,
                                                                  mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let metalTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: descriptor,
                                                                               iosurface: iosurface,
                                                                               plane: plane) else {
            return nil
        }

        let texture = Texture(texture: metalTexture)
        return texture
    }
    public class func makeTexture(pixelFormat: MTLPixelFormat = .bgra8Unorm, width:Int, height:Int) -> Texture?{
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        guard let metalTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: descriptor) else {
            return nil
        }
        return Texture(texture: metalTexture)
    }
    
    public class func makeTexture(cgImage:CGImage) -> Texture?{
        let metalTexture: MTLTexture
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        let options = [MTKTextureLoader.Option.SRGB: false,
                       MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue) ]
        do {
            metalTexture = try textureLoader.newTexture(cgImage: cgImage, options: options)
        } catch  {
            fatalError("Failed loading image texture")
        }
         
        let texture = Texture(texture: metalTexture)
        return texture
    }
    public class func makeTexture(cgImage:CGImage,completion: @escaping(Texture?)->Void){
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        let options = [MTKTextureLoader.Option.SRGB: false,
                       MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue) ]
        
        textureLoader.newTexture(cgImage: cgImage, options: options) { text, error in
            if let texture = text {
                completion(Texture(texture: texture))
            }else{
                completion(nil)
            }
        }
    }
    
    public class func clearTexture(_ texture: Texture){
        guard let commmandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else{
            return
        }
        commmandBuffer.clearTexture(texture)
        commmandBuffer.commit()
    }
    
    var textureRetainCount = 0
    
    public func lock(){
        textureRetainCount += 1
    }
    public func unlock() {
        textureRetainCount -= 1
        if textureRetainCount < 1{
            if textureRetainCount < 0{
                fatalError("failed textuer")
            }
            textureRetainCount = 0
            sharedMetalRenderingDevice.textureCache.returnToCache(self)
        }
    }
    
}
