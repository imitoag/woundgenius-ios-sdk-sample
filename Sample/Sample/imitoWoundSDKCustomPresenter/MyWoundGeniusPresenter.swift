//
//  MyWoundGeniusPresenter.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit
import CoreMedia
import AVFoundation
import WoundGenius

class MyWoundGeniusPresenter: MyWoundGeniusLokalizable, WGPresenterProtocol {
    var rulerScaleAutoDetectionEnabled: Bool = false
    
    var isSingleAreaModeEnabled: Bool {
        return UserDefaults.standard.bool(forKey: SettingKey.isSingleAreaModeEnabled.rawValue)
    }
        
    var isEmergencyModeEnabled: Bool = false
    
    var userId: String? = "user5"
    
    var showMarkerMeasurementTutorialAutomatically: Bool = true
    
    var backNavigationBarButtonTitle: String?
    
    // MARK: - WoundGeniusPresenterProtocol
    var isRightNavBarButtonAvailable: Bool = true
    
    var availableModes: [ImitoCameraMode] {
        var modes = [ImitoCameraMode]()
        if UserDefaults.standard.bool(forKey: SettingKey.videoModeEnabled.rawValue) {
            modes.append(.video)
        }
        if UserDefaults.standard.bool(forKey: SettingKey.markerModeEnabled.rawValue) {
            modes.append(.markerMeasurement)
        }
        if UserDefaults.standard.bool(forKey: SettingKey.photoModeEnabled.rawValue) {
            modes.append(.photo)
        }
        if UserDefaults.standard.bool(forKey: SettingKey.rulerModeEnabled.rawValue) {
            modes.append(.rulerMeasurement)
        }
        
        return modes
    }
    
    var isVideoWithAudioEnabled: Bool = true
    
    var defaultMode: ImitoCameraMode {
        if self.availableModes.contains(.markerMeasurement) {
            return .markerMeasurement
        } else {
            return self.availableModes.first ?? .markerMeasurement
        }
    }
    
    var tutorialsAvailableForModes: [ImitoCameraMode] = [.markerMeasurement, .rulerMeasurement]
    
    var isBodyPartPickerAvailable: Bool {
        return UserDefaults.standard.bool(forKey: SettingKey.bodyPartPickerOnCapturingEnabled.rawValue)
    }
    
    var isAddFromLocalStorageAvailable: Bool {
        return UserDefaults.standard.bool(forKey: SettingKey.localStorageMediaEnabled.rawValue)
    }
    
    var isFrontCameraUsageAllowed: Bool {
        return UserDefaults.standard.bool(forKey: SettingKey.frontalCameraEnabled.rawValue)
    }
    
    var isFullHDVideoEnabled: Bool = false
    
    var isCancelBarButtonItemVisible: Bool = true
    
    var refreshLastMediaIconAndRightBarButtonState: (() -> ())?
    
    func lastMediaIcon(icon: @escaping (UIImage?) -> ()) {
        guard let lastMedia = self.capturedItemsToReturn.last else {
            icon(nil)
            return
        }
        switch lastMedia {
        case .video(let video):
            icon(video.preview)
        case .image(let image):
            icon(image.image)
        case .photo(let photo):
            icon(photo.preview)
        case .measurement(let measurement):
            icon(measurement.image)
        }
    }
    
    private var selectedBodyParts: [String]?
    
    var autoDetectionMode: AutoDetectionMode {
        if UserDefaults.standard.bool(forKey: SettingKey.tissueTypesDetection.rawValue) && UserDefaults.standard.bool(forKey: SettingKey.woundDetection.rawValue) {
            return .woundAndTissueTypes
        } else if UserDefaults.standard.bool(forKey: SettingKey.woundDetection.rawValue) {
            return .woundOnly
        } else {
            return .none
        }
    }
    
    var isLiveWoundDetectionEnabled: Bool {
        guard UserDefaults.standard.bool(forKey: SettingKey.stomaCapturing.rawValue) != true else { return false }
        
        return UserDefaults.standard.bool(forKey: SettingKey.liveWoundDetection.rawValue)
    }
        
    var enabledOutlineTypes: [WoundGenius.IMOutlineCluster] {
        var enabledTypes = [WoundGenius.IMOutlineCluster]()
        
        if UserDefaults.standard.bool(forKey: SettingKey.stomaCapturing.rawValue) {
            enabledTypes.append(.stoma)
        } else {
            switch self.autoDetectionMode {
            case .none, .woundOnly:
                enabledTypes.append(.wound)
            case .woundAndTissueTypes:
                enabledTypes.append(contentsOf: [.wound,
                                                 .granulation,
                                                 .necrosis,
                                                 .slough,
                                                 .fibrin,
                                                 .boneAndTendon,
                                                 .fascia,
                                                 .fat,
                                                 .dressing,
                                                 .skinGraft])
                
            @unknown default:
                enabledTypes.append(.wound)
            }
        }
        
        // Add Lines Measurement, if enabled
        if UserDefaults.standard.bool(forKey: SettingKey.localStorageLineMeasurementEnabled.rawValue) {
            enabledTypes.append(.line)
        }
        
        return enabledTypes
    }
    
    let sizeForPopoverController = CGSize(width: 375, height: 580)
    let topPaddingForPopoverController: CGFloat = 10
    
    func captured(sampleBuffer: CMSampleBuffer,
                  previewOrientation: UIInterfaceOrientation,
                  videoOrientation: AVCaptureVideoOrientation,
                  processingResult: @escaping ((MarkerDetectionStatus, [CGPoint]?, CGSize?)) -> ()) {
        
    }
    
    func handle(event: WGEvent) {
        switch event {
        case .stoppedCapturingVideoBecauseOfDurationLimit, .capturedHandyscopePhoto, .capturedManualInputPhoto:
            assertionFailure("Unexpected use of this version of WoundGenius.")
            break
        case .capturedVideo(_, let videoCaptureResult),
                .pickedVideo(_, let videoCaptureResult):
            capturedItemsToReturn.append(.video(videoCaptureResult))
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [CaptureResult]()
            }
        case .capturedPhoto(let vc, let photoResult):
            print("The IMCaptureViewController: \(vc), the photoResult: \(photoResult)")
            capturedItemsToReturn.append(.photo(photoResult))
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [CaptureResult]()
            }
        case .capturedMarkerMeasurement(let vc, let result):
            self.showOutlining(captureVC: vc, captureResult: result)
        case .capturedRulerMeasurementImage(vc: let vc, let result):
            self.presentMeasurementFlow(overCaptureVC: vc, captureResult: result, pointViews: nil, sideSize: nil)
        case .cancelButtonTapped(vc: let vc):
            if self.capturedItemsToReturn.count > 0 {
                UIUtils.showConfirmationAlert(title: L.str("CONFIRM_CANCEL_CAPTURING"), message: nil, confirmButton: L.str("CONFIRM"), cancelButton: L.str("DISMISS_BUTTON")) {
                    self.capturedItemsToReturn = [CaptureResult]()
                    vc.dismiss(animated: true)
                }
            } else {
                vc.dismiss(animated: true)
            }
        case .rightBarButtonTapped(vc: let vc):
            print("case .rightBarButtonTapped")
            self.completion?(self.capturedItemsToReturn)
            vc.dismiss(animated: true) { [weak self] in
                self?.capturedItemsToReturn = [CaptureResult]()
            }
        case .pickedPhoto(vc: let vc, result: let photoResult, let markerDetector):
            print("The IMCaptureViewController: \(vc), the photoResult: \(photoResult)")
            // Search for imito marker on the image. If it will be detected - start measurement.
            func addPickedPhoto() {
                self.capturedItemsToReturn.append(.photo(photoResult))
                if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                    self.completion?(self.capturedItemsToReturn)
                    self.capturedItemsToReturn = [CaptureResult]()
                }
                self.refreshLastMediaIconAndRightBarButtonState?()
            }
            switch vc.currentMode {
            case .markerMeasurement, .rulerMeasurement:
                markerDetector.searchMarker(image: photoResult.preview) { result in
                    switch result {
                    case .detected(let pointsPercentage, _):
                        DispatchQueue.main.async {
                            // Start Marker Measurement Flow, as the marker was detected.
                            let captureResultNew = MeasurementCaptureResult(photoName: photoResult.photoName,
                                                                            photo: photoResult.preview,
                                                                            codeDetection: CodeDetectionResult(code: "10mm",
                                                                                                               fromQRCode: false,
                                                                                                               pointsPercentage: pointsPercentage))
                            self.showOutlining(captureVC: vc, captureResult: captureResultNew)
                        }
                    case .detectedWrongTilt, .detectedCompletelyWrongTilt, .stoppedDetecting, .notDetected:
                        DispatchQueue.main.async {
                            // Starting the Ruler Measurement. As there is no marker in the image. You can adjust it to required behaviour.
                            self.presentMeasurementFlow(overCaptureVC: vc, captureResult: photoResult, pointViews: nil, sideSize: nil)
                        }
                    }
                }
            default:
                addPickedPhoto()
            }
        case .helpButtonClicked(let over, let mode, let sourceView, let isTopViewTapped):
            /*
             CALIBRATION_MARKER_HELP_JSON
             CALIBRATION_MARKER_HOW_TO_USE_HTML
             CALIBRATION_MARKER_HOW_TO_GET_MARKERS_HTML
             CALIBRATION_MARKER_HOW_WOUND_SIZE_CALCULATED_HTML
             
             RULER_HELP_JSON
             RULER_HOW_TO_USE_HTML
             RULER_HOW_WOUND_SIZE_CALCULATED_HTML
             */
            
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
                    vc = WebViewTutorialScreen(title: L.str("CALIBRATION_MARKER"), data: tutorialData, videoName: (self.autoDetectionMode == .none) ? TutorialVideoName.manualTracing.rawValue : TutorialVideoName.autocapture.rawValue, videoExtension: "mp4", config: self)
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
                return
            }
            if UIDevice.current.isPad {
                vc.modalPresentationStyle = .popover
                vc.preferredContentSize = self.sizeForPopoverController
                
                let topPaddingForPopoverController = isTopViewTapped ? self.topPaddingForPopoverController : -self.topPaddingForPopoverController
                
                if let popoverController = vc.popoverPresentationController {
                    popoverController.delegate = over
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = CGRect(origin: CGPoint(x: sourceView.bounds.origin.x,
                                                                          y: sourceView.bounds.origin.y + topPaddingForPopoverController),
                                                          size: sourceView.bounds.size)
                    popoverController.permittedArrowDirections = isTopViewTapped ? .up : .down
                }
                over.present(vc, animated: true)
            } else {
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen // Full screen is needed. Otherwise the AVPlayerViewController is hanging on dismissal.
                over.present(navVC, animated: true)
            }
        case .viewWillAppear:
            break
        case .viewWillDisappear:
            break
        case .launchBodyPartPickerClicked(let over):
            guard UserDefaults.standard.bool(forKey: SettingKey.bodyPartPickerOnCapturingEnabled.rawValue) else { return }
            
            self.router?.startBodyPartPickerV2(over: over, preselect: self.selectedBodyParts, languageISO2Alpha: L.str("LANGUAGE_CODE"), gender: nil, language: BPPickerLanguage(rawValue: L.str("LANGUAGE_CODE")) ?? BPPickerLanguage.en, completion: { [weak self] newSelectedBodyParts in
                self?.selectedBodyParts = newSelectedBodyParts
            })
        case .woundAutoDetectionExecuted(let numberOfWoundOutlines):
            print("Log woundAutoDetectionExecuted for statistics. \(numberOfWoundOutlines) wound outines detected. No actions needed.")
        case .autoDetectButtonClicked:
            print("Log autoDetectButtonClicked event for statistics. No actions needed.")
        case .autoDetectResultsEdited:
            print("Log autoDetectResultsEdited event for statistics. No actions needed.")
        case .devLogs(_):
            break
        @unknown default:
#if DEBUG
            assertionFailure()
#endif
        }
    }
    
    var minNumberOfMedia: Int {
        return UserDefaults.standard.integer(forKey: SettingKey.minNumberOfMediaInt.rawValue)
    }
    
    var maxNumberOfMedia: Int {
        return UserDefaults.standard.integer(forKey: SettingKey.maxNumberOfMediaInt.rawValue)
    }
    
    var headerTextColorUIUtils: UIColor = UIColor.black
    
    var customBlackColorUIUtils: UIColor = UIColor.black
    
    var customRedColorUIUtils: UIColor = UIColor.red
    
    var operatingMode: OperatingMode = .SDK
    
    /* imitoMeasureConfigurations */
    var isSendPrintablePDFHidden: Bool = true
    
    var primaryButtonColor: UIColor {
        switch UserDefaults.standard.integer(forKey: SettingKey.primaryButtonColor.rawValue) {
        case 1:
            return .blue
        case 2:
            return .green
        default:
            return UIColor(red: 226/255.0, green: 53/255.0, blue: 42/255.0, alpha: 1.0)
        }
    }
    
    var lightBackgroundColor: UIColor {
        switch UserDefaults.standard.integer(forKey: SettingKey.lightBackgroundColor.rawValue) {
        case 1:
            return .lightGray
        case 2:
            return .yellow
        default:
            return .white
        }
    }
    
    var imBlackColor: UIColor {
        return UIColor.black
    }
    
    var completionButtonTitle: WGLokalizableKey {
        return .CONTINUE_BUTTON
    }
    
    var isResultsBottomBarHidden: Bool = true
    
    var isDepthOrHeightInputEnabled: Bool = true
    
    /**
     - Avoid creation of WoundGeniusTFLiteExtension object multiple times. This way it will be created once.
     - Disable TFLiteFlow for Simulator, as Google built TensorFlowLiteTaskVision runnable on real devices only.
     */
    private lazy var tfLiteExtensionLocal: WoundGenius.TFLiteExtensionProtocol? = {
#if targetEnvironment(simulator)
        return nil
#else
        return WoundGeniusTFLiteExtension.shared
#endif
    }()
    
    /// If nil is provided - MLModels will be used. Integrate WoundGeniusTFLiteExtension and install the TensorFlowLiteTaskVision pod to use the TFLite models.
    var tfLiteExtension: WoundGenius.TFLiteExtensionProtocol? {
        return self.tfLiteExtensionLocal
    }
    
    // MARK: - Non-Protocol. Custom Methods
    private var capturedItemsToReturn = [CaptureResult]()
    private var completion: (([CaptureResult]) -> Void)!
    internal weak var router: WGRouter?
    
    init(completion: @escaping (([CaptureResult]) -> Void)) {
        super.init()
        self.completion = completion
    }
}

extension MyWoundGeniusPresenter {
    
    /**
     The IMNavigationController - will handle the case when scale is not defined - and will initialize the Navigation Flow with Scale Definitiion View Controller, and Outlining after the scale is defined.
     */
    func presentMeasurementFlow(overCaptureVC: IMCaptureViewController,
                                captureResult: PhotoCaptureResult,
                                pointViews: [AMPointView2]?,
                                sideSize: CGFloat?) {
        
        guard let image = captureResult.preview else { return }
        
        var linePoints: [CGPoint]?
        if let pointViews = pointViews, let point1 = pointViews.first?.center, let point2 = pointViews.last?.center {
            if point1.x > point2.x {
                linePoints = [point2, point1]
            } else {
                linePoints = [point1, point2]
            }
        }
        
        var imNavController: IMNavigationController?
        
        let woundStomaConfig: WoundStomaConfig = UserDefaults.standard.bool(forKey: SettingKey.stomaCapturing.rawValue) ?
            .stoma :
            .wound(config: WoundConfig(
                isMultipleOutlinesEnabled: UserDefaults.standard.bool(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue) && !isSingleAreaModeEnabled,
                autoDetectionMode: self.autoDetectionMode)
            )
        let navConfig = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                     outlineScreenTitle: L.str("OUTLINE"),
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
                                                 navConfig: navConfig,
                                                 config: self,
                                                 willPresentResults: {
            
        }, completion: { [weak self] measureResult in
            guard let `self` = self else { return }
            /*
             Switch to some other mode.
             For example if you need one measurement and multiple photos to be captured.
             */
            if UserDefaults.standard.bool(forKey: SettingKey.photoModeEnabled.rawValue) {
                overCaptureVC.switchTo(mode: .photo)
            }
            
            /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of PhotoCaptureResult */
            captureResult.deleteRelatedFiles()
            
            self.capturedItemsToReturn.append(.measurement(measureResult))
            
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [CaptureResult]()
            }
        }, bottomViewCompletion: { _ in
            
        })
        
        DispatchQueue.main.async {
            guard let imNavController = imNavController else { return }
            imNavController.modalPresentationStyle = .fullScreen // Use full screen, as there is some logic in viewDidAppear.
            overCaptureVC.present(imNavController, animated: false, completion: nil)
        }
    }
    
    func showOutlining(captureVC: IMCaptureViewController, captureResult: MeasurementCaptureResult) {
        if captureResult.photo != nil && captureResult.codeDetection.codeSizeMM() != 0 {
            var imNavController: IMNavigationController?
            
            let woundStomaConfig: WoundStomaConfig = UserDefaults.standard.bool(forKey: SettingKey.stomaCapturing.rawValue) ?
                .stoma :
                .wound(config: WoundConfig(
                    isMultipleOutlinesEnabled: UserDefaults.standard.bool(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue) && !isSingleAreaModeEnabled,
                    autoDetectionMode: self.autoDetectionMode)
                )
            
            let navConfig = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                         outlineScreenTitle: self.autoDetectionMode != .none ? L.str("REVIEW_OUTLINES") : L.str("OUTLINE"),
                                                         outlineScreenSubtitle: nil,
                                                         summaryScreenTitle: L.str("RESULT_TITLE"),
                                                         summaryScreenSubtitle: nil,
                                                         resultsScreenTitle: L.str("WOUND_SIZE"),
                                                         resultsScreenSubtitle: nil,
                                                         woundStomaConfig: woundStomaConfig)
            print("NavigationController state: \(imNavController)")
            print("Current view controller: \(self)")
            
            imNavController = IMNavigationController(image: captureResult.photo!,
                                                     qrSideSize: CGFloat(captureResult.codeDetection.codeSizeMM()),
                                                     resultScreenBottomView: nil,
                                                     markerPointsPercentage: captureResult.codeDetection.pointsPercentage,
                                                     navConfig: navConfig,
                                                     config: self,
                                                     willPresentResults: {
                
            }, completion: { [weak self] measurementResult in
                guard let `self` = self else { return }
                
                /*
                 Switch to some other mode.
                 For example if you need one measurement and multiple photos to be captured.
                 */
                if UserDefaults.standard.bool(forKey: SettingKey.photoModeEnabled.rawValue) {
                    captureVC.switchTo(mode: .photo)
                }
                
                /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of MeasurementCaptureResult */
                captureResult.deleteRelatedFiles()
                
                self.capturedItemsToReturn.append(.measurement(measurementResult))
                
                if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                    self.completion?(self.capturedItemsToReturn)
                    self.capturedItemsToReturn = [CaptureResult]()
                }
            }, bottomViewCompletion: { _ in
                
            })
            
            imNavController!.modalPresentationStyle = .fullScreen // Use full screen, as there is some logic in viewDidAppear.
            captureVC.present(imNavController!, animated: true, completion: nil)
        } else {
            UIUtils.showOKAlert("Unsupported marker was detected", message: nil)
        }
    }
}
