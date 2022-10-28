//
//  PhotoLibraryFetchAssetsHandler.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import Foundation
import Photos
import UIKit

class PhotoLibraryFetchAssetsHandler {

  private enum Constants {
    static let fetchLimit = 1000
  }

  private let cachingImageManager = PHCachingImageManager()
  private var pendingRequests = [PHImageRequestID]()

  func requestAccessToPhotoLibrary(completion: @escaping (Bool) -> ()) {
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
      completion(status == .authorized || status == .limited)
    }
  }

  func fetchPhotoAssets() -> [PHAsset] {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.fetchLimit = Constants.fetchLimit

    let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOptions)
    let indexes = IndexSet(0..<fetchResult.count)
    let assets = fetchResult.objects(at: indexes)

    return assets
  }

  func cacheAssets(_ assets: [PHAsset], targetSize: CGSize) {
    guard !assets.isEmpty else { return }

    let options = PHImageRequestOptions()
    options.deliveryMode = .fastFormat

    cachingImageManager.startCachingImages(for: assets,
                                           targetSize: targetSize,
                                           contentMode: .aspectFill,
                                           options: options)
  }

  func stopCachingAssets() {
    cachingImageManager.stopCachingImagesForAllAssets()
  }

  func requestImage(for asset: PHAsset,
                    targetSize: CGSize = PHImageManagerMaximumSize,
                    contentMode: PHImageContentMode = .aspectFill,
                    deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat,
                    completion: @escaping (UIImage?) -> ()) {

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    let requestId = cachingImageManager.requestImage(for: asset,
                                                     targetSize: targetSize,
                                                     contentMode: contentMode,
                                                     options: options) { [weak self] image, info in
      if let requestId = info?[PHImageResultRequestIDKey] as? PHImageRequestID,
         let index = self?.pendingRequests.firstIndex(of: requestId) {
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
