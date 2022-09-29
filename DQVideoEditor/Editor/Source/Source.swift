//
//  Source.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/14.
//

import AVFoundation

public protocol Source {
    var selectedTimeRange: CMTimeRange { get set }
    var duration: CMTime { get set }
    var isloaded: Bool { get set }
    
    func load(completion: @escaping (NSError?)-> Void)
    func tracks(for type: AVMediaType) -> [AVAssetTrack]
    func texture(at time: CMTime) -> Texture?
    
}
extension Source {
    public func texture(at: CMTime) -> Texture?{
        return nil
    }
}
