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

  func fetchAssets() -> [PHAsset] {
    let fetchOptions = PHFetchOptions()
    fetchOptions.fetchLimit = Constants.fetchLimit
    let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOptions)
    let indexes = IndexSet(0..<Constants.fetchLimit)
    let assets = fetchResult.objects(at: indexes)
    print(assets.count)

    return assets
  }

  func cacheAssets(assets: [PHAsset]) {
    guard !assets.isEmpty else { return }

    cachingImageManager.startCachingImages(for: assets,
                                           targetSize: CGSize(width: 86, height: 86),
                                           contentMode: .aspectFill,
                                           options: imageRequestOptions)
  }

  func stopCachingAssets() {
    cachingImageManager.stopCachingImagesForAllAssets()
    pendingRequests.forEach({ cachingImageManager.cancelImageRequest($0) })
  }

  func requestImage(for asset: PHAsset, completion: @escaping (UIImage?) -> ()) {
    let requestId = cachingImageManager.requestImage(for: asset,
                                                     targetSize: CGSize(width: 86, height: 86),
                                                     contentMode: PHImageContentMode.aspectFill,
                                                     options: imageRequestOptions) { [weak self] image, info in
      if let requestId = info?["PHImageResultRequestIDKey"] as? PHImageRequestID,
         let index = self?.pendingRequests.index(of: requestId) {
        self?.pendingRequests.remove(at: index)
      }
      completion(image)
    }
    pendingRequests.append(requestId)
  }

  func stopRequestingImages() {
    pendingRequests.forEach({ cachingImageManager.cancelImageRequest($0) })
  }

}
