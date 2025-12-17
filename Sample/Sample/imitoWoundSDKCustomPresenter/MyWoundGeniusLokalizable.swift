//
//  MyWoundGeniusLokalizable.swift
//  Sample
//
//  Created by P Dev on 8/7/25.
//

import UIKit
import WoundGenius

class MyWoundGeniusLokalizable: NSObject, WGLokalizable {
    func lokalize(_ key: String) -> String {
        return L.str(key)
    }

    func lokalize(_ key: WGLokalizableKey) -> String {
        switch key {
        case .captureScreenTitle:
            return "Patient Name"
        case .captureScreenSubtitle:
            return "Patient Date of Birth"
        case .selectAll:
            return L.str("WHOLE_BODY")
        case .clearSelection:
            return L.str("CLEAR_SELECTION")
        case .collapseButtonTitle:
            return L.str("HIDE")
        case .leftShortText:
            return L.str("LEFT_SHORT_TEXT")
        case .rightShortText:
            return L.str("RIGHT_SHORT_TEXT")
        case .lateralSide:
            return L.str("LATERAL")
        case .medialSide:
            return L.str("MEDIAL")
        case .pinsScreenTitle:
            return ""
        default:
            return L.str(key.rawValue)
        }
    }
}
