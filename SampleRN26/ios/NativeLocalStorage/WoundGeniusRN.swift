//
//  WoundGeniusRN.swift
//  TurboModuleExample
//
//  Created by Eugene Naloiko on 03.10.2025.
//

import UIKit
import WoundGenius

typealias RCTPromiseResolveBlock = (Any?) -> Void
typealias RCTPromiseRejectBlock = (String?, String?, Error?) -> Void


@objc(WoundGeniusRN)
class WoundGeniusRN: NSObject {
  private var resolveBase64Image: RCTPromiseResolveBlock?
  private var rejectBase64Image: RCTPromiseRejectBlock?
  
  private lazy var wgRouter = WGRouter(presenter: WoundGeniusPresenter(completion: { [weak self] photoResult, measurementResult in
    guard let self = self else { return }
    
    // We've configured the Presenter to Return PhotoResult, or MeasurementResult.
    if let photoResult = photoResult {
      // Handle the Photo Result.
      guard let base64ResultingString = photoResult.preview.jpegData(compressionQuality: 0.4)?.base64EncodedString() else { return }
      self.resolveBase64Image?(base64ResultingString)
    } else if let measurementResult = measurementResult {
      // Handle the Measurement Result.
      guard let base64ResultingString = measurementResult.image.jpegData(compressionQuality: 1)?.base64EncodedString(), let modifiedImage = measurementResult.image.draw(outlines: measurementResult.outlines).jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
      self.resolveBase64Image?(base64ResultingString)
    }
  }))
  
  @objc func startCapturing(
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    self.resolveBase64Image = resolve
    self.rejectBase64Image = reject
    DispatchQueue.main.async {
      guard let topMostVC = self.getTopMostViewController() else { return }
      self.wgRouter.startCapturing(over: topMostVC, completion: { shown in
        
      })
    }
  }
  
  func getTopMostViewController() -> UIViewController? {
    guard let keyWindow = UIApplication.shared.connectedScenes
      .filter({ $0.activationState == .foregroundActive })
      .map({ $0 as? UIWindowScene })
      .compactMap({ $0 })
      .first?.windows
      .filter({ $0.isKeyWindow }).first else {
      return nil
    }
    
    var topController = keyWindow.rootViewController
    
    while let presentedViewController = topController?.presentedViewController {
      topController = presentedViewController
    }
    
    return topController
  }
}
