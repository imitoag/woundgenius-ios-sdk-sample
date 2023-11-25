////
////  SummingUp.swift
////  WoundSDK
////
////  Created by Eugene Naloiko on 19.12.2022.
////  Copyright (c) 2022 by imito AG, Zurich, Switzerland
////
//
//import UIKit
//
//public protocol WoundGeniusPresenterProtocol: IMCaptureVCPresenterProtocol,
//                                            UIUtilsConfigProtocol,
//                                            ImitoMeasureConfigProtocol,
//                                            BodyPartPickerConfigProtocol {
//    
//}
//
//public class WoundGeniusFlow: NSObject {
//    private let presenter: WoundGeniusPresenterProtocol
//    private var captureNavVC: UINavigationController!
//    private var cameraVC: IMCaptureViewController!
//    
//    public init(licenseKey: String, presenter: WoundGeniusPresenterProtocol) {
//        _ = Licensing(license: licenseKey)
//        self.presenter = presenter
//        UIUtils.shared.setup(config: presenter)
//        setup(with: presenter)
//        ImitoBodyPartPickerSettings.shared.setup(with: presenter)
//    }
//    
//    public func startCapturing(over: UIViewController) {
//        switch Licensing.shared.status {
//            case .locked(let issue):
//                UIUtils.shared.showOKAlert("License Issue", message: issue)
//                return
//            case .unlocked(let features):
//            
//            // MARK: Capture Modes Validation
//            guard presenter.availableModes.count > 0 else {
//                UIUtils.shared.showOKAlert("Setup the available modes", message: "At least one capture mode should be available.")
//                return
//            }
//            
//            for mode in self.presenter.availableModes {
//                switch mode {
//                case .scanner:
//                    if !features.contains(.barcodeScanning) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .scanner capture mode.")
//                        return
//                    }
//                case .photo:
//                    if !features.contains(.photoCapturing) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .photo capture mode.")
//                        return
//                    }
//                case .video:
//                    if !features.contains(.videoCapturing) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .video capture mode.")
//                        return
//                    }
//                case .markerMeasurement:
//                    if !features.contains(.markerMeasurementCapturing) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .markerMeasurement capture mode.")
//                        return
//                    }
//                case .rulerMeasurement:
//                    if !features.contains(.rulerMeasurementCapturing) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .rulerMeasurement capture mode.")
//                        return
//                    }
//                case .handyscope:
//                    if !features.contains(.handyscropeCapturing) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .handyscope capture mode.")
//                        return
//                    }
//                case .manualInput:
//                    if !features.contains(.manualMeasurementInput) {
//                        UIUtils.shared.showOKAlert("License", message: "Your license doesn't include the .manualInput capture mode.")
//                        return
//                    }
//                }
//            }
//            
//            if presenter.isAddFromLocalStorageAvailable == true, (!features.contains(.localStorageImages) && !features.contains(.localStorageVideos)) {
//                UIUtils.shared.showOKAlert("License", message: "Your license doesn't contain Local Storage Media support. Please set isAddFromLocalStorageAvailable to false, or request another license.")
//                return
//            }
//            
//            PermissionsManager.cameraPermissionsFixed { [weak self] fixed in
//                guard fixed, let self = self else { return }
//                self.showCamera(over: over)
//            }
//            
//            if #available(iOS 14.0, *) {
//                MLContourDetector.shared.initializeModelsInBackground(mode: presenter.autoDetectionMode, password: Licensing.shared.zipPW())
//            }
//        }
//    }
//    
//    public func startBodyPartPicker(over: UIViewController, preselect: BodyPartPickerResult?, completion: @escaping (BodyPartPickerResult?)->()) {
//        switch Licensing.shared.status {
//        case .locked(let issue):
//            UIUtils.shared.showOKAlert("License Issue", message: issue)
//            return
//        case .unlocked(let features):
//            guard features.contains(.bodyPartPicker) else {
//                UIUtils.shared.showOKAlert("License Issue", message: "Body Part Picker is not included into your license. Request another license, including this feature.")
//                return
//            }
//            let bodyPartPicker = BodyPartPickerViewController(preselect: preselect) { bodyPart in
//                completion(bodyPart)
//            }
//            over.present(bodyPartPicker, animated: true)
//        }
//    }
//}
//
//extension WoundGeniusFlow {
//    private func showCamera(over: UIViewController) {
//        self.cameraVC = IMCaptureViewController(presenter: self.presenter)
//        self.captureNavVC = UINavigationController(rootViewController: self.cameraVC)
//        self.captureNavVC.modalPresentationStyle = .fullScreen
//        over.present(self.captureNavVC, animated: true)
//    }
//}
