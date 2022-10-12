//
//  ViewController.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/14.
//

import AVFoundation
import UIKit

class ViewController: UITableViewController {

    let titiles = ["simple","multi lalyer","audio volum ramp","text animation","key frame animation","layer group","transition2D"]
    var filterTextures: [Texture] = []
    let renderSize = CGSize(width: 1280, height: 720)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        filterTextures = makeFilterTexture()
    }
    

    func simpleDemo() -> DQVideoEditor {
        // 1. Layer 1
        var url = Bundle.main.url(forResource: "hdr", withExtension: "mov")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        var timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        // 1. Layer 2
        url = Bundle.main.url(forResource: "sea", withExtension: "mp4")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        timeRange.start = CMTimeRangeGetEnd(renderLayer1.timeRange)
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: source)
        
        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [renderLayer1, renderLayer2]

        
        let editor = DQVideoEditor(renderComposition: composition)
        
        return editor
    }
    
    func multiLayerDemo() -> DQVideoEditor{
        //layer1
        guard let url = Bundle.main.url(forResource: "sea", withExtension: "mp4") else{
            fatalError(" no url")
        }
        var asset = AVAsset(url: url)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: .zero, duration: asset.duration)
        var timeRange = source.selectedTimeRange
        let renderLaayer1 = RenderLayer(timeRange: timeRange,source: source)
        
        var center = CGPoint(x: 0.25, y: 0.25)
        let layer1Size = source.videoSize
        if let  layer1Size = layer1Size {
            center.x = layer1Size.width * 0.5 / 2.0 / renderSize.width
            center.y = layer1Size.height * 0.5 / 2.0 / renderSize.height
        }
        var transform = Transform(center: center, rotation: 0, scale: 0.5)
        renderLaayer1.transform = transform
        
        //layer2
        let image = UIImage(named: "image1.JPG")
        let imagesource = ImageSource(cgImage: image?.cgImage)
        imagesource.selectedTimeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 15, preferredTimescale: 600))
        timeRange = imagesource.selectedTimeRange
        let renderLayer2 = RenderLayer(timeRange: timeRange,source: imagesource)
        
        var filter = LookupFilter()
        filter.addTexture(filterTextures[0], at: 0)
        renderLayer2.operations = [filter]
        
        transform = Transform(center: CGPoint(x: 0.25, y: 0.75), rotation: 0, scale: 1.0/8)
        renderLayer2.transform = transform
        
        //layer3
        guard let url = Bundle.main.url(forResource: "cute", withExtension: "mp4") else{
            fatalError(" no url")
        }
        asset = AVAsset(url: url)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        let renderLayer3 = RenderLayer(timeRange: timeRange, source: source)
        filter = LookupFilter()
        filter.addTexture(filterTextures[1], at:0)
        renderLayer3.operations = [filter]
        var scale:Float = 1/3.0
        var x = 0.75
        var y = 0.25
        if let layer1Size = layer1Size,let layer3Size = source.videoSize {
            scale = Float((renderSize.width - layer1Size.width/2.0) / layer3Size.width)
            x = (renderSize.width - layer3Size.width * CGFloat(scale) / 2.0) / renderSize.width
            y = ((layer3Size.height * CGFloat(scale)) / 2) / renderSize.height
        }
        renderLayer3.transform = Transform(center: CGPoint(x: x, y: y), rotation: 0, scale: scale)
        
        //layer4
        guard let url = Bundle.main.url(forResource: "bamboo", withExtension: "mp4") else{
            fatalError("no url")
        }
        asset = AVAsset(url: url)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        let renderLayer4 = RenderLayer(timeRange: timeRange, source: source)
        filter = LookupFilter()
        filter.addTexture(filterTextures[3], at:0)
        renderLayer4.operations = [filter]
        renderLayer4.transform = Transform(center: CGPoint(x: 0.75, y: 0.75), rotation: 0, scale: 1/3.0)
        
        let composition = RenderComposition()
        composition.renderSize = renderSize
        composition.layers = [renderLaayer1,renderLayer3]
        
        composition.backgroundColor = Color(red: 21, green: 1, blue: 47)
        let videoEditor = DQVideoEditor(renderComposition: composition)
        return videoEditor
    }
    
    
    func textAnimationDemo() -> DQVideoEditor {
        // 1. Layer 1
        let url = Bundle.main.url(forResource: "cute", withExtension: "mp4")
        let asset = AVAsset(url: url!)
        let source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = renderSize
        composition.layers = [renderLayer1]
        composition.animationLayer = makeTextLayer()
        
        let editor = DQVideoEditor(renderComposition: composition)
        
        return editor
    }
    func makeTextLayer() -> TextAnimationLayer{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes:[NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 120),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: "Hello Beijing,I'm Come In",attributes: attributes)
        let size = attributedString.boundingRect(with: renderSize,options: .usesLineFragmentOrigin, context: nil).size
        let layer = TextOpacityAnimationLayer()
        layer.attributedText = attributedString
        layer.position = CGPoint(x: renderSize.width/2, y: renderSize.height/2)
        layer.bounds = CGRect(origin: .zero, size: size)
        
        return layer
    }
    
    
    func makeFilterTexture() -> [Texture]{
        let filterNames = ["LUT_M01", "LUT_M02", "LUT_M03", "LUT_M07", "LUT_M06", "LUT_M12", "LUT_M11", "LUT_M05", "LUT_M08", "LUT_M09"]
        var textures = [Texture]()
        for name in filterNames {
            guard let image = UIImage(named: name)?.cgImage else {
                continue
            }
            guard let texture = Texture.makeTexture(cgImage: image) else{
                continue
            }
            textures.append(texture)
        }
        return textures
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titiles.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = titiles[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoEditor: DQVideoEditor = {
            if indexPath.row == 1{
                return multiLayerDemo()
            }else if indexPath.row == 3 {
                return textAnimationDemo()
            }
            return simpleDemo()
        }()
        let playerItem = videoEditor.makePlayerItem()
        playerItem.seekingWaitsForVideoCompositionRendering = true
        let controller = DQPlayerViewController(videoEditor: videoEditor)
        controller.player = AVPlayer(playerItem: playerItem)
        
        if let layer = makeSynchronizedLayer(playerItem: playerItem, videoEditor: videoEditor) {
            controller.view.layer.addSublayer(layer)
        }
        navigationController?.pushViewController(controller, animated: true)
//        if let layer = videoEditor.renderComposition.animationLayer as? TextOpacityAnimationLayer {
//            view.layer.addSublayer(layer)
//            layer.addAnimations(to: layer.animationLayers)
//            layer.backgroundColor = UIColor.blue.cgColor
//        }
        
    }
    
    
    func makeSynchronizedLayer(playerItem: AVPlayerItem, videoEditor: DQVideoEditor) -> CALayer?{
        guard let animationLayer = videoEditor.renderComposition.animationLayer else{
            return nil
        }
        
        let layer = AVSynchronizedLayer(playerItem: playerItem)
        layer.addSublayer(animationLayer)
        layer.zPosition = 999
        let videoSize = videoEditor.renderComposition.renderSize
        
        let screenSize = UIScreen.main.bounds.size
        let videoRect = AVMakeRect(aspectRatio: videoSize, insideRect: CGRect(origin: .zero, size: screenSize))
        layer.position = CGPoint(x: videoRect.midX, y: videoRect.maxY)
        let  scale = fminf(Float(screenSize.width / videoSize.width), Float(screenSize.height / videoSize.height))
        layer.setAffineTransform(CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))
        layer.frame = videoRect
        
        
        return layer
    }
}

