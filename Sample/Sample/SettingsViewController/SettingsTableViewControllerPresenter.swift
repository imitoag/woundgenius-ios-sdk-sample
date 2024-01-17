//
//  SettingsTableViewControllerPresenter.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit
import WoundGenius

enum SettingKey: String {
    case licenseKey
    case videoModeEnabled
    case markerModeEnabled
    case photoModeEnabled
    case rulerModeEnabled
    case handyscopeModeEnabled
    case localStorageMediaEnabled
    case bodyPartPickerOnCapturingEnabled
    case frontalCameraEnabled
    case autoDetectionType
    case autoDetectionTypeDescription
    
    /// 0 - Off, 1 - On
    case liveWoundDetection
    case liveWoundDetectionDescription
    case maxNumberOfMediaInt
    case multipleOutlinesPerImageEnabled
    
    case stomaCapturing
    case stomaCapturingDescription
    
    case primaryButtonColor
    case lightBackgroundColor
}

struct SettingsSection {
    let labelText: String
    let elements: [SettingsElement]
}

struct SettingsElement {
    let labelText: String
    let key: SettingKey
    let cellId: String
    let isEnabled: Bool
    let minValue: Int?
    let maxValue: Int?
    let options: [String]?
    
    init(labelText: String,
         key: SettingKey,
         cellId: String,
         isEnabled: Bool,
         minValue: Int? = nil,
         maxValue: Int? = nil,
         options: [String]? = nil) {
        self.labelText = labelText
        self.key = key
        self.isEnabled = isEnabled
        self.cellId = cellId
        self.minValue = minValue
        self.maxValue = maxValue
        self.options = options
    }
}

class SettingsTableViewControllerPresenter: NSObject {
    
    var sections: [SettingsSection] {
        var result = [
            SettingsSection(labelText: "License Key", elements: [
                SettingsElement(labelText: "License",
                                key: .licenseKey,
                                cellId: String(describing: TextFieldTableViewCell.self),
                                isEnabled: true)
            ]),
            SettingsSection(labelText: "Modes Configurations",
                            elements: [
                                SettingsElement(labelText: "Video",
                                                key: .videoModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .videoCapturing)),
                                SettingsElement(labelText: "Marker Measurement",
                                                key: .markerModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .markerMeasurementCapturing)),
                                SettingsElement(labelText: "Photo",
                                                key: .photoModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .photoCapturing)),
                                SettingsElement(labelText: "Ruler",
                                                key: .rulerModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .rulerMeasurementCapturing)),
                            ]),
            SettingsSection(labelText: "Max Number of Media",
                            elements: [
                                SettingsElement(labelText: "Max Number of Media",
                                                key: .maxNumberOfMediaInt,
                                                cellId: String(describing: SliderTableViewCell.self),
                                                isEnabled: true,
                                                minValue: 1,
                                                maxValue: 99)
                            ]),
            SettingsSection(labelText: "Flow", elements: [
                SettingsElement(labelText: "Stoma Capturing",
                                key: .stomaCapturing,
                                cellId: String(describing: SwitchTableViewCell.self),
                                isEnabled: WoundGeniusFlow.isAvailable(feature: .stomaDocumentation)),
                SettingsElement(labelText: "When Stoma Capturing flow is activated:\n- Wound Auto-detection, Tissue Type Auto-detection will get disabled.\n- Instead of Wound Depth user will be requested to enter Stoma Height.\n- Instead of Wound Width Length - Stoma Diameter is measured.",
                                key: .stomaCapturingDescription,
                                cellId: String(describing: DescriptionTableViewCell.self),
                                isEnabled: WoundGeniusFlow.isAvailable(feature: .stomaDocumentation))
            ])
        ]
        
        let isMLEnabled = UserDefaults.standard.bool(forKey: SettingKey.stomaCapturing.rawValue) != true &&
        UserDefaults.standard.bool(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue) != false
        
        result.append(
            SettingsSection(labelText: "Machine Learning",
                            elements: [SettingsElement(labelText: "Autodetect",
                                                       key: .autoDetectionType,
                                                       cellId: String(describing: SegmentedTableViewCell.self),
                                                       isEnabled: WoundGeniusFlow.isAvailable(feature: .woundDetection) && isMLEnabled,
                                                       options: ["None", "Wound", "Tissue Types"]),
                                       SettingsElement(labelText: "iOS 14+. To enable Wound or Tissue Types autodetection - your license should have it enabled. Pick Wound option if you need wound auto-detection only. In Tissue Types mode both Wound and Tissue Types will be detected.",
                                                       key: .autoDetectionTypeDescription,
                                                       cellId: String(describing: DescriptionTableViewCell.self),
                                                       isEnabled: WoundGeniusFlow.isAvailable(feature: .woundDetection) && isMLEnabled),
                                       SettingsElement(labelText: "Live Wound Detection",
                                                       key: .liveWoundDetection,
                                                       cellId: String(describing: SegmentedTableViewCell.self),
                                                       isEnabled: WoundGeniusFlow.isAvailable(feature: .liveWoundDetection) && isMLEnabled,
                                                       options: ["Off", "On"]),
                                       SettingsElement(labelText: "iOS 15+. Highlight wound on live video preview - to guide users though the best device positioning for wound capturing. To activate this feature - your license should have it enabled.",
                                                       key: .liveWoundDetectionDescription,
                                                       cellId: String(describing: DescriptionTableViewCell.self),
                                                       isEnabled: WoundGeniusFlow.isAvailable(feature: .liveWoundDetection) && isMLEnabled)])
        )
        
        result.append(
            SettingsSection(labelText: "Other",
                            elements: [
                                SettingsElement(labelText: "Import from Camera Roll",
                                                key: .localStorageMediaEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .localStorageImages) || WoundGeniusFlow.isAvailable(feature: .localStorageVideos)),
                                SettingsElement(labelText: "Body Part Picker while Capturing",
                                                key: .bodyPartPickerOnCapturingEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .bodyPartPicker)),
                                SettingsElement(labelText: "Frontal Camera Enabled",
                                                key: .frontalCameraEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .frontalCamera)),
                                SettingsElement(labelText: "Multiple Outlines per Image",
                                                key: .multipleOutlinesPerImageEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self),
                                                isEnabled: WoundGeniusFlow.isAvailable(feature: .multipleWoundsPerImage)),
                            ])
        )
        
        result.append(
            SettingsSection(labelText: "Color", elements: [
                SettingsElement(labelText: "Primary Button",
                                key: .primaryButtonColor,
                                cellId: String(describing: SegmentedTableViewCell.self),
                                isEnabled: true,
                                options: ["imitoRed", "Blue", "Green"]),
                SettingsElement(labelText: "Light BG",
                                key: .lightBackgroundColor,
                                cellId: String(describing: SegmentedTableViewCell.self),
                                isEnabled: true,
                                options: ["white", "lightGray", "yellow"])
            ])
        )
        
        return result
    }
}
