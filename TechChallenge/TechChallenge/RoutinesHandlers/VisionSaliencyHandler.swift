//
//  VisionSaliencyHandler.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import Vision
import UIKit

struct VisionSaliencyHandler {

  func findAreasOfInterest(_ imageUrl: URL) -> [CGRect]? {
//    let handler = VNImageRequestHandler(data: data)
    let handler = VNImageRequestHandler(url: imageUrl, options: [:])
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

    // allways 1 object
    guard let observation = request.results?.first as? VNSaliencyImageObservation else { return nil }
    return observation.salientObjects?.compactMap({ $0.boundingBox })
  }
// don't work
  func createBoundingPathForSalientObjects(_ salientObjectsBoxes: [CGRect],
                                           transform: CGAffineTransform,
                                           size: CGSize) -> CGPath {
    let path = CGMutablePath()
    for object in salientObjectsBoxes {
      let boundingBox = object
      print("boundingBox: \(boundingBox)")
//      let xCord = object.topLeft.x * 320
//      let yCord = (1 - object.topLeft.y) * 568
//      let width = (object.topRight.x - object.bottomLeft.x) * 320
//      let height = (object.topLeft.y - object.bottomLeft.y) * 568
//
//      let newBox = CGRect(x: xCord, y: yCord, width: width, height: height)
//      var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
//      let rect = boundingBox.applying(bottomToTopTransform)
      let newBox = VNImageRectForNormalizedRect(boundingBox, Int(size.width), Int(size.height))
      print("newBox: \(newBox)")
      path.addRect(boundingBox, transform: transform)
    }
    return path
  }

}
