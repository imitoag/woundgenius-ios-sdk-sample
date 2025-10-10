//
//  WoundGeniusTensorFlowLiteExtension.swift
//  Sample
//
//  Created by Eugene Naloiko on 17.12.2023.
//

import UIKit
import WoundGenius
#if targetEnvironment(simulator)
#else
import TensorFlowLiteTaskVision

class WoundGeniusTFLiteExtension: NSObject, TFLiteExtensionProtocol {
    static let shared = WoundGeniusTFLiteExtension()
    
    private let segmentationQueue = DispatchQueue(label: "WoundGeniusTFLiteExtension", qos: .userInitiated)
        
    private var segmenters = [SegmenterType: ImageSegmenter]()
        
    private override init() {}
    
    /** Optionally you can release memory used for Segmenters. */
    public func cleanup() {
        self.segmenters = [SegmenterType: ImageSegmenter]()
    }
        
    func setupSegmenter(path: String, type: SegmenterType) -> Bool {
        guard segmenters[type] == nil else {
            return true
        }
        
        let options = ImageSegmenterOptions(modelPath: path)
        do {
            let segmenter = try ImageSegmenter.segmenter(options: options)
            segmenters[type] = segmenter
            return true
        } catch {
            print("func setupSegmenter(path: String, type: SegmenterType) -> Bool: \(error)")
            return false
        }
    }
    
    func runSegmentation(type: WoundGenius.SegmenterType,
                         image: UIImage,
                         completion: @escaping ((Result<WoundGenius.ImageSegmentationResult, WoundGenius.SegmentationError>) -> Void)) {
        self.segmentationQueue.async {
            guard let segmenter = self.segmenters[type] else {
                completion(.failure(.segmenterNotInitialized))
                return
            }
            
            let segmentationResult: SegmentationResult
            var inferenceTime: TimeInterval = 0
            do {
                let startTime = Date()
                guard let mlImage = MLImage(image: image) else {
                    completion(.failure(SegmentationError.invalidImage))
                    return
                }
                segmentationResult = try segmenter.segment(mlImage: mlImage)
                inferenceTime = Date().timeIntervalSince(startTime)
            } catch {
                completion(.failure(SegmentationError.internalError(error)))
                return
            }
            let startTime = Date()
            
            guard let (resultImage, colorLegend) = self.parseOutput(segmentationResult: segmentationResult) else {
                completion(.failure(SegmentationError.postProcessingError))
                return
            }
            let postprocessingTime = Date().timeIntervalSince(startTime)
            let result = ImageSegmentationResult(
                resultImage: resultImage,
                colorLegend: colorLegend,
                inferenceTime: inferenceTime,
                postProcessingTime: postprocessingTime
            )
            completion(.success(result))
        }
    }
    
    private func parseOutput(segmentationResult: SegmentationResult) -> (UIImage, [String: UIColor])? {
        guard let segmentation = segmentationResult.segmentations.first, let categoryMask = segmentation.categoryMask else { return nil }
        let mask = categoryMask.mask
        let results = [UInt8](UnsafeMutableBufferPointer(start: mask, count: categoryMask.width * categoryMask.height))
        
        let alphaChannel: UInt32 = 255
        let classColorsUInt32: [UInt32] = segmentation.coloredLabels.map({
            let colorAsUInt32 = alphaChannel << 24  + UInt32($0.r) << 16 + UInt32($0.g) << 8 + UInt32($0.b)
            return colorAsUInt32
        })
        let segmentationImagePixels: [UInt32] = results.map({ classColorsUInt32[Int($0)] })
        guard let resultImage = UIImage.fromSRGBColorArray(pixels: segmentationImagePixels, size: CGSize(width: categoryMask.width, height: categoryMask.height)) else { return nil }
        
        let classFoundInImageList = IndexSet(Set(results).map({ Int($0) }))
        let filteredColorLabels = classFoundInImageList.map({ segmentation.coloredLabels[$0] })
        let colorLegend = [String: UIColor](uniqueKeysWithValues: filteredColorLabels.map { colorLabel in
            let color = UIColor(red: CGFloat(colorLabel.r) / 255.0, green: CGFloat(colorLabel.g) / 255.0, blue: CGFloat(colorLabel.b) / 255.0, alpha: CGFloat(alphaChannel) / 255.0)
            return (colorLabel.label, color)
        })
        
        return (resultImage, colorLegend)
    }
}
#endif
