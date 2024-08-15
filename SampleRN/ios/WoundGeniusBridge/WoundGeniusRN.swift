//
//  WoundGeniusRN.swift
//  SampleRN
//
//  Created by Eugene Naloiko on 07.08.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit
import WoundGenius

@objc(WoundGeniusRN)
class WoundGeniusRN: RCTEventEmitter {
  
  // Initialize the WoundGenius Router instance with WoundGeniusPresenter which sets up the behaviour of the SDK.
  private lazy var wgRouter = WGRouter(presenter: WoundGeniusPresenter(completion: { [weak self] photoResult, measurementResult in
    guard let self = self else { return }
    
    // We've configured the Presenter to Return PhotoResult, or MeasurementResult.
    if let photoResult = photoResult {
      // Handle the Photo Result.
      guard let base64ResultingString = photoResult.preview.jpegData(compressionQuality: 0.4)?.base64EncodedString() else { return }
      DispatchQueue.main.async {
        self.sendImageCaptured(image: base64ResultingString, modifiedImage: base64ResultingString, metadata: ["type":"photo"])
      }
    } else if let measurementResult = measurementResult {
      // Handle the Measurement Result.
      guard let base64ResultingString = measurementResult.image.jpegData(compressionQuality: 1)?.base64EncodedString(), let modifiedImage = measurementResult.image.draw(outlines: measurementResult.outlines).jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
      DispatchQueue.main.async {
        var metadata = NSMutableDictionary()
        metadata["type"] = "measurement"
        if let lengthOfOneCMInPixels = measurementResult.lengthOfOneCmInPixels {
          metadata["lengthOfOneCMInPixels"] = lengthOfOneCMInPixels
        }
        metadata["outlines"] = measurementResult.outlines.map({
          $0.toDictionary()
        })
        
        self.sendImageCaptured(image: base64ResultingString, modifiedImage: modifiedImage, metadata: metadata)
      }
    }
  }))
  
  private var count = 0;
  
  /**
   This is the showcase - how to call the Native iOS method with a React Native Callback.
   */
  @objc func increment(_ callback: RCTResponseSenderBlock) {
    count += 1
    callback([count])
  }
  
  // To run on main thread.
  @objc override static func requiresMainQueueSetup() -> Bool {
    return true;
  }
  
  @objc
  override func constantsToExport() -> [AnyHashable: Any]! {
    return ["initialCount": 0]
  }
  
  override func supportedEvents() -> [String]! {
    return ["onImage"]
  }
  
  /**
   This is the showcase - how to call the Native iOS method with a React Native Callback. Which can result in success or failure.
   */
  @objc func decrement(_ resolve: RCTPromiseResolveBlock,
                 reject: RCTPromiseRejectBlock) {
    if (count == 0) {
      let error = NSError(domain: "", code: 200, userInfo: nil)
      reject("ERROR_COUNT", "count cannot be negative", error)
    } else {
      count -= 1
      resolve(count)
    }
  }
  
  /**
   This is a showcase of how to present the WoundGenius Capturing over the Top Most ViewController of the React Native app.
   */
  @objc func startCapturing() {
    DispatchQueue.main.async {
      guard let topMostVC = self.getTopMostViewController() else { return }
      self.wgRouter.startCapturing(over: topMostVC)
    }
  }
  
  /**
   A method to identify the Top Most View Controller of the iOS App.
   */
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
  
  /**
   Send the event to React Native. With original image, modified image and metadata NSDictionary.
   */
  @objc func sendImageCaptured(image: String, modifiedImage: String, metadata: NSDictionary) {
    sendEvent(withName: "onImage", body: ["base64ImageOriginal": image, "base64ImageModified": modifiedImage, "metadata": metadata])
  }
}

extension MeasuredOutline {
  
  /// Convenience method to convert data to NSDictionary - which can be forwarded to ReactNative.
  func toDictionary() -> NSDictionary {
    let dict = NSMutableDictionary()
    
    if let areaInCM = self.areaInCM {
      dict["areaInCM"] = areaInCM
    }
    
    if let widthInCM = self.widthInCM {
      dict["widthInCM"] = widthInCM
    }
    
    if let depthCM = self.depthCM {
      dict["depthCM"] = depthCM
    }
    
    if let circumferenceInCM = self.circumferenceInCM {
      dict["circumferenceInCM"] = circumferenceInCM
    }
    
    if let lengthInCM = self.lengthInCM {
      dict["lengthInCM"] = lengthInCM
    }
    
    if let excluding = self.excluding, excluding.count > 0 {
      dict["excluding"] = excluding.map({ $0.toDictionary() })
    }
    
    dict["widthStartPointPixels"] = self.widthStartPointPixels.toDictionary()
    dict["widthEndPointPixels"] = self.widthEndPointPixels.toDictionary()
    
    dict["lengthStartPointPixels"] = self.lengthStartPointPixels.toDictionary()
    dict["lengthEndPointPixels"] = self.lengthEndPointPixels.toDictionary()
    
    dict["points"] = self.points.map({ $0.toDictionary() })
    
    return dict
  }
}

extension ExcludedMeasuredOutline {
  
  /// Convenience method to convert data to NSDictionary - which can be forwarded to ReactNative.
  func toDictionary() -> NSDictionary {
    let dict = NSMutableDictionary()

    if let areaInCM = self.areaInCM {
      dict["areaInCM"] = areaInCM
    }
    
    dict["points"] = self.points.map({ $0.toDictionary() })
    
    return dict
  }
}

extension CGPoint {
  
  /// Convenience method to convert data to NSDictionary - which can be forwarded to ReactNative.
  func toDictionary() -> NSDictionary {
    let dict = NSMutableDictionary()
    dict["x"] = self.x
    dict["y"] = self.y
    return dict
  }
}

