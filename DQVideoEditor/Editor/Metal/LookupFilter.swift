//
//  LookupFilter.swift
//  DQVideoEditor
//
//  Created by zhaoquan.du on 2022/9/30.
//

import UIKit

class LookupFilter: BasicOperation {

    public var intensity: Float = 1.0 {
        didSet{
            uniformSettings["intensity"] = intensity
        }
    }
    public init() {
        super.init(fragmentFunctionName: "lookupFragment",numberOfInputs: 1)
        ({
            intensity = 1.0
        })()
    }
}
