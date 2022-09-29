//
//  AVAssetSource.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/14.
//

import AVFoundation

class AVAssetSource: Source {
    
    private var asset: AVAsset?
    init(asset:AVAsset) {
        self.asset = asset
        selectedTimeRange = .zero
        duration = .zero
    }
    
    
    var selectedTimeRange: CMTimeRange
    
    var duration: CMTime
    
    var isloaded: Bool = false
    
    func load(completion: @escaping (NSError?) -> Void) {
        guard let asset = asset else {
            let error = NSError(domain: "com.source.load", code: 0, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Asset is nil", comment: "")])
            completion(error)
            return
        }

        var error: NSError?
        asset.loadValuesAsynchronously(forKeys: ["tracks","duration"]) {[weak self] in
            guard let self = self else {
                return
            }
            if asset.statusOfValue(forKey: "tracks", error: &error) != .loaded{
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            if asset.statusOfValue(forKey: "duration", error: &error) != .loaded{
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            if let videoTrack = self.tracks(for: .video).first{
                self.duration = videoTrack.timeRange.duration
            }else{
                self.duration = asset.duration
            }
            self.selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: self.duration)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func tracks(for type: AVMediaType) -> [AVAssetTrack] {
        guard let asset = asset else {
            return []
        }
        return asset.tracks(withMediaType: type)
    }
    

}
