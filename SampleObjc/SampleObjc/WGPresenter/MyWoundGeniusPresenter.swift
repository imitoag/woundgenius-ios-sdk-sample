//
//  MyWoundGeniusPresenter.swift
//  SampleObjc
//
//  Created by apple on 13.03.2024.
//

import UIKit
import CoreMedia
import AVFoundation
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

class MyWoundGeniusPresenter: NSObject, WGPresenterProtocol {
    var availablePoseModes: [WoundGenius.PoseMode]?
    
    var defaultPoseMode: WoundGenius.PoseMode?
    
    var isFacialSurgeryEnabled: Bool = false
    
    var isSingleAreaModeEnabled: Bool = false
    
    var rulerScaleAutoDetectionEnabled: Bool = false
    
    var isEmergencyModeEnabled: Bool = false
    
    var showMarkerMeasurementTutorialAutomatically: Bool = false
    
    var refreshLastMediaIconAndRightBarButtonState: (() -> ())?
    
    var userId: String?
    
    var availableModes: [WoundGenius.ImitoCameraMode] = [.video, .photo, .markerMeasurement, .rulerMeasurement]
    
    var defaultMode: WoundGenius.ImitoCameraMode = .markerMeasurement
    
    var tutorialsAvailableForModes: [WoundGenius.ImitoCameraMode] = [.markerMeasurement, .rulerMeasurement]
    
    var isBodyPartPickerAvailable: Bool = false
    
    var isAddFromLocalStorageAvailable: Bool = true
    
    var isFrontCameraUsageAllowed: Bool = false
    
    var isFullHDVideoEnabled: Bool = false
    
    var isVideoWithAudioEnabled: Bool = false
    
    var isLiveWoundDetectionEnabled: Bool = true
    
    var isCancelBarButtonItemVisible: Bool = true
    
    var tfLiteExtension: WoundGenius.TFLiteExtensionProtocol? {
        WoundGeniusTFLiteExtension.shared
    }
    
    var showTutorialOnViewDidAppear: Bool = false
    
    var minNumberOfMedia: Int = 1
    
    var maxNumberOfMedia: Int = 99
    
    var operatingMode: WoundGenius.OperatingMode = .SDK
    
    func lastMediaIcon(icon: @escaping (UIImage?) -> ()) {
        guard let lastMedia = self.capturedItemsToReturn.last else {
            icon(nil)
            return
        }
        if let measurement = lastMedia as? MeasurementResult {
            icon(measurement.image)
        } else if let video = lastMedia as? VideoCaptureResult {
            icon(video.preview)
        } else if let photo = lastMedia as? PhotoCaptureResult {
            icon(photo.preview)
        } else if let image = lastMedia as? ImageCaptureResult {
            icon(image.image)
        }
    }
        
    var headerTextColorUIUtils: UIColor = .black
    
    var customBlackColorUIUtils: UIColor = .black
    
    var customRedColorUIUtils: UIColor = WGConstants.Color.red
    
    var imBlackColor: UIColor = .black
    
    var primaryButtonColor: UIColor = WGConstants.Color.red
    
    var lightBackgroundColor: UIColor = WGConstants.Color.lightSemitransparentBackground
    
    var completionButtonTitle: WoundGenius.WGLokalizableKey = .CONTINUE_BUTTON
    
    var isSendPrintablePDFHidden: Bool = true
    
    var isResultsBottomBarHidden: Bool = true
    
    var backNavigationBarButtonTitle: String?
    
    var isDepthOrHeightInputEnabled: Bool = true
    
    var autoDetectionMode: WoundGenius.AutoDetectionMode = .woundOnly
    
    var enabledOutlineTypes: [WoundGenius.IMOutlineCluster] = [.wound]
    
    func lokalize(_ key: WoundGenius.WGLokalizableKey) -> String {
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
    
    func lokalize(_ key: String) -> String {
        L.str(key)
    }
    
    func handle(event: WoundGenius.WGEvent) {
        switch event {
        case .woundAutoDetectionExecuted(let int):
            print("Log woundAutoDetectionExecuted for statistics. \(int) wound outines detected. No actions needed.")
        case .autoDetectButtonClicked:
            print("Log autoDetectButtonClicked event for statistics. No actions needed.")
        case .autoDetectResultsEdited:
            print("Log autoDetectResultsEdited event for statistics. No actions needed.")
        case .stoppedCapturingVideoBecauseOfDurationLimit(let vc):
            print("Show here the explanation that video capturing stopped automatically, as the video duration limit was reached.")
        case .cancelButtonTapped(let vc):
            UIUtils.showConfirmationAlert(title: "Confirmation Popup", message: "Are you sure you want to cancel capturing?", confirmButton: "Cancel", cancelButton: "Dismiss") {
                vc.dismiss(animated: true)
            }
        case .rightBarButtonTapped(let vc):
            self.completion?(self.capturedItemsToReturn)
            vc.dismiss(animated: true) { [weak self] in
                self?.capturedItemsToReturn = [Any]()
            }
        case .capturedMarkerMeasurement(let vc, let result):
            self.showOutlining(captureVC: vc, captureResult: result)
        case .capturedPhoto(let vc, let result):
            capturedItemsToReturn.append(result)
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [Any]()
            }
        case .capturedRulerMeasurementImage(let vc, let result):
            self.showRulerMeasurementScaleDefinition(captureVC: vc, captureResult: result)
        case .pickedPhoto(vc: let vc, result: let photoResult, let markerDetector):
            print("The IMCaptureViewController: \(vc), the photoResult: \(photoResult)")
            // Search for imito marker on the image. If it will be detected - start measurement.
            switch vc.currentMode {
            case .markerMeasurement, .rulerMeasurement:
                markerDetector.searchMarker(image: photoResult.preview) { [weak self] status in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        switch status {
                        case .detected(let pointsPercentage, _):
                            let captureResultNew = MeasurementCaptureResult(photoName: photoResult.photoName,
                                                                            photo: photoResult.preview,
                                                                            codeDetection: CodeDetectionResult(code: "10mm",
                                                                                                               fromQRCode: false,
                                                                                                               pointsPercentage: pointsPercentage))
                            self.showOutlining(captureVC: vc, captureResult: captureResultNew)
                        default:
                            // Starting the Ruler Measurement. As there is no marker in the image. You can adjust it to required behaviour.
                            self.showRulerMeasurementScaleDefinition(captureVC: vc, captureResult: photoResult)
                        }
                    }
                }
            default:
                self.capturedItemsToReturn.append(photoResult)
                if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                    self.completion?(self.capturedItemsToReturn)
                    self.capturedItemsToReturn = [Any]()
                }
            }
        case .pickedVideo(let vc, let result):
            capturedItemsToReturn.append(result)
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [Any]()
            }
        case .capturedVideo(let vc, let result):
            capturedItemsToReturn.append(result)
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [Any]()
            }
        case .capturedManualInputPhoto(let vc, let result):
            break
        case .capturedHandyscopePhoto(let vc, let result, let widthOfScreen, let percentageOfScreen1mm):
            break
        case .helpButtonClicked(let over, let mode, let sourceView, let isTopViewTapped):
            var vc = UIViewController()
            switch mode {
            case .markerMeasurement:
                do {
                    let jsonHelpConfig = (self.autoDetectionMode == .none) ? "CALIBRATION_MARKER_HELP_JSON" : "CALIBRATION_MARKER_LIVE_WOUND_AUTODETECT_HELP_JSON"
                    guard let data = L.str(jsonHelpConfig).data(using: .utf8) else {
                        vc = showManualTutorialScreenViewController(type: .calibrationMarker, tutorialVideoName: "marker-mode-tutorial", videoExtension: "mp4", config: self)
                        break
                    }
                    let tutorialData = try JSONDecoder().decode([TutorialData].self, from: data)
                    for item in tutorialData {
                        item.htmlBody = L.strWithPatterns(item.htmlBodyKey)
                    }
                    vc = WebViewTutorialScreen(title: L.str("CALIBRATION_MARKER"), data: tutorialData, videoName: "marker-mode-tutorial", videoExtension: "mp4", config: self)
                } catch {
                    vc = showManualTutorialScreenViewController(type: .calibrationMarker, tutorialVideoName: "marker-mode-tutorial", videoExtension: "mp4", config: self)
                }
            case .rulerMeasurement:
                do {
                    let jsonHelpConfig = (self.autoDetectionMode == .none) ? "RULER_HELP_JSON" : "RULER_LIVE_WOUND_AUTODETECT_HELP_JSON"
                    guard let data = L.str(jsonHelpConfig).data(using: .utf8) else {
                        vc = showManualTutorialScreenViewController(type: .rulerMode, tutorialVideoName: "ruler-mode-tutorial", videoExtension: "mp4", config: self)
                        break
                    }
                    let tutorialData = try JSONDecoder().decode([TutorialData].self, from: data)
                    for item in tutorialData {
                        item.htmlBody = L.strWithPatterns(item.htmlBodyKey)
                    }
                    vc = WebViewTutorialScreen(title: L.str("RULER_MODE"), data: tutorialData, videoName: "ruler-mode-tutorial", videoExtension: "mp4", config: self)
                } catch {
                    vc = showManualTutorialScreenViewController(type: .rulerMode, tutorialVideoName: "ruler-mode-tutorial", videoExtension: "mp4", config: self)
                }
            case .handyscope, .photo, .video, .scanner, .manualInput:
                assertionFailure("Not supported")
            @unknown default:
                assertionFailure("Unknown default")
            }
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen // Full screen is needed. Otherwise the AVPlayerViewController is hanging on dismissal.
            over.present(navVC, animated: true)
        case .viewWillAppear(let vc):
            break
        case .viewWillDisappear(let vc):
            break
        case .launchBodyPartPickerClicked(let vc):
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Non-Protocol. Custom Methods
    private var capturedItemsToReturn = [Any]()
    private var completion: (([Any])->())!
    init(completion: @escaping (([Any])->())) {
        super.init()
        self.completion = completion
    }
}

extension MyWoundGeniusPresenter {
    func showOutlining(captureVC: IMCaptureViewController,
                       captureResult: PhotoCaptureResult,
                       pointViews: [AMPointView2],
                       sideSize: CGFloat) {
        guard let point1 = pointViews.first?.center else {
            assertionFailure()
            return
        }
        
        guard let point2 = pointViews.last?.center else {
            assertionFailure()
            return
        }
        
        guard let image = captureResult.preview else { return }
        
        var linePoints: [CGPoint]
        if point1.x > point2.x {
            linePoints = [point2, point1]
        } else {
            linePoints = [point1, point2]
        }
        
        var imNavController: IMNavigationController?
        
        let woundStomaConfig: WoundStomaConfig =
            .wound(config: WoundConfig(isMultipleOutlinesEnabled: true,
                                       autoDetectionMode: self.autoDetectionMode))
        
        let config = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                  outlineScreenTitle: "Outline",
                                                  outlineScreenSubtitle: nil,
                                                  summaryScreenTitle: L.str("RESULT_TITLE"),
                                                  summaryScreenSubtitle: nil,
                                                  resultsScreenTitle: L.str("WOUND_SIZE"),
                                                  resultsScreenSubtitle: nil,
                                                  woundStomaConfig: woundStomaConfig)
        
        imNavController = IMNavigationController(image: image,
                                                 resultScreenBottomView: nil,
                                                 sideSize: sideSize,
                                                 linePoints: linePoints,
                                                 navConfig: config,
                                                 config: self,
                                                 willPresentResults: {
            
        }, completion: { [weak self] measureResult in
            guard let `self` = self else { return }
            /*
             Switch to some other mode.
             For example if you need one measurement and multiple photos to be captured.
             */
            captureVC.switchTo(mode: .photo)
            
            /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of PhotoCaptureResult */
            if let pathURL = ImitoCameraFileManager.documentPathForExistingFile(captureResult.photoNameExt) {
                do {
                    try FileManager.default.removeItem(atPath: pathURL.path)
                } catch {
                    print("Failed to remove \(error)")
                }
            }
            
            self.capturedItemsToReturn.append(measureResult)
                        
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [Any]()
            }
        }, bottomViewCompletion: { _ in })
        
        DispatchQueue.main.async {
            guard let imNavController = imNavController else { return }
            imNavController.modalPresentationStyle = .fullScreen // Use full screen, as there is some logic in viewDidAppear.
            captureVC.present(imNavController, animated: false, completion: nil)
        }
    }
    
    func showOutlining(captureVC: IMCaptureViewController, captureResult: MeasurementCaptureResult) {
        if captureResult.photo != nil && captureResult.codeDetection.codeSizeMM() != 0 {
            var imNavController: IMNavigationController?
            
            let woundStomaConfig: WoundStomaConfig = .wound(config: WoundConfig(isMultipleOutlinesEnabled: true,
                                                                                autoDetectionMode: self.autoDetectionMode))

            let config = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                      outlineScreenTitle: "Patient Name",
                                                      outlineScreenSubtitle: "10.12.2000, P1234",
                                                      summaryScreenTitle: L.str("RESULT_TITLE"),
                                                      summaryScreenSubtitle: nil,
                                                      resultsScreenTitle: L.str("WOUND_SIZE"),
                                                      resultsScreenSubtitle: nil,
                                                      woundStomaConfig: woundStomaConfig)
            
            imNavController = IMNavigationController(image: captureResult.photo!,
                                                     qrSideSize: CGFloat(captureResult.codeDetection.codeSizeMM()), resultScreenBottomView: nil,
                                                     markerPointsPercentage: captureResult.codeDetection.pointsPercentage, 
                                                     navConfig: config,
                                                     config: self,
                                                     willPresentResults: {
                
            }, completion: { [weak self] measureResult in
                guard let `self` = self else { return }
                
                /*
                 Switch to some other mode.
                 For example if you need one measurement and multiple photos to be captured.
                 */
                captureVC.switchTo(mode: .photo)
                
                /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of MeasurementCaptureResult */
                if let pathURL = ImitoCameraFileManager.documentPathForExistingFile(captureResult.photoNameExt) {
                    do {
                        try FileManager.default.removeItem(atPath: pathURL.path)
                    } catch {
                        print("Failed to remove \(error)")
                    }
                }
                
                self.capturedItemsToReturn.append(measureResult)
                                
                if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                    self.completion?(self.capturedItemsToReturn)
                    self.capturedItemsToReturn = [Any]()
                }
            }, bottomViewCompletion: { _ in
                
            })
            
            imNavController!.modalPresentationStyle = .fullScreen // Use full screen, as there is some logic in viewDidAppear.
            captureVC.present(imNavController!, animated: true, completion: nil)
        } else {
            UIUtils.showOKAlert("Unsupported marker was detected", message: nil)
        }
    }
    
    func showRulerMeasurementScaleDefinition(captureVC: IMCaptureViewController, captureResult: PhotoCaptureResult) {
        guard let image = captureResult.preview else { return }
        
        var pinsViewController: PinsViewController?
        pinsViewController = PinsViewController(image: image, config: self) { [weak self] size, pointViews in
            guard let `self` = self else {return}
            pinsViewController?.dismiss(animated: false, completion: { [weak self] in
                guard let `self` = self else { return }
                self.showOutlining(captureVC: captureVC,
                                   captureResult: captureResult,
                                   pointViews: pointViews,
                                   sideSize: size)
            })
        }
        
        DispatchQueue.main.async {
            guard let pinsViewController = pinsViewController else { return }
            let navigationController = UINavigationController(rootViewController: pinsViewController)
            navigationController.modalPresentationStyle = .fullScreen // Use full screen, as there is some logic in viewDidAppear.
            navigationController.view.backgroundColor = .black
            captureVC.present(navigationController, animated: false, completion: nil)
        }
    }
}
