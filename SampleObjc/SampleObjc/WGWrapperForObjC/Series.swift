//
//  Series.swift
//  SampleObjc
//
//  Created by apple on 13.03.2024.
//

import UIKit

class Series: NSObject {
    /** Date of Creation */
    var timestamp = Date().timeIntervalSince1970
    
    /** Store the results of capturing */
    var captureResults: [Any]
        
    init(captureResults: [Any]) {
        self.captureResults = captureResults
        super.init()
    }
}
