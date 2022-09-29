//
//  DQVideoEditor.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import UIKit
import AVFoundation

public class DQVideoEditor {
    var renderComposition: RenderComposition
    
    private var videoRenderLayers: [VideoRenderLayer] = []
    private var audioRenderLayersInTimeline: [AudioRenderLayer] = []
    private var composition: AVComposition?
    private var videoComposition: AVMutableVideoComposition?
    private var audioMix: AVAudioMix?
    
    init(renderComposition: RenderComposition){
        self.renderComposition = renderComposition
    }

    func makePlayerItem() -> AVPlayerItem {
        let composition = makeComposition()
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.videoComposition = makeVideoComposition()
//        playerItem.audioMix = makeAudioMix()
        
        return playerItem
    }
    
    func makeComposition() -> AVComposition{
        let composition = AVMutableComposition()
        self.composition = composition
        
        
        var increaseMentTrackID:CMPersistentTrackID = 0
        func increaseTrackID() -> CMPersistentTrackID{
            let trackID = increaseMentTrackID + 1
            increaseMentTrackID = trackID
            return trackID
        }
        // Step 1: Add video tracks
        
        // Substep 1: Generate videoRenderLayers sorted by start time.
        // A videoRenderLayer can contain video tracks or the source of the layer is ImageSource.
        videoRenderLayers = renderComposition.layers.filter {
            $0.canBeConvertedToVideoRenderLayer()
        }.sorted(by: {
            $0.timeRange.start < $1.timeRange.start
        }).compactMap({
            VideoRenderLayer.makeVideoRenderLayer(renderLayer: $0)
        })
        
        // Generate video track ID. This inline method is used in substep 2.
        // You can reuse the track ID if there is no intersection with some of the previous, otherwise increase an ID.
        var videoRrackIDInfo: [CMPersistentTrackID: CMTimeRange] = [:]
        func videoTrackID(for layer: VideoRenderLayer) ->CMPersistentTrackID{
        
            for (trackID,timeRange) in videoRrackIDInfo {
                if layer.timeRangeInTimeline.start > timeRange.end{
                    videoRrackIDInfo[trackID] = layer.timeRangeInTimeline
                    return trackID
                }
            }
            let trackID = increaseTrackID()
            videoRrackIDInfo[trackID] = layer.timeRangeInTimeline
            return trackID
        }
        
        // Substep 2: Add all VideoRenderLayer tracks from the timeline to the composition.
        // Calculate minimum start time and maximum end time for substep 3.
        var videoRenderLayersInTimeLine:[VideoRenderLayer] = []
        
        videoRenderLayers.forEach {
            if let group = $0 as? VideoRenderLayerGroup{
                videoRenderLayersInTimeLine.append(contentsOf: group.recuriveVideoRenderLayers())
            }else{
                videoRenderLayersInTimeLine.append($0)
            }
            
        }
        let minmumStratTime = videoRenderLayersInTimeLine.first?.timeRangeInTimeline.start
        var maximumEndTime = videoRenderLayersInTimeLine.first?.timeRangeInTimeline.end
        videoRenderLayersInTimeLine.forEach {
            if $0.renderLayer.source?.tracks(for: .video).first != nil {
                let trackId = videoTrackID(for: $0)
                $0.addVideoTrack(to: composition, preferedTrackID: trackId)
            }
            if maximumEndTime! < $0.timeRangeInTimeline.end {
                maximumEndTime = $0.timeRangeInTimeline.end
            }
        }
        
        // Substep 3: Add a blank video track for image or effect layers.
        // The track's duration is the same as timeline's duration.
        if let minmumStartTime = minmumStratTime,let maximumEndTime = maximumEndTime {
            let timeRange = CMTimeRange(start: minmumStartTime, end: maximumEndTime)
            VideoRenderLayer.addBlankVideoTrack(to: composition, in: timeRange, preferredTrackID: increaseMentTrackID)
        }
        
        // Step 2: Add audio tracks
        
        // Substep 1: Generate audioRenderLayers sorted by start time.
        // A audioRenderLayer must contain audio tracks.
        let audioRenderLayers = renderComposition.layers.filter {
            $0.canBeConvertedToAudioRenderLayer()
        }.sorted {
            CMTimeCompare($0.timeRange.start, $1.timeRange.start) < 0
        }.compactMap {
            AudioRenderLayer.makeAudioRenderLayer(renderLayer:$0)
        }
        // Substep 2: Add tracks from the timeline to the composition.
        // Since AVAudioMixInputParameters only corresponds to one track ID, the audio track ID is not reused. One audio layer corresponds to one track ID.
        audioRenderLayersInTimeline = []
        audioRenderLayers.forEach {
            if let group = $0 as? AudioRenderLayerGroup {
                audioRenderLayersInTimeline.append(contentsOf: group.recursiveAudioRenderLayers())
            }else{
                audioRenderLayersInTimeline.append($0)
            }
        }
        audioRenderLayersInTimeline.forEach {
            if $0.renderLayer.source?.tracks(for: .audio).first != nil{
                let trackId = increaseTrackID()
                $0.trackID = trackId
                $0.addAudioTrack(to: composition, preferredTrackID: trackId)
            }
        }
        
        return composition
    }
    
    private func makeVideoComposition() -> AVMutableVideoComposition {
        // TODO: optimize make performance, like return when exist
        
        // Convert videoRenderLayers to videoCompositionInstructions
        
        // Step 1: Put the layer start time and end time on the timeline, each interval is an instruction. Then sort by time
        // Make sure times contain zero
        var times: [CMTime] = [CMTime.zero]
        videoRenderLayers.forEach { videoRenderLayer in
            let startTime = videoRenderLayer.timeRangeInTimeline.start
            let endTime = videoRenderLayer.timeRangeInTimeline.end
            if !times.contains(startTime) {
                times.append(startTime)
            }
            if !times.contains(endTime) {
                times.append(endTime)
            }
        }
        times.sort { $0 < $1 }
        
        // Step 2: Create instructions for each interval
        var instructions: [VideoCompositionInstruction] = []
        for index in 0..<times.count - 1 {
            let startTime = times[index]
            let endTime = times[index + 1]
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            var intersectingVideoRenderLayers: [VideoRenderLayer] = []
            videoRenderLayers.forEach { videoRenderLayer in
                if !videoRenderLayer.timeRangeInTimeline.intersection(timeRange).isEmpty {
                    intersectingVideoRenderLayers.append(videoRenderLayer)
                }
            }
            
            intersectingVideoRenderLayers.sort(by: {
                $0.renderLayer.layerLevel < $1.renderLayer.layerLevel
            })
            
            let instruction = VideoCompositionInstruction(videoRenderLayers: intersectingVideoRenderLayers, timeRange: timeRange)
            instructions.append(instruction)
        }
        
        // Create videoComposition. Specify frameDuration, renderSize, instructions, and customVideoCompositorClass.
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = renderComposition.frameDuration
        videoComposition.renderSize = renderComposition.renderSize
        videoComposition.instructions = instructions
        videoComposition.customVideoCompositorClass = VideoCompositor.self
        self.videoComposition = videoComposition
        
        return videoComposition
    }
    
//    private func makeAudioMix() -> AVAudioMix? {
//        // TODO: optimize make performance, like return when exist
//        
//        // Convert audioRenderLayers to inputParameters
//        var inputParameters: [AVMutableAudioMixInputParameters] = []
//        audioRenderLayersInTimeline.forEach { audioRenderLayer in
//            let audioMixInputParameters = AVMutableAudioMixInputParameters()
//            audioMixInputParameters.trackID = audioRenderLayer.trackID
//            audioMixInputParameters.audioTimePitchAlgorithm = audioRenderLayer.pitchAlgorithm
//            audioMixInputParameters.audioTapProcessor = audioRenderLayer.makeAudioTapProcessor()
//            inputParameters.append(audioMixInputParameters)
//        }
//
//        // Create audioMix. Specify inputParameters.
//        let audioMix = AVMutableAudioMix()
//        audioMix.inputParameters = inputParameters
//        self.audioMix = audioMix
//        
//        return audioMix
//    }
}
