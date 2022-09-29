//
//  VideoRenderLayer.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/19.
//

import UIKit
import CoreMedia
import AVFoundation

class VideoRenderLayer {
    var renderLayer: RenderLayer
    var trackId:CMPersistentTrackID = kCMPersistentTrackID_Invalid
    var timeRangeInTimeline:CMTimeRange
    var preferredTransform: CGAffineTransform = .identity
    
    init(renderLayer:RenderLayer){
        self.renderLayer = renderLayer
        self.timeRangeInTimeline = renderLayer.timeRange
    }
    

    func addVideoTrack(to compostion: AVMutableComposition, preferedTrackID: CMPersistentTrackID){
        guard let source = renderLayer.source else {
            return
        }
        guard let assetTrack = source.tracks(for: .video).first else {
            return
        }
        trackId = preferedTrackID
        preferredTransform = assetTrack.preferredTransform
        let compositionTrack: AVMutableCompositionTrack? = {
            if let com = compostion.track(withTrackID: preferedTrackID){
                return com
            }else{
                return compostion.addMutableTrack(withMediaType: .video, preferredTrackID: preferedTrackID)
            }
        }()
        if let compositionTrack = compositionTrack{
            do {
                print("------------------------------------")
                try compositionTrack.insertTimeRange(source.selectedTimeRange, of: assetTrack, at: timeRangeInTimeline.start)
            } catch  {
                print(" add video track failed!")
            }
        }
    }
    
    class func addBlankVideoTrack(to composition: AVMutableComposition, in timeRange: CMTimeRange, preferredTrackID: CMPersistentTrackID) {
        guard let assetTrack = blankVideoAsset?.tracks(withMediaType: .video).first else {
            return
        }

        let compositionTrack: AVMutableCompositionTrack? = {
            if let compositionTrack = composition.track(withTrackID: preferredTrackID) {
                return compositionTrack
            }
            return composition.addMutableTrack(withMediaType: .video, preferredTrackID: preferredTrackID)
        }()
        
        var insertTimeRange = assetTrack.timeRange
        if insertTimeRange.duration > timeRange.duration {
            insertTimeRange.duration = timeRange.duration
        }
        
        if let compositionTrack = compositionTrack {
            do {
                try compositionTrack.insertTimeRange(insertTimeRange, of:assetTrack , at: timeRange.start)
                compositionTrack.scaleTimeRange(CMTimeRange(start: timeRange.start, duration: insertTimeRange.duration), toDuration: timeRange.duration)
            } catch {
                
            }
        }
    }
    
    private static let blankVideoAsset:AVAsset? = {
        if let url = Bundle.main.url(forResource: "black_empty", withExtension: "mov"){
            return AVAsset(url: url)
        }
        return nil
    }()
    
}
extension RenderLayer{
    @objc func canBeConvertedToVideoRenderLayer() -> Bool{
        if source?.tracks(for: .video).first != nil{
            return true
        }
        if source is ImageSource {
            return true
        }
//            if oprations.count > 0{
//                return true
//            }
        return false
    }
}
