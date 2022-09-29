//
//  AudioRenderLayerGroup.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/22.
//

import AVFoundation

class AudioRenderLayerGroup: AudioRenderLayer {

    var audioRenderLayers: [AudioRenderLayer] = []
    private var recursiveAudioRenderLayersInGroup: [AudioRenderLayer] = []

    override init(renderLayer: RenderLayer) {
        super.init(renderLayer: renderLayer)
        generateAudioRenderLayers()
    }
    
    // MARK: - Public
    
    public func recursiveAudioRenderLayers() -> [AudioRenderLayer] {
        
        var recursiveAudioRenderLayers: [AudioRenderLayer] = []
        for audioRenderLayer in audioRenderLayers {
            audioRenderLayer.timeRangeInTimeline.start = CMTimeAdd(audioRenderLayer.timeRangeInTimeline.start, self.timeRangeInTimeline.start)
            if let audioRenderLayerGroup = audioRenderLayer as? AudioRenderLayerGroup {
                recursiveAudioRenderLayers += audioRenderLayerGroup.recursiveAudioRenderLayers()
            } else {
                recursiveAudioRenderLayers.append(audioRenderLayer)
            }
        }
        self.recursiveAudioRenderLayersInGroup = recursiveAudioRenderLayers
        
        return recursiveAudioRenderLayers
    }
    
    // MARK: - Private
    
    private func generateAudioRenderLayers() {
        guard let renderLayerGroup = renderLayer as? RenderLayerGroup else {
            return
        }
        
        for subRenderLayer in renderLayerGroup.layers {
            if subRenderLayer is RenderLayerGroup {
                let audioRenderLayerGroup = AudioRenderLayerGroup(renderLayer: subRenderLayer)
                audioRenderLayerGroup.superLayer = self
                audioRenderLayers.append(audioRenderLayerGroup)
            } else if subRenderLayer.canBeConvertedToAudioRenderLayer() {
                let audioRenderLayer = AudioRenderLayer(renderLayer: subRenderLayer)
                audioRenderLayer.superLayer = self
                audioRenderLayers.append(audioRenderLayer)
            }
        }
    }

}
extension AudioRenderLayer {
    class func makeAudioRenderLayer(renderLayer: RenderLayer) -> AudioRenderLayer {
        if renderLayer is RenderLayerGroup {
            return AudioRenderLayerGroup(renderLayer: renderLayer)
        } else {
            return AudioRenderLayer(renderLayer: renderLayer)
        }
    }
}

extension RenderLayerGroup {
    override func canBeConvertedToAudioRenderLayer() -> Bool {
        for renderLayer in layers {
            if renderLayer.canBeConvertedToAudioRenderLayer() {
                return true
            }
        }
        return false
    }
}
