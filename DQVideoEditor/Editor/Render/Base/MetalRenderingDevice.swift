//
//  MetalRenderingDevice.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/14.
//

import Metal

public let sharedMetalRenderingDevice = MetalRenderingDevice()
public class MetalRenderingDevice {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let shaderLibrary: MTLLibrary
    lazy var textureCache: TextureCache = {
        return TextureCache()
    }()
    init(){
        guard let device = MTLCreateSystemDefaultDevice() else{
            fatalError("Could not create Metal Device")
        }
        self.device = device
        guard let queue = self.device.makeCommandQueue() else{
            fatalError("Could not create command queue")
        }
        self.commandQueue = queue
        
//        let frameworkBundle = Bundle.main
//        guard let metalLibraryPath = frameworkBundle.path(forResource: "default", ofType: "metallib")else{
//            fatalError("Could not load library")
//        }
        do {
            self.shaderLibrary = try device.makeDefaultLibrary(bundle: Bundle.main)
        } catch  {
            fatalError("Could not load library")
        }
    }
}
