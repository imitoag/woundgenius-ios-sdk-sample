//
//  WoundGeniusPresenter.swift
//  TurboModuleExample
//
//  Created by Eugene Naloiko on 03.10.2025.
//

import UIKit
import WoundGenius
import AVFoundation

/**
 The WoundGeniusPresenter, which convigures the WoundGenius framework. For more details on configurable parameters - check the SDK README files.
 */
class WoundGeniusPresenter: NSObject, WGPresenterProtocol {
  
  // Disabled single wound per image mode.
  var isSingleAreaModeEnabled: Bool = false
    
  // Custom completion, which can return the Photo result or Measurement result.
  private var completion: ((PhotoCaptureResult?, MeasurementResult?)->())?
  
  // Init method for the presenter.
  init(completion: @escaping ((PhotoCaptureResult?, MeasurementResult?)->())) {
    
    super.init()
    
    // Activate the WoundGenius with your license key.
    WG.activate(licenseKey: "eyJzaWciOiJDWnFEMmRZRlkzU21hKzRqM2JxSVpUREJIb0RTNnVmTTdIQ3F6TXQxZTd1VWVsY1wvbzBmbkpydUFyQkY4NnIyb3dTd3N3ZDQyaytZbFRaa2gzZmZlYmo3S0MyTWZBMjYzSEJGdHpJRGdHT0dZd2l5TGNYQ1pVSGVjamxmWTZkSldvSjhxRUk3UUdoTFZOVzJvZ1F6YWp0aDU2RU1zeEJNU3h0bnl6QklSK2JidlJqb1dibDFjTkQyS3pcL2FRbk5ZWml2QTR6aHdydjR5ZUhNcjV6dHpOTU5UMDBuZ3pLTFpENTVQTUlPUWhhVjFMaGZEd3MrQXRsNU9BYWZxT3NGNmlyYThzSktPOTNFODlyb1NIRlVkMXIwbHdtaFVyWDN0aWNnbkFIZTFzbmZTSkdGRHBJWURWd25OWVhvY1F5RFhNd1lnSDc3OE8zREJITU5kYXdIdVd2d1RYeVhyQmFhWkY1OEFUYmN2ZVZtWlwvTHlaTkdtbTZIUk9UWHp4SFFXMmUzMFJyTGNNWnZJQlc1TUFSa01GZDhXUk5TemRFRENFTE51UzUrWjJhU3pIZGVmcEc0bFwvM2FVR2YrSnM5NVo2RGQrWVZTcXpLcVwvQlA1QzhDY3lMMjF4c0RuVHZVSjVKUXhsd1diZUliV2JOZXNncXd6NWRoRWZldkFoQXVOZ1M2eDBBdzM5V1U4QWlmWGUxYVJNN3N6dzY5bzlFZDNzYWZta2xKRytGU0lxam9udzdoYmxjQ3ExU1ExT3dDbTNOZ0d3VkJFSkJyRTVPeWw3cUJMQ0ZGcUc0WCtiQnpoczRibzVic1gzaFhsT29UYjJzS21JYnhcL0xzK1lxQ1l0NHBMbkN3ME9zSnFtM2tERkNqUU9NWEtGeDN0bVZPV0NVT284WmVNbFlLWHI2Zz0iLCJhbGciOiIxIiwiZW5jIjoiZXlKcGJtTnNkV1JsWkNJNlczc2lkSGx3WlNJNkltRndjR3hwWTJGMGFXOXVTV1FpTENKcFpDSTZJbWx2TG1sdGFYUnZMbmR2ZFc1a1oyVnVhWFZ6TG5OaGJYQnNaU0o5TEhzaWRIbHdaU0k2SW1abFlYUjFjbVZKWkNJc0ltbGtJam9pY0dodmRHOURZWEIwZFhKcGJtY2lmU3g3SW5SNWNHVWlPaUptWldGMGRYSmxTV1FpTENKcFpDSTZJblpwWkdWdlEyRndkSFZ5YVc1bkluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSnlkV3hsY2sxbFlYTjFjbVZ0Wlc1MFEyRndkSFZ5YVc1bkluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSnRZWEpyWlhKTlpXRnpkWEpsYldWdWRFTmhjSFIxY21sdVp5SjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2liR2x1WlUxbFlYTjFjbVZ0Wlc1MEluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSm1jbTl1ZEdGc1EyRnRaWEpoSW4wc2V5SjBlWEJsSWpvaVptVmhkSFZ5WlVsa0lpd2lhV1FpT2lKaGNtVmhVMk5oYm01cGJtY3pSQ0o5TEhzaWRIbHdaU0k2SW1abFlYUjFjbVZKWkNJc0ltbGtJam9pYlhWc2RHbHdiR1ZYYjNWdVpITlFaWEpKYldGblpTSjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2lkMjkxYm1SRVpYUmxZM1JwYjI0aWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNklteHBkbVZYYjNWdVpFUmxkR1ZqZEdsdmJpSjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2lZbTlrZVZCaGNuUlFhV05yWlhJaWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNklteHZZMkZzVTNSdmNtRm5aVWx0WVdkbGN5SjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2liRzlqWVd4VGRHOXlZV2RsVm1sa1pXOXpJbjFkTENKa1lYUmhJanA3ZlN3aWJXVjBZU0k2ZXlKbGVIQnBjbmtpT2lJeU1ESTFMVEV5TFRNeElERXdPalE1T2pBd0lpd2lhWE56ZFdWa0lqb2lNakF5TlMweE1DMHdNeUF3T1RvME9UbzFPQ0o5ZlE9PSJ9") // Sample License Key. Valid Till December 31, 2025. Use your license key here, with your bundle id to run the sample app.
    
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
  
  var autoDetectionMode: WoundGenius.AutoDetectionMode = .woundOnly
  
  var isLiveWoundDetectionEnabled: Bool = true
  
  var enabledOutlineTypes: [WoundGenius.IMOutlineCluster] = [.wound]
  
  /**
   - Avoid creation of WoundGeniusTFLiteExtension object multiple times. This way it will be created once.
   - Disable TFLiteFlow for Simulator, as Google built TensorFlowLiteTaskVision runnable on real devices only.
   */
  
  var tfLiteExtension: (any WoundGenius.TFLiteExtensionProtocol)? {
    self.tfLiteExtensionLocal
  }
  
  private lazy var tfLiteExtensionLocal: WoundGenius.TFLiteExtensionProtocol? = {
#if targetEnvironment(simulator)
    return nil
#else
    return WoundGeniusTFLiteExtension.shared
#endif
  }()
  
  var userId: String? = nil
  
  var availableModes: [WoundGenius.ImitoCameraMode] = [.markerMeasurement, .rulerMeasurement]
  
  var defaultMode: WoundGenius.ImitoCameraMode = .markerMeasurement
  
  var tutorialsAvailableForModes: [WoundGenius.ImitoCameraMode] = []
  
  var isBodyPartPickerAvailable: Bool = false
  
  var isAddFromLocalStorageAvailable: Bool = true
  
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
    
  func handle(event: WoundGenius.WGEvent) {
    switch event {
    case .cancelButtonTapped(let vc):
      vc.dismiss(animated: true) // Dismiss the Capture Screen on cancel.
    case .capturedPhoto(let vc, let result):
      completion?(result, nil) // Transfer captured photo result.
      vc.dismiss(animated: true) // Dismiss the Capture Screen if max 1 media is requied.
    case .capturedMarkerMeasurement(let vc, let result):
      self.showOutlining(captureVC: vc, captureResult: result)
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
              self.presentMeasurementFlow(overCaptureVC: vc, captureResult: photoResult, pointViews: nil, sideSize: nil)
            }
          }
        }
      default:
        break
      }
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
  
  func showRulerMeasurementScaleDefinition(captureVC: IMCaptureViewController, captureResult: PhotoCaptureResult) {
    guard let image = captureResult.preview else { return }
    
    var pinsViewController: PinsViewController?
    pinsViewController = PinsViewController(image: image, config: self) { [weak self] size, pointViews in
      guard let `self` = self else {return}
      pinsViewController?.dismiss(animated: false, completion: { [weak self] in
        guard let `self` = self else { return }
        self.presentMeasurementFlow(overCaptureVC: captureVC, captureResult: captureResult, pointViews: pointViews, sideSize: size)
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
    
    let woundStomaConfig: WoundStomaConfig =
      .wound(config: WoundConfig(isMultipleOutlinesEnabled: true,
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
                                             resultScreenBottomView: nil,
                                             sideSize: sideSize,
                                             linePoints: linePoints,
                                             navConfig: navConfig,
                                             config: self,
                                             willPresentResults: {
      
    }, completion: { [weak self] measureResult in
      guard let `self` = self else { return }
      
      /* Now as we've generated the MeasurementResult (Which contains the UIImage - we can clean-up the file in Documents folder which is available in context of PhotoCaptureResult */
      captureResult.deleteRelatedFiles()
      
      self.completion?(nil, measureResult) // Transfer the Measurement Result.
      overCaptureVC.dismiss(animated: true)  // Dismiss the Capture Screen.
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

