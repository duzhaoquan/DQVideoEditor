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
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            return simpleDemo()
        }()
        let playerItem = videoEditor.makePlayerItem()
        playerItem.seekingWaitsForVideoCompositionRendering = true
        let controller = DQPlayerViewController(videoEditor: videoEditor)
        controller.player = AVPlayer(playerItem: playerItem)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func makeSynchronizedLayer(playerItem: AVPlayerItem, videoEditor: DQVideoEditor) -> CALayer?{
        guard let animationLayer = videoEditor.renderComposition.animationLayer else{
            return nil
        }
        let layer = AVSynchronizedLayer(playerItem: playerItem)
        return nil
    }
}

