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
    WG.activate(licenseKey: "eyJhbGciOiIxIiwiZW5jIjoiZXlKcGJtTnNkV1JsWkNJNlczc2lkSGx3WlNJNkltRndjR3hwWTJGMGFXOXVTV1FpTENKcFpDSTZJbWx2TG1sdGFYUnZMbmR2ZFc1a1oyVnVhWFZ6TG5KbFlXTjBibUYwYVhabEluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSndhRzkwYjBOaGNIUjFjbWx1WnlKOUxIc2lhV1FpT2lKMmFXUmxiME5oY0hSMWNtbHVaeUlzSW5SNWNHVWlPaUptWldGMGRYSmxTV1FpZlN4N0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaUxDSnBaQ0k2SW5KMWJHVnlUV1ZoYzNWeVpXMWxiblJEWVhCMGRYSnBibWNpZlN4N0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaUxDSnBaQ0k2SW0xaGNtdGxjazFsWVhOMWNtVnRaVzUwUTJGd2RIVnlhVzVuSW4wc2V5SjBlWEJsSWpvaVptVmhkSFZ5WlVsa0lpd2lhV1FpT2lKbWNtOXVkR0ZzUTJGdFpYSmhJbjBzZXlKMGVYQmxJam9pWm1WaGRIVnlaVWxrSWl3aWFXUWlPaUp0ZFd4MGFYQnNaVmR2ZFc1a2MxQmxja2x0WVdkbEluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSjNiM1Z1WkVSbGRHVmpkR2x2YmlKOUxIc2lkSGx3WlNJNkltWmxZWFIxY21WSlpDSXNJbWxrSWpvaWJHbDJaVmR2ZFc1a1JHVjBaV04wYVc5dUluMHNleUpwWkNJNkltSnZaSGxRWVhKMFVHbGphMlZ5SWl3aWRIbHdaU0k2SW1abFlYUjFjbVZKWkNKOUxIc2lkSGx3WlNJNkltWmxZWFIxY21WSlpDSXNJbWxrSWpvaWJHOWpZV3hUZEc5eVlXZGxTVzFoWjJWekluMHNleUpwWkNJNklteHZZMkZzVTNSdmNtRm5aVlpwWkdWdmN5SXNJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlmVjBzSW0xbGRHRWlPbnNpYVhOemRXVmtJam9pTWpBeU5DMHdOeTB6TVNBeE5Eb3pOVG96TVNJc0ltVjRjR2x5ZVNJNklqSXdNalF0TURrdE16QWdNVFE2TXpVNk1EQWlmU3dpWkdGMFlTSTZlMzE5Iiwic2lnIjoiUVo1eHBoQjVuYll1SVwvT01XT01EQkMzcDJcL2tFNWVkSmowd1N4aktscERUQXNZMVdMZEptYkl5MWJDM1loQVc1YWxPckhaTlpQK3o3TFZcLzhyblJSTTdOdXRrRTFWMmp1bmhrRTZtOXpIRU9zb1BnZHh2akZRNlVFN094VitXNFBjOXVjNkNiRzZxdnZDb2crUWpSWW43VnptT2FHRXgydzBTaElUdkNOTE1yMG5OT1lPSmZCUmtUbWoxYU9nY1NnMmZFNnFCOExxTTMyWFNSbXZvOXpFaUpaQXZKbFZUOGdGbzgzN0MweGN3KzdPOGl3WXhyeGI5UVY0NXo5ZWdRdHNEZ1AyZ3c5UE1sM3hDZTRWbnRtaDJjSUxCUXhKNkFJZEtFeWl3OEZKdFBCXC82VElqaVN0RUhqRFhManBKOUxydGRwakJ6T24wSXlFZ1hmZFZMamcwbjlzVjhsZWtObWZuaWhsUWdtZDhiS3VjUVwvXC8rTUw4VFZ3RzMweGJNbUZlQVFYV2JkbVFwTDM3elF6NEJGRTF5UU16d1grU09XTWlXMHRERG5GN21lSEFxeGNVMlkxWkIxSDgzbU5LcjJPemZJSXd5MFwvSmRVdUJtNHV3UXloMStXbHVWYnVBeTYzQ3FcL0ZVTW44d1dvRGhTQ2NlK2NaTEtQTFBlTkRTN0c3cWFvTmloZVdFNGVaV2dJYWU1cU5neUVQWlZUZVV3TDlCSWNtNXMxaW5tNDBaNzZMV1g5cmVxVEhOS01sNEs1TnRqeEVGbzFcL1ZXaE81THc2VG9VWFJvdFE0aHAwczRlclNTRE1mK1JhXC9LdE16OFk1SjVWditDdXVTelNGS2RzYmVvbGhxOEJVcmFzUmJiMWpGczdTSE5sM0dXcm1tb2lEZklKUGl0VE8ybW4wPSJ9")
    
    self.completion = completion
  }
  
  // End: Non-protocol Properties
  
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
