//
//  DQPlayerViewController.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/22.
//

import AVKit


class DQPlayerViewController: AVPlayerViewController {
    var videoEditor:DQVideoEditor
    var exportSession: AVAssetExportSession?
    init(videoEditor: DQVideoEditor) {
        self.videoEditor = videoEditor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(saveVideo))
    }
    @objc func saveVideo(){
        
    }
    

}
