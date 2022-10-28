//
//  VisionSaliencyHandler.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import Vision
import UIKit

struct VisionSaliencyHandler {

  func findAreasOfInterest(_ image: CGImage) -> [CGRect]? {
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    let request = VNGenerateAttentionBasedSaliencyImageRequest { _, error in
      if let error = error {
        print(error)
      }
    }
    request.revision = VNGenerateAttentionBasedSaliencyImageRequestRevision1
    do {
      try handler.perform([request])
    } catch {
      print(error)
    }

    // there's allways 1 object for attention based request
    guard let observation = request.results?.first as? VNSaliencyImageObservation else { return nil }
    return observation.salientObjects?.compactMap({ $0.boundingBox })
  }

  func createBoundingPathForSalientObjects(_ salientObjectsBoxes: [CGRect], size: CGSize) -> CGPath {
    let path = CGMutablePath()
    for rect in salientObjectsBoxes {
      let boundingBox = VNImageRectForNormalizedRect(rect, Int(size.width), Int(size.height))
      path.addRect(boundingBox)
    }
    return path
  }

}
