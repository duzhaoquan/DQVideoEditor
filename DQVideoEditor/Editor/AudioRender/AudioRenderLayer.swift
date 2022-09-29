//
//  AudioRenderLayer.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/22.
//

import AVFoundation

class AudioRenderLayer {
    let renderLayer: RenderLayer
    var superLayer: AudioRenderLayer?
    var trackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    var timeRangeInTimeline: CMTimeRange
    var pitchAlgorithm: AVAudioTimePitchAlgorithm? {
        return renderLayer.audioConfiguration.pitchAlgorithm
    }
    init(renderLayer: RenderLayer) {
        self.renderLayer = renderLayer
        timeRangeInTimeline = renderLayer.timeRange
    }
    
    func addAudioTrack(to composition: AVMutableComposition,preferredTrackID:CMPersistentTrackID){
        guard let source = renderLayer.source else{
            return
        }
        guard let assetTack = source.tracks(for: .audio).first else {
            return
        }
        let compositionTrack: AVMutableCompositionTrack? = {
            if let compositionTrack = composition.track(withTrackID: preferredTrackID) {
                return compositionTrack
            }else{
                return composition.addMutableTrack(withMediaType: .audio, preferredTrackID: preferredTrackID)
            }
        }()
        if let compositionTrack = compositionTrack{
            do {
                try compositionTrack.insertTimeRange(source.selectedTimeRange, of: assetTack, at: timeRangeInTimeline.start)
            } catch  {
                
            }
        }
    }
    
}


extension RenderLayer {
    @objc func canBeConvertedToAudioRenderLayer() -> Bool {
        return source?.tracks(for: .audio).first != nil
    }
}
