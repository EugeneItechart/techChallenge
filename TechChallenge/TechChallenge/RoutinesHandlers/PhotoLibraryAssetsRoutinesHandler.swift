//
//  PhotoLibraryAssetsRoutinesHandler.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import Foundation
import Photos
import UIKit

class PhotoLibraryAssetsRoutinesHandler {

  private enum Constants {
    static let fetchLimit = 1000
  }

  private let cachingImageManager = PHCachingImageManager()
  private let imageRequestOptions = PHImageRequestOptions()
  private var pendingRequests = [PHImageRequestID]()

  func requestAccessToPhotoLibrary(completion: @escaping (Bool) -> ()) {
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
      completion(status == .authorized || status == .limited)
    }
  }

  func fetchPhotoAssets() -> [PHAsset] {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // fetch only photos
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)] // fetch last 1000 photos
    //requestOptions.deliveryMode = .highQualityFormat
    fetchOptions.fetchLimit = Constants.fetchLimit

    let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOptions)
    let indexes = IndexSet(0..<Constants.fetchLimit)
    let assets = fetchResult.objects(at: indexes)

    return assets
  }

  func cacheAssets(assets: [PHAsset], targetSize: CGSize) {
    guard !assets.isEmpty else { return }

    imageRequestOptions.deliveryMode = .highQualityFormat // .opportunistic

    cachingImageManager.startCachingImages(for: assets,
                                           targetSize: targetSize,
                                           contentMode: .aspectFill,
                                           options: imageRequestOptions)
  }

  func stopCachingAssets(assets: [PHAsset]) {
    cachingImageManager.stopCachingImages(for: assets,
                                          targetSize: CGSize(width: 86, height: 86),
                                          contentMode: .aspectFill,
                                          options: imageRequestOptions)
  }

  func requestImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> ()) {
    //    cachingImageManager.allowsCachingHighQualityImages = true
    //   imageRequestOptions.progressHandler // check show loading indicator
   // contentMode for detailed presentation: .aspectFit
   // targetSize: max
    let requestId = cachingImageManager.requestImage(for: asset,
                                                     targetSize: targetSize,
                                                     contentMode: .aspectFill,
                                                     options: imageRequestOptions) { [weak self] image, info in
      if let requestId = info?["PHImageResultRequestIDKey"] as? PHImageRequestID,
         let index = self?.pendingRequests.firstIndex(of: requestId) {
        self?.pendingRequests.remove(at: index)
      }
      completion(image)
    }
//    pendingRequests.append(requestId)
  }

  func stopRequestingImages() {
    pendingRequests.forEach({ cachingImageManager.cancelImageRequest($0) })
  }

}

// cachingImageManager.allowsCachingHighQualityImages
//   imageRequestOptions.progressHandler // check
