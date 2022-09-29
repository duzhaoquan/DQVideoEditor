//
//  ImageSource.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/14.
//

import AVFoundation
import UIKit

public class ImageSource: Source {
    private var cgImage:CGImage?
    var texture: Texture?
    public init(cgImage:CGImage?) {
        self.cgImage = cgImage
        duration = CMTime(seconds: 3, preferredTimescale: 600)
        selectedTimeRange = CMTimeRange(start: .zero, duration: duration)
    }
    
    public var selectedTimeRange: CMTimeRange
    
    public var duration: CMTime
    
    public var isloaded: Bool = false
    
    public func load(completion: @escaping (NSError?) -> Void) {
        guard let cgImage = cgImage else {
            let error = NSError(domain: "com.source.load",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Image is nil", comment: "")])
            completion(error)
            isloaded = true
            return
        }
        Texture.makeTexture(cgImage: cgImage) {[weak self] texture in
            guard let self = self else{
                return
            }
            self.texture = texture
            self.isloaded = true
            completion(nil)
        }

    }
    
    public func tracks(for type: AVMediaType) -> [AVAssetTrack] {
        return []
    }
    
    public func texture(at time: CMTime) -> Texture? {
        if isloaded {
            return self.texture
        }
        defer {
            isloaded = true
        }
        guard let cgImage = cgImage else {
            return nil
        }
        
        return Texture.makeTexture(cgImage: cgImage)
    }
}
