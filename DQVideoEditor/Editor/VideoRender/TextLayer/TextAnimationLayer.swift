//
//  TextAnimationLayer.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/10/11.
//

import UIKit
import AVFoundation

class TextAnimationLayer: CALayer {
    private let textStorage: NSTextStorage = .init()
    private let layoutManager: NSLayoutManager = .init()
    private let textContainer: NSTextContainer = .init()
    private var textSize: CGSize = .zero
    var animationLayers: [CATextLayer] = []
    
    public var attributedText: NSAttributedString {
        set{
            textStorage.setAttributedString(newValue)
//            updateAnimationLayers()
        }
        get{
            return textStorage as NSAttributedString
        }
    }
    public override var bounds: CGRect {
        set {
            textContainer.size = newValue.size
            super.bounds = newValue
        }
        get {
            return super.bounds
        }
    }

    override init() {
        super.init()
        setUpTextKit()
    }
    override init(layer: Any) {
        super.init(layer: layer)
        setUpTextKit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTextKit(){
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate =  self
        textContainer.size = .zero
    }
    //子类须实现具体的动画
    func addAnimations(to layers: [CATextLayer]){
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 15.0
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.fillMode = .both
        animationGroup.isRemovedOnCompletion = false
        self.add(animationGroup, forKey: "animationGroup")
    }
    private func updateAnimationLayers(){
        if textContainer.size.equalTo(.zero) || attributedText.length == 0{
            return
        }
        //删除旧的animation layers
        animationLayers.forEach {
            $0.removeAllAnimations()
            $0.removeFromSuperlayer()
        }
        animationLayers.removeAll()
        self.removeAllAnimations()
        let string = attributedText.string
        
        string.enumerateSubstrings(in: string.startIndex..<string.endIndex,options: .byComposedCharacterSequences) {[weak self] substring, substringRange, enclosingRange, _ in
            guard let self = self else{
                return
            }
            let glyphRange = NSRange(substringRange, in: string)
            let textRect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in: self.textContainer)
            let textLayer = CATextLayer()
            textLayer.frame = textRect
            textLayer.string = self.attributedText.attributedSubstring(from: glyphRange)
            self.animationLayers.append(textLayer)
            self.addSublayer(textLayer)
        }
        
        addAnimations(to: animationLayers)
    }
}
extension TextAnimationLayer :  NSLayoutManagerDelegate{
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if textContainer == nil {
            return
        }
       updateAnimationLayers()
    }
}
