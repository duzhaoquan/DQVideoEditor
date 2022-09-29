//
//  AudioConfiguration.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/15.
//

import UIKit
import AVFoundation

public struct AudioConfiguration {
    var pitchAlgorithm: AVAudioTimePitchAlgorithm = .varispeed
    var volumeRamps: [VolumeRamp] = []

}

public struct VolumeRamp {
    var startVolume: Float
    var endVolume: Float
    var timeRange: CMTimeRange
    var timingFuntion: TimingFunction = .linear
    
    
    
}
