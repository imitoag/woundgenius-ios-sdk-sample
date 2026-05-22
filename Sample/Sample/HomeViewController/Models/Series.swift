//
//  Series.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.01.2023.
//

import UIKit
import WoundGenius

class Series: NSObject {
    /** Date of Creation */
    var timestamp = Date().timeIntervalSince1970
    
    /** Store the results of capturing */
    var captureResults: [CaptureResult]
    
    var formsModel: WGFModel?
        
    init(captureResults: [CaptureResult], formsModel: WGFModel?) {
        self.captureResults = captureResults
        self.formsModel = formsModel
        super.init()
    }
}
