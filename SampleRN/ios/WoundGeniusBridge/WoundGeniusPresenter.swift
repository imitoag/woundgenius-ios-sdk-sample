//
//  WoundGeniusPresenter.swift
//  SampleRN
//
//  Created by Eugene Naloiko on 07.08.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit
import WoundGenius
import AVFoundation

/**
 The WoundGeniusPresenter, which convigures the WoundGenius framework. For more details on configurable parameters - check the SDK README files.
 */
class WoundGeniusPresenter: NSObject, WGPresenterProtocol {
  
  // Start: Non-protocol properties
  
  // Zxing wrapper to search for markers.
  private let zxWrapper = ZXWrapper()
  
  // Custom completion, which can return the Photo result or Measurement result.
  private var completion: ((PhotoCaptureResult?, MeasurementResult?)->())?
  
  // Init method for the presenter.
  init(completion: @escaping ((PhotoCaptureResult?, MeasurementResult?)->())) {
    
    super.init()
    
    // Activate the WoundGenius with your license key.
    WG.activate(licenseKey: "eyJhbGciOiIxIiwic2lnIjoiR3daOWhQcHJVZ0V0Y1FYVjkrbEtJYWpUOHlaMEVPdGQwYXNWSlRCcUhJRUErQUxxXC9SdHF1TTRyb3VwM1QxblVxVWtLcXZiZE00R1U4V3ZcL3VlV0F5RFdNZ3FQVVZ3TmI2RTVUbG5uQ1VXT1Y1N0lBZEIrS2NpQ09xN2hQSDdySUZsTjh0YXJDVW44VDdocGtodVpZOEk3bGxXUkxNN21aTFcrak0ydExycVwvUXBSTytuenh2endSaXUxNVRvR1VNVWN5Qk9WV09FclZFdU5FQXhIcDRwOUw0WDRHWVMzc3BkUysrM284MHJHYWJqQjRGWnRYZkZjelBpRG80d2MzNDZRUUQ5NjdWemd3WW93d2ozbXN6OCtROFpaUjJFa0haeXZPUHFLZFwvNDVlblM2TVBiOEh1TXpzSHlyellZeUdmYW9jTkpFNkZFK1VXZWo1ZGpFZ0k2b0ZVRW9qUjNtSXhWOWxZQTMzdUY3dVwvZlpVOTI3cnZxWDNZYkVTRXNmaTkzTXc5SFoySURsY29IYXFiU005M0xiTEZIVEVGb1FrMHBOYzNqQTFXQUdGSkVzQ0ZXaU1wQnRubHpmVnZIZXpxZ01wYW9kempsTkVHXC9Vd1ROQ1NIdGNoelkwaWdITHhyMFJES0VUR0pUbkdLS3JETUFhN2pjM2pReTRrVlNHWmlRYTEyUmVzQVNTXC9UQTkwcEszK2VEdlFuS3ozSVdYK3JuTjd0XC9pYzcxVko2NWtvYjFzQzZmTFNGeFFmekQxUkEwNktlc0VaeGdDUFRjK1F1XC9Dek1NTktFdkh6U0Q0VXpKMEtHQktFMUNHMWZXXC9HSHBoZ0JiU1daelR5clZRa3dtT2lSRVJRdWF3Q2kwV2xxV2ZaNWhaRzZtWEd0Nlh0T1BlckVzZm9Ia1JnPSIsImVuYyI6ImV5SnBibU5zZFdSbFpDSTZXM3NpZEhsd1pTSTZJbUZ3Y0d4cFkyRjBhVzl1U1dRaUxDSnBaQ0k2SW1sdkxtbHRhWFJ2TG5kdmRXNWtaMlZ1YVhWekxuSmxZV04wYm1GMGFYWmxJbjBzZXlKMGVYQmxJam9pWm1WaGRIVnlaVWxrSWl3aWFXUWlPaUp3YUc5MGIwTmhjSFIxY21sdVp5SjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2lkbWxrWlc5RFlYQjBkWEpwYm1jaWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNkluSjFiR1Z5VFdWaGMzVnlaVzFsYm5SRFlYQjBkWEpwYm1jaWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNkltMWhjbXRsY2sxbFlYTjFjbVZ0Wlc1MFEyRndkSFZ5YVc1bkluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSm1jbTl1ZEdGc1EyRnRaWEpoSW4wc2V5SjBlWEJsSWpvaVptVmhkSFZ5WlVsa0lpd2lhV1FpT2lKaGNtVmhVMk5oYm01cGJtY3pSQ0o5TEhzaWRIbHdaU0k2SW1abFlYUjFjbVZKWkNJc0ltbGtJam9pYlhWc2RHbHdiR1ZYYjNWdVpITlFaWEpKYldGblpTSjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2lkMjkxYm1SRVpYUmxZM1JwYjI0aWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNklteHBkbVZYYjNWdVpFUmxkR1ZqZEdsdmJpSjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2lZbTlrZVZCaGNuUlFhV05yWlhJaWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNklteHZZMkZzVTNSdmNtRm5aVWx0WVdkbGN5SjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2liRzlqWVd4VGRHOXlZV2RsVm1sa1pXOXpJbjFkTENKdFpYUmhJanA3SW1semMzVmxaQ0k2SWpJd01qVXRNRFF0TVRZZ01qRTZNelE2TURRaUxDSmxlSEJwY25raU9pSXlNREkxTFRBMUxUTXdJREl4T2pNME9qQXdJbjBzSW1SaGRHRWlPbnQ5ZlE9PSJ9") // Till May 31, 2025.
    
    self.completion = completion
  }
  
  // End: Non-protocol Properties
  
  var isEmergencyModeEnabled: Bool = false
  
  var showMarkerMeasurementTutorialAutomatically: Bool = false
  
  var imBlackColor: UIColor = .black
  
  var primaryButtonColor: UIColor = .red
  
  var lightBackgroundColor: UIColor = .lightGray
  
  var completionButtonTitle: WoundGenius.WGLokalizableKey = .DONE
  
  var isSendPrintablePDFHidden: Bool = true
  
  var isResultsBottomBarHidden: Bool = true
  
  var backNavigationBarButtonTitle: String? = "Back"
  
  var isDepthOrHeightInputEnabled: Bool = false
  
  var autoDetectionMode: WoundGenius.AutoDetectionMode = .none
  
  var isLiveWoundDetectionEnabled: Bool = false
  
  var enabledOutlineTypes: [WoundGenius.IMOutlineCluster] = [.wound]
  
  var tfLiteExtension: (WoundGenius.TFLiteExtensionProtocol)? = nil
  
  var userId: String? = nil
  
  var availableModes: [WoundGenius.ImitoCameraMode] = [.photo, .markerMeasurement, .rulerMeasurement]
  
  var defaultMode: WoundGenius.ImitoCameraMode = .markerMeasurement
  
  var tutorialsAvailableForModes: [WoundGenius.ImitoCameraMode] = []
  
  var isBodyPartPickerAvailable: Bool = false
  
  var isAddFromLocalStorageAvailable: Bool = false
  
  var isFrontCameraUsageAllowed: Bool = false
  
  var isFullHDVideoEnabled: Bool = false
  
  var isVideoWithAudioEnabled: Bool = false
  
  var isCancelBarButtonItemVisible: Bool = true
  
  var showTutorialOnViewDidAppear: Bool = false
  
  var minNumberOfMedia: Int = 1
  
  var maxNumberOfMedia: Int = 1
  
  var operatingMode: WoundGenius.OperatingMode = .SDK
  
  func lastMediaIcon(icon: @escaping (UIImage?) -> ()) {
    icon(nil)
  }
  
  var refreshLastMediaIconAndRightBarButtonState: (() -> ())?
  
  func captured(sampleBuffer: CMSampleBuffer, previewOrientation: UIInterfaceOrientation, videoOrientation: AVCaptureVideoOrientation, processingResult: @escaping ((WoundGenius.MarkerDetectionStatus, [CGPoint]?, CGSize?)) -> ()) {
    self.zxWrapper.submitNewSampleBuffer(sampleBuffer: sampleBuffer,
                                         previewOrientation: previewOrientation,
                                         videoOrientation: videoOrientation)
    
    self.zxWrapper.detectionStatus = { status in
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
  
  func handle(event: WoundGenius.WGEvent) {
    switch event {
    case .cancelButtonTapped(let vc):
      vc.dismiss(animated: true)
    case .capturedPhoto(let vc, let result):
      completion?(result, nil)
      vc.dismiss(animated: true)
    case .capturedMarkerMeasurement(let vc, let result):
      self.showOutlining(captureVC: vc, captureResult: result)
    case .capturedRulerMeasurementImage(let vc, let result):
      self.showRulerMeasurementScaleDefinition(captureVC: vc, captureResult: result)
    default:
      break
    }
  }
  
  func lokalize(_ key: String) -> String {
    L.str(key)
  }
  
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
}

extension WoundGeniusPresenter {
  
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
    
    let woundStomaConfig: WoundStomaConfig = WoundStomaConfig.wound(config: WoundConfig(isMultipleOutlinesEnabled: true,
                                                                                        autoDetectionMode: self.autoDetectionMode))
    
    let navConfig = IMNavigationControllerConfig(showActivityIndicatorOnCompletion: false,
                                                 outlineScreenTitle: "Outline",
                                                 outlineScreenSubtitle: nil,
                                                 summaryScreenTitle: L.str("RESULT_TITLE"),
                                                 summaryScreenSubtitle: nil,
                                                 resultsScreenTitle: L.str("WOUND_SIZE"),
                                                 resultsScreenSubtitle: nil,
                                                 woundStomaConfig: woundStomaConfig)
    
    imNavController = IMNavigationController(image: image,
                                             mediaManager: ImitoMeasureMediaManager(),
                                             sideSize: sideSize,
                                             resultScreenBottomView: nil,
                                             linePoints: linePoints,
                                             navConfig: navConfig,
                                             config: self,
                                             willPresentResults: {
      
    }, completion: { [weak self] measureResult in
      guard let `self` = self else { return }
      /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of PhotoCaptureResult */
      if let pathURL = ImitoCameraFileManager.documentPathForExistingFile(captureResult.photoNameExt) {
        do {
          try FileManager.default.removeItem(atPath: pathURL.path)
        } catch {
          print("Failed to remove \(error)")
        }
      }
      
      completion?(nil, measureResult)
      captureVC.dismiss(animated: true)
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
      
      let woundStomaConfig: WoundStomaConfig =
        .wound(config: WoundConfig(isMultipleOutlinesEnabled: true,
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
                                               mediaManager: ImitoMeasureMediaManager(),
                                               qrSideSize: CGFloat(captureResult.codeDetection.codeSizeMM()), resultScreenBottomView: nil,
                                               markerPointsPercentage: captureResult.codeDetection.pointsPercentage,
                                               navConfig: config,
                                               config: self,
                                               willPresentResults: {
        
      }, completion: { [weak self] measureResult in
        guard let `self` = self else { return }
        
        /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of MeasurementCaptureResult */
        if let pathURL = ImitoCameraFileManager.documentPathForExistingFile(captureResult.photoNameExt) {
          do {
            try FileManager.default.removeItem(atPath: pathURL.path)
          } catch {
            print("Failed to remove \(error)")
          }
        }
        
        completion?(nil, measureResult)
        captureVC.dismiss(animated: true)
      }, bottomViewCompletion: { _ in
        
      })
      
      imNavController!.modalPresentationStyle = .fullScreen // Use full screen, as there is some logic in viewDidAppear.
      captureVC.present(imNavController!, animated: true, completion: nil)
    } else {
      UIUtils.showOKAlert("Unsupported marker was detected", message: nil)
    }
  }
}
