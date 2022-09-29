//
//  TextureCache.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import UIKit

class TextureCache {

    var textureCache = [String:[Texture]]()
    
    //read
    public func requestTexture(pixelFormat: MTLPixelFormat = .bgra8Unorm,width: Int, height: Int) -> Texture?{
        let hash = hashForTexture(pixelFormat: pixelFormat, width: width, height: height)
        let texture: Texture?
        if let textureCount = textureCache[hash]?.count, textureCount > 0{
            texture = textureCache[hash]?.removeLast()
        }else{
            texture = Texture.makeTexture(pixelFormat: pixelFormat, width: width, height: height)
        }
        return texture
    }
    
    //cache
    public func returnToCache(_  texture: Texture){
        let hash = hashForTexture(pixelFormat: texture.texture.pixelFormat, width: texture.width, height: texture.height)
        if textureCache[hash] != nil {
            textureCache[hash]?.append(texture)
        }else{
            textureCache[hash] = [texture]
        }
        
    }
    //delete all
    public func purgeAllTextures(){
        textureCache.removeAll()
    }
    
    public func hashForTexture(pixelFormat: MTLPixelFormat, width: Int, height: Int) -> String{
        return "\(width)x\(height)-\(pixelFormat)"
    }
}
