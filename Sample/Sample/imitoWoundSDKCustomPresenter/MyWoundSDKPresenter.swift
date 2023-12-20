//
//  MyWoundSDKPresenter.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit
import CoreMedia
import AVFoundation
import WoundGenius

class MyWoundSDKPresenter: NSObject, WoundGeniusPresenterProtocol {
    
    var showTutorialOnViewDidAppear: Bool = false
    
    var backNavigationBarButtonTitle: String?
    
    // MARK: - BodyPartPickerSettings
    func lokalise(key: BodyPartPickerLocalizationKeys) -> String {
        switch key {
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
        @unknown default:
            return "Unknown default"
        }
    }
    
    // MARK: - WoundSDKPresenterProtocol
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
    
    func lastImage(icon: @escaping (UIImage?) -> ()) {
        icon(nil)
    }
    
    private var bodyPartPickerResult: BodyPartPickerResult?
    
    var autoDetectionMode: AutoDetectionMode {
        switch UserDefaults.standard.integer(forKey: SettingKey.autoDetectionType.rawValue) {
        case 1:
            return .woundOnly
        case 2:
            return .woundAndTissueTypes
        default:
            return .none
        }
    }
    
    var enabledOutlineTypes: [WoundGenius.IMOutlineCluster] {
        switch self.autoDetectionMode {
        case .none, .woundOnly:
            return [.wound]
        case .woundAndTissueTypes:
            return [.wound,
                    .granulation,
                    .necrosis,
                    .slough,
                    .fibrin,
                    .boneAndTendon,
                    .fascia,
                    .fat,
                    .dressing,
                    .skinGraft]
        @unknown default:
            return [.wound]
        }
    }
    
    func captured(sampleBuffer: CMSampleBuffer, previewOrientation: UIInterfaceOrientation, videoOrientation: AVCaptureVideoOrientation, processingResult: @escaping ((MarkerDetectionStatus, [CGPoint]?, CGSize?)?) -> ()) {
        ZXWrapper.shared.submitNewSampleBuffer(sampleBuffer: sampleBuffer,
                                               previewOrientation: previewOrientation,
                                               videoOrientation: videoOrientation)
        
        ZXWrapper.shared.detectionStatus = { status in
            DispatchQueue.main.async {
                switch status {
                case .detected(let pointsInPrecentage, let frameSize):
                    processingResult((.detectedImitoMarkerTiltOk, pointsInPrecentage, frameSize))
                case .detectedWrongTilt(let pointsInPrecentage, let frameSize):
                    processingResult((.detectedImitoMerkerTiltNotOk, pointsInPrecentage, frameSize))
                case .stoppedDetecting, .notDetected, .detectedCompletelyWrongTilt:
                    processingResult((.searching, nil, nil))
                @unknown default:
                    assertionFailure("Unknown default")
                }
            }
        }
    }
    
    func informAbout(event: IMCaptureVCPresenterInforming) {
        switch event {
        case .stoppedCapturingVideoBecauseOfDurationLimit, .capturedHandyscopePhoto, .capturedManualInputPhoto:
            assertionFailure("Unexpected use of this version of WoundSDK.")
            break
        case .capturedVideo(_, let videoCaptureResult),
                .pickedVideo(_, let videoCaptureResult):
            capturedItemsToReturn.append(videoCaptureResult)
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [Any]()
            }
        case .capturedPhoto(let vc, let photoResult):
            print("The IMCaptureViewController: \(vc), the photoResult: \(photoResult)")
            capturedItemsToReturn.append(photoResult)
            if self.maxNumberOfMedia == self.capturedItemsToReturn.count {
                self.completion?(self.capturedItemsToReturn)
                self.capturedItemsToReturn = [Any]()
            }
        case .capturedMarkerMeasurement(let vc, let result):
            showOutlining(captureVC: vc, captureResult: result)
        case .capturedRulerMeasurementImage(vc: let vc, let result):
            showRulerMeasurementScaleDefinition(captureVC: vc, captureResult: result)
        case .cancelButtonTapped(vc: let vc):
            UIUtils.shared.showConfirmationAlert(title: "Confirmation Popup", message: "Are you sure you want to cancel capturing?", confirmButton: "Cancel", cancelButton: "Dismiss") {
                vc.dismiss(animated: true)
            }
        case .rightBarButtonTapped(vc: let vc):
            print("case .rightBarButtonTapped")
            self.completion?(self.capturedItemsToReturn)
            vc.dismiss(animated: true) { [weak self] in
                self?.capturedItemsToReturn = [Any]()
            }
        case .pickedPhoto(vc: let vc, result: let photoResult):
            print("The IMCaptureViewController: \(vc), the photoResult: \(photoResult)")
            // Search for imito marker on the image. If it will be detected - start measurement.
            switch vc.currentMode {
            case .markerMeasurement, .rulerMeasurement:
                ZXWrapper.shared.searchMarker(image: photoResult.preview) { [weak self] status in
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
        case .helpButtonClicked(over: let over, mode: let mode):
            var vc = UIViewController()
            switch mode {
            case .markerMeasurement:
                vc = showManualTutorialScreenViewController(type: .calibrationMarker, tutorialVideoName: "marker-mode-tutorial", videoExtension: "mp4")
            case .rulerMeasurement:
                vc = showManualTutorialScreenViewController(type: .rulerMode, tutorialVideoName: "ruler-mode-tutorial", videoExtension: "mp4")
            case .handyscope, .photo, .video, .scanner, .manualInput:
                assertionFailure("Not supported")
            @unknown default:
                assertionFailure("Unknown default")
            }
            let navVC = UINavigationController(rootViewController: vc)
            over.present(navVC, animated: true)
        case .viewWillAppear(let vc):
            if UserDefaults.standard.bool(forKey: SettingKey.bodyPartPickerOnCapturingEnabled.rawValue) {
                guard let image = BodyPartPickerViewController.imageFor(id: "0", frontBack: BPPFrontBack.front, leftRight: BPPLeftRight.undefined) else { return }
                vc.updateBodyPartPickerButton(image: image)
            }
        case .viewWillDisappear:
            break
        case .launchBodyPartPickerClicked(let over):
            guard UserDefaults.standard.bool(forKey: SettingKey.bodyPartPickerOnCapturingEnabled.rawValue) else { return }
            ImitoBodyPartPickerSettings.shared.language = BPPickerLanguage(rawValue: L.str("LANGUAGE_CODE")) ?? BPPickerLanguage.en
            
            let bodyPartPickerVC = BodyPartPickerViewController(preselect: self.bodyPartPickerResult) { [weak self] bodyPart in
                guard let sSelf = self else { return }
                guard let bodyPart = bodyPart, let _ = bodyPart.htGroupId, let _ = bodyPart.hashtag_en, let _ = bodyPart.hashtag_de, let _ = bodyPart.hashtag_fr else {
                    sSelf.bodyPartPickerResult = nil
                    return
                }
                sSelf.bodyPartPickerResult = bodyPart
                guard let image = BodyPartPickerViewController.imageFor(id: bodyPart.id,
                                                                        frontBack: bodyPart.frontBack,
                                                                        leftRight: bodyPart.leftRight) else { return }
                over.updateBodyPartPickerButton(image: image)
            }
            over.present(bodyPartPickerVC, animated: true, completion: nil)
        @unknown default:
#if DEBUG
            assertionFailure()
#endif
        }
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
    
    func lokalise(key: CameraLokalizationKey) -> String? {
        switch key {
        case .captureScreenTitle:
            return "Patient Name"
        case .captureScreenSubtitle:
            return "Patient Date of Birth"
        default:
            return L.str(key.rawValue)
        }
    }
    
    var localizeUIUtils: (LocalizeKeyUIUtils) -> (String) = { key in
        return L.str(key.rawValue)
    }
    
    func localise(key: IMLocalisation) -> String? {
        switch key {
        case .pinsScreenTitle:
            return nil
        default:
            return L.str(key.rawValue)
        }
    }
    
    var completionButtonTitle: IMLocalisation {
        return .CONTINUE_BUTTON
    }
    
    var isResultsBottomBarHidden: Bool = true
    
    var isDepthInputEnabled: Bool = true
    
    // MARK: - Non-Protocol. Custom Methods
    private var capturedItemsToReturn = [Any]()
    private var completion: (([Any])->())!
    init(completion: @escaping (([Any])->())) {
        super.init()
        self.completion = completion
    }
}

extension MyWoundSDKPresenter {
    func showRulerMeasurementScaleDefinition(captureVC: IMCaptureViewController, captureResult: PhotoCaptureResult) {
        guard let image = captureResult.preview else { return }
        
        var imManualModeNavigationViewController: PinsViewController?
        imManualModeNavigationViewController = PinsViewController(image: image) { [weak self] size, pointViews in
            guard let `self` = self else {return}
            imManualModeNavigationViewController?.dismiss(animated: false, completion: { [weak self] in
                guard let `self` = self else { return }
                self.showOutlining(captureVC: captureVC,
                                   captureResult: captureResult,
                                   pointViews: pointViews,
                                   sideSize: size)
            })
        }
        
        DispatchQueue.main.async {
            guard let imManualModeViewController = imManualModeNavigationViewController else { return }
            let imManualModeNavigationViewController = UINavigationController(rootViewController: imManualModeViewController)
            imManualModeNavigationViewController.modalPresentationStyle = .overFullScreen
            captureVC.present(imManualModeNavigationViewController, animated: false, completion: nil)
        }
    }
    
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
        
        let config = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                  outlineScreenTitle: "Outline",
                                                  outlineScreenSubtitle: nil,
                                                  summaryScreenTitle: L.str("RESULT_TITLE"),
                                                  summaryScreenSubtitle: nil,
                                                  resultsScreenTitle: L.str("WOUND_SIZE"),
                                                  resultsScreenSubtitle: nil,
                                                  isStoma: false,
                                                  isMultipleOutlinesEnabled: UserDefaults.standard.bool(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue),
                                                  autoDetectionMode: self.autoDetectionMode)
        
        imNavController = IMNavigationController(image: image,
                                                 mediaManager: ImitoMeasureMediaManager(),
                                                 sideSize: sideSize,
                                                 resultScreenBottomView: nil,
                                                 linePoints: linePoints,
                                                 config: config,
                                                 willPresentResults: {
            
        }, completion: { [weak self] measureResult in
            guard let `self` = self else { return }
            /*
             Switch to some other mode.
             For example if you need one measurement and multiple photos to be captured.
             */
            if UserDefaults.standard.bool(forKey: SettingKey.photoModeEnabled.rawValue) {
                captureVC.switchTo(mode: .photo)
            }
            
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
            imNavController.modalPresentationStyle = .overFullScreen//.fullScreen
            captureVC.present(imNavController, animated: false, completion: nil)
        }
    }
    
    func showOutlining(captureVC: IMCaptureViewController, captureResult: MeasurementCaptureResult) {
        if captureResult.photo != nil && captureResult.codeDetection.codeSizeMM() != 0 {
            var imNavController: IMNavigationController?
            
            let config = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                      outlineScreenTitle: "Patient Name",
                                                      outlineScreenSubtitle: "10.12.2000, P1234",
                                                      summaryScreenTitle: L.str("RESULT_TITLE"),
                                                      summaryScreenSubtitle: nil,
                                                      resultsScreenTitle: L.str("WOUND_SIZE"),
                                                      resultsScreenSubtitle: nil,
                                                      isStoma: false,
                                                      isMultipleOutlinesEnabled: UserDefaults.standard.bool(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue),
                                                      autoDetectionMode: self.autoDetectionMode)
            
            imNavController = IMNavigationController(image: captureResult.photo!,
                                                     mediaManager: ImitoMeasureMediaManager(),
                                                     qrSideSize: CGFloat(captureResult.codeDetection.codeSizeMM()), resultScreenBottomView: nil,
                                                     markerPointsPercentage: captureResult.codeDetection.pointsPercentage,
                                                     config: config,
                                                     willPresentResults: {
                
            }, completion: { [weak self] measureResult in
                guard let `self` = self else { return }
                
                /*
                 Switch to some other mode.
                 For example if you need one measurement and multiple photos to be captured.
                 */
                if UserDefaults.standard.bool(forKey: SettingKey.photoModeEnabled.rawValue) {
                    captureVC.switchTo(mode: .photo)
                }
                
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
            
            imNavController!.modalPresentationStyle = .fullScreen
            captureVC.present(imNavController!, animated: true, completion: nil)
        } else {
            UIUtils.shared.showOKAlert("Unsupported marker was detected", message: nil)
        }
    }
}

extension MyWoundSDKPresenter {
    
    /*
     Log the events to Firebase, if needed to aggregate some WoundSDK usage statistics.
     Leave empty if the events are not needed.
     */
    func log(event: WoundGenius.WoundSDKLogEvent) {
        print(event)
    }
}
