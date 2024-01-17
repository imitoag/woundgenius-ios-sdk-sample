//
//  SettingsTableViewController.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit
import WoundGenius

class SettingsTableViewController: UITableViewController {
    
    private let presenter = SettingsTableViewControllerPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sections[section].labelText
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sections[section].elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = presenter.sections[indexPath.section].elements[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: element.cellId, for: indexPath)
        
        switch element.cellId {
        case String(describing: SwitchTableViewCell.self):
            let switchCell = cell as! SwitchTableViewCell
            switchCell.labelElement.text = element.labelText
            switchCell.switchElement.isOn = UserDefaults.standard.bool(forKey: element.key.rawValue)
            switchCell.isEnabled = element.isEnabled
            
            switchCell.valueChanged = { newValue in
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
                if element.key == .stomaCapturing   {
                    if newValue == true {
                        UserDefaults.standard.setValue(0, forKey: SettingKey.autoDetectionType.rawValue)
                        UserDefaults.standard.setValue(0, forKey: SettingKey.liveWoundDetection.rawValue)
                    }
                    self.refreshTableView()
                }
                if element.key == .multipleOutlinesPerImageEnabled {
                    if newValue == false {
                        UserDefaults.standard.setValue(0, forKey: SettingKey.autoDetectionType.rawValue)
                        UserDefaults.standard.setValue(0, forKey: SettingKey.liveWoundDetection.rawValue)
                    }
                    self.refreshTableView()
                }
            }
            return switchCell
        case String(describing: SliderTableViewCell.self):
            let sliderCell = cell as! SliderTableViewCell
            sliderCell.labelElement.text = "\(element.labelText): \(UserDefaults.standard.integer(forKey: element.key.rawValue))"
            sliderCell.sliderElement.value = Float(UserDefaults.standard.integer(forKey: element.key.rawValue))
            sliderCell.sliderElement.minimumValue = Float(element.minValue ?? 0)
            sliderCell.sliderElement.maximumValue = Float(element.maxValue ?? 100)
            sliderCell.isEnabled = element.isEnabled
            
            sliderCell.valueChanged = { [weak sliderCell] newValue in
                sliderCell?.labelElement.text = "\(element.labelText): \(UserDefaults.standard.integer(forKey: element.key.rawValue))"
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
            }
            return sliderCell
        case String(describing: TextFieldTableViewCell.self):
            let textFieldCell = cell as! TextFieldTableViewCell
            textFieldCell.labelElement.text = element.labelText
            textFieldCell.textFieldElement.text = UserDefaults.standard.string(forKey: element.key.rawValue)
            textFieldCell.isEnabled = element.isEnabled
            
            textFieldCell.valueChanged = { newValue in
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
                if element.key == .licenseKey {
                    _ = WoundGeniusFlow(licenseKey: newValue ?? "", presenter: MyWoundGeniusPresenter(completion: { _ in }))
                    self.refreshTableView()
                    for feature in Feature.allCases {
                        switch feature {
                        case .photoCapturing:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.photoModeEnabled.rawValue)
                        case .videoCapturing:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.videoModeEnabled.rawValue)
                        case .rulerMeasurementCapturing:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.rulerModeEnabled.rawValue)
                        case .markerMeasurementCapturing:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.markerModeEnabled.rawValue)
                        case .frontalCamera:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.frontalCameraEnabled.rawValue)
                        case .multipleWoundsPerImage:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue)
                        case .woundDetection, .tissueTypeDetection:
                            UserDefaults.standard.setValue(WoundGeniusFlow.isAvailable(feature: .woundDetection) ? 1 : 0, forKey: SettingKey.autoDetectionType.rawValue)
                        case .liveWoundDetection:
                            UserDefaults.standard.setValue(WoundGeniusFlow.isAvailable(feature: .liveWoundDetection) ? 1 : 0, forKey: SettingKey.liveWoundDetection.rawValue)
                        case .bodyPartPicker:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.bodyPartPickerOnCapturingEnabled.rawValue)
                        case .localStorageImages, .localStorageVideos:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.localStorageMediaEnabled.rawValue)
                        case .stomaDocumentation:
                            UserDefaults.standard.set(WoundGeniusFlow.isAvailable(feature: feature), forKey: SettingKey.stomaCapturing.rawValue)
                        case .barcodeScanning:
                            break
                        case .manualMeasurementInput:
                            break
                        case .handyscopeCapturing:
                            break
                        case .debugMode:
                            break
                        @unknown default:
                            break
                        }
                    }
                }
            }
        case String(describing: SegmentedTableViewCell.self):
            let segmentedCell = cell as! SegmentedTableViewCell
            segmentedCell.labelElement.text = element.labelText
            if let options = element.options {
                segmentedCell.segmentedControl.removeAllSegments()
                for (index, option) in options.enumerated() {
                    segmentedCell.segmentedControl.insertSegment(withTitle: option, at: index, animated: false)
                }
            }
            segmentedCell.segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: element.key.rawValue)
            segmentedCell.isEnabled = element.isEnabled
            
            segmentedCell.valueChanged = { newValue in
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
            }
        case String(describing: DescriptionTableViewCell.self):
            let descriptionCell = cell as! DescriptionTableViewCell
            descriptionCell.isEnabled = element.isEnabled
            descriptionCell.descriptionLabel.text = element.labelText
        default:
            assertionFailure()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let element = presenter.sections[indexPath.section].elements[indexPath.row]
        if !element.isEnabled {
            UIUtils.shared.showOKAlert("Update the License Key",
                                       message: "To access this feature - License Key should have it enabled.")
        }
    }
    
    private func refreshTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
