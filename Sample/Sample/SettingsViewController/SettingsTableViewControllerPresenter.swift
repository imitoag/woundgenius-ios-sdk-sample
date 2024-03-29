//
//  SettingsTableViewControllerPresenter.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit
import WoundGenius

enum SettingKey: String {
    /// String
    case licenseKey
    
    /// Bool
    case videoModeEnabled
    
    /// Bool
    case markerModeEnabled
    
    /// Bool
    case photoModeEnabled
    
    /// Bool
    case rulerModeEnabled
    
    /// Bool
    case handyscopeModeEnabled
    
    /// Bool
    case localStorageMediaEnabled
    
    /// Bool
    case bodyPartPickerOnCapturingEnabled
    
    /// Bool
    case frontalCameraEnabled
    
    /// Bool
    case woundDetection
    case woundDetectionDescription
    
    /// Bool
    case liveWoundDetection
    case liveWoundDetectionDescription
    
    /// Bool
    case tissueTypesDetection
    case tissueTypesDetectionDescription
    
    /// Bool
    case minNumberOfMediaInt
    case maxNumberOfMediaInt
    case minMaxNumberOfMediaDescription
    case multipleOutlinesPerImageEnabled
    
    /// Bool
    case stomaCapturing
    case stomaCapturingDescription
    
    /// Bool
    case primaryButtonColor
    case lightBackgroundColor
    
    var cellId: String {
        switch self {
        case .licenseKey:
            return String(describing: TextFieldTableViewCell.self)
        case .videoModeEnabled,
                .markerModeEnabled,
                .photoModeEnabled,
                .rulerModeEnabled,
                .handyscopeModeEnabled,
                .localStorageMediaEnabled,
                .bodyPartPickerOnCapturingEnabled,
                .frontalCameraEnabled,
                .woundDetection,
                .liveWoundDetection,
                .tissueTypesDetection,
                .multipleOutlinesPerImageEnabled,
                .stomaCapturing:
            return String(describing: SwitchTableViewCell.self)
        case .woundDetectionDescription, .liveWoundDetectionDescription, .tissueTypesDetectionDescription, .stomaCapturingDescription, .minMaxNumberOfMediaDescription:
            return String(describing: DescriptionTableViewCell.self)
        case .minNumberOfMediaInt, .maxNumberOfMediaInt:
            return String(describing: SliderTableViewCell.self)
        case .primaryButtonColor, .lightBackgroundColor:
            return String(describing: SegmentedTableViewCell.self)
        }
    }
    
    var correspondingFeature: Feature? {
        switch self {
        case .licenseKey, .woundDetectionDescription, .liveWoundDetectionDescription, .tissueTypesDetectionDescription, .minNumberOfMediaInt, .maxNumberOfMediaInt, .stomaCapturingDescription, .primaryButtonColor, .lightBackgroundColor, .minMaxNumberOfMediaDescription:
            return nil
        case .videoModeEnabled:
            return .videoCapturing
        case .markerModeEnabled:
            return .markerMeasurementCapturing
        case .photoModeEnabled:
            return .photoCapturing
        case .rulerModeEnabled:
            return .rulerMeasurementCapturing
        case .handyscopeModeEnabled:
            return .handyscopeCapturing
        case .localStorageMediaEnabled:
            return .localStorageImages
        case .bodyPartPickerOnCapturingEnabled:
            return .bodyPartPicker
        case .frontalCameraEnabled:
            return .frontalCamera
        case .woundDetection:
            return .woundDetection
        case .liveWoundDetection:
            return .liveWoundDetection
        case .tissueTypesDetection:
            return .tissueTypeDetection
        case .multipleOutlinesPerImageEnabled:
            return .multipleWoundsPerImage
        case .stomaCapturing:
            return .stomaDocumentation
        }
    }
}

struct SettingsSection {
    let labelText: String
    let elements: [SettingsElement]
}

struct SettingsElement {
    let labelText: String
    let key: SettingKey
    let isEnabled: Bool
    let minValue: Int?
    let maxValue: Int?
    let options: [String]?
    
    init(labelText: String,
         key: SettingKey,
         isEnabled: Bool,
         minValue: Int? = nil,
         maxValue: Int? = nil,
         options: [String]? = nil) {
        self.labelText = labelText
        self.key = key
        self.isEnabled = isEnabled
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
                                isEnabled: true)
            ]),
            SettingsSection(labelText: "Modes Configurations",
                            elements: [
                                SettingsElement(labelText: "Video",
                                                key: .videoModeEnabled,
                                                isEnabled: WG.isAvailable(feature: .videoCapturing)),
                                SettingsElement(labelText: "Marker Measurement",
                                                key: .markerModeEnabled,
                                                isEnabled: WG.isAvailable(feature: .markerMeasurementCapturing)),
                                SettingsElement(labelText: "Photo",
                                                key: .photoModeEnabled,
                                                isEnabled: WG.isAvailable(feature: .photoCapturing)),
                                SettingsElement(labelText: "Ruler",
                                                key: .rulerModeEnabled,
                                                isEnabled: WG.isAvailable(feature: .rulerMeasurementCapturing)),
                            ]),
            SettingsSection(labelText: "Number of media per series/assessment",
                            elements: [
                                SettingsElement(labelText: "Min number of media items",
                                                key: .minNumberOfMediaInt,
                                                isEnabled: true,
                                                minValue: 0,
                                                maxValue: 1),
                                SettingsElement(labelText: "Max number of media items",
                                                key: .maxNumberOfMediaInt,
                                                isEnabled: true,
                                                minValue: 1,
                                                maxValue: 100),
                                SettingsElement(labelText: "When minimal number of media is 0 - on capture screen Done button will be always enabled (except video capturing process). This is done to enable possibility to create empty series/assessments with some additional metadata (Like Status/Therapy data collection).\nWhen min and max number of items is 1 - Done button won't be shown, instead - Capture Screen will complete operating just after single media capturing.",
                                                key: .minMaxNumberOfMediaDescription,
                                                isEnabled: true)

                            ]),
            SettingsSection(labelText: "Flow", elements: [
                SettingsElement(labelText: "Stoma Capturing",
                                key: .stomaCapturing,
                                isEnabled: WG.isAvailable(feature: .stomaDocumentation)),
                SettingsElement(labelText: "When Stoma Capturing flow is activated:\n- Wound Auto-detection, Tissue Type Auto-detection will get disabled.\n- Instead of Wound Depth user will be requested to enter Stoma Height.\n- Instead of Wound Width Length - Stoma Diameter is measured.",
                                key: .stomaCapturingDescription,
                                isEnabled: WG.isAvailable(feature: .stomaDocumentation))
            ])
        ]
        
        let isMLEnabled = UserDefaults.standard.bool(forKey: SettingKey.stomaCapturing.rawValue) != true &&
        UserDefaults.standard.bool(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue) != false
        
        result.append(
            SettingsSection(labelText: "Machine Learning",
                            elements: [SettingsElement(labelText: Feature.woundDetection.title,
                                                       key: .woundDetection,
                                                       isEnabled: WG.isAvailable(feature: .woundDetection) && isMLEnabled),
                                       SettingsElement(labelText: "iOS 14+. To enable Wound Autodetection - your license should have it enabled. (Model: \(WGConstants.woundDetectionModelName))",
                                                       key: .woundDetectionDescription,
                                                       isEnabled: WG.isAvailable(feature: .woundDetection) && isMLEnabled),
                                       SettingsElement(labelText: Feature.liveWoundDetection.title,
                                                       key: .liveWoundDetection,
                                                       isEnabled: WG.isAvailable(feature: .liveWoundDetection) && isMLEnabled && UserDefaults.standard.bool(forKey: SettingKey.woundDetection.rawValue)),
                                       SettingsElement(labelText: "iOS 15+. Highlight wound on live video preview - to guide users though the best device positioning for wound capturing. To activate this feature - your license should have it enabled.",
                                                       key: .liveWoundDetectionDescription,
                                                       isEnabled: WG.isAvailable(feature: .liveWoundDetection) && isMLEnabled && UserDefaults.standard.bool(forKey: SettingKey.woundDetection.rawValue)),
                                       SettingsElement(labelText: Feature.tissueTypeDetection.title,
                                                       key: .tissueTypesDetection,
                                                       isEnabled: WG.isAvailable(feature: .tissueTypeDetection) && isMLEnabled),
                                       SettingsElement(labelText: "iOS 14+. To enable Tissue Type Detection - your license should have it enabled. (Model: \(WGConstants.tissueTypeDetectionModelName))",
                                                       key: .tissueTypesDetectionDescription,
                                                       isEnabled: WG.isAvailable(feature: .tissueTypeDetection) && isMLEnabled)])
        )
        
        result.append(
            SettingsSection(labelText: "Other",
                            elements: [
                                SettingsElement(labelText: "Import from Camera Roll",
                                                key: .localStorageMediaEnabled,
                                                isEnabled: WG.isAvailable(feature: .localStorageImages) || WG.isAvailable(feature: .localStorageVideos)),
                                SettingsElement(labelText: "Body Part Picker while Capturing",
                                                key: .bodyPartPickerOnCapturingEnabled,
                                                isEnabled: WG.isAvailable(feature: .bodyPartPicker)),
                                SettingsElement(labelText: "Frontal Camera Enabled",
                                                key: .frontalCameraEnabled,
                                                isEnabled: WG.isAvailable(feature: .frontalCamera)),
                                SettingsElement(labelText: "Multiple Outlines per Image",
                                                key: .multipleOutlinesPerImageEnabled,
                                                isEnabled: WG.isAvailable(feature: .multipleWoundsPerImage)),
                            ])
        )
        
        result.append(
            SettingsSection(labelText: "Color", elements: [
                SettingsElement(labelText: "Primary Button",
                                key: .primaryButtonColor,
                                isEnabled: true,
                                options: ["imitoRed", "Blue", "Green"]),
                SettingsElement(labelText: "Light BG",
                                key: .lightBackgroundColor,
                                isEnabled: true,
                                options: ["white", "lightGray", "yellow"])
            ])
        )
        
        return result
    }
}
