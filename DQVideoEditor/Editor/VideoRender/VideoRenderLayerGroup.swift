//
//  VideoRenderLayerGroup.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/22.
//

import AVFoundation

class VideoRenderLayerGroup: VideoRenderLayer {

    var videoRenderLayers: [VideoRenderLayer] = []
    private var recursiveVideoRenderLayersInGroup: [VideoRenderLayer] = []
    
    override init(renderLayer: RenderLayer) {
        super.init(renderLayer: renderLayer)
        
    }
    public func recuriveVideoRenderLayers() -> [VideoRenderLayer]{
        var recuriveVideoRenderLayers = [VideoRenderLayer]()
        for videoRenderLayer in videoRenderLayers{
            videoRenderLayer.timeRangeInTimeline.start = CMTimeAdd(videoRenderLayer.timeRangeInTimeline.start, timeRangeInTimeline.start)
            if let videoRenderLayerGroup = videoRenderLayer as? VideoRenderLayerGroup{
                recuriveVideoRenderLayers += videoRenderLayerGroup.recuriveVideoRenderLayers()
            }else{
                recuriveVideoRenderLayers.append(videoRenderLayer)
            }
        }
        self.recursiveVideoRenderLayersInGroup = recuriveVideoRenderLayers
        return recuriveVideoRenderLayers
    }
    
    func recursiveTrackIDs() -> [CMPersistentTrackID] {
        return recursiveVideoRenderLayersInGroup.compactMap {
            $0.trackId
        }
    }

    //处理layers 拍平
    private func generateVideoRenderlayers(){
        guard let renderLayerGroup = renderLayer as? RenderLayerGroup else{
            return
        }
        
        for subRenderLayer in renderLayerGroup.layers {
            if subRenderLayer is RenderLayerGroup {
                videoRenderLayers.append(VideoRenderLayerGroup(renderLayer: subRenderLayer))
            }else{
                videoRenderLayers.append(VideoRenderLayer(renderLayer: subRenderLayer))
            }
        }
    }
}
extension VideoRenderLayer {
    class func makeVideoRenderLayer(renderLayer:RenderLayer) -> VideoRenderLayer{
        if renderLayer is RenderLayerGroup{
            return VideoRenderLayerGroup(renderLayer: renderLayer)
        }else {
            return VideoRenderLayer(renderLayer: renderLayer)
        }
    }
}
extension RenderLayerGroup {
    override func canBeConvertedToVideoRenderLayer() -> Bool {
        layers.contains {
            $0.canBeConvertedToVideoRenderLayer()
        }
    }
}
