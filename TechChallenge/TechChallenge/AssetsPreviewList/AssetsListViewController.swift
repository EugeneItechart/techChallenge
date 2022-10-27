//
//  AssetsListViewController.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit
import Photos

class AssetsListViewController: UIViewController, UINavigationControllerDelegate {

  @IBOutlet private var assetsCollectionView: UICollectionView!

  private let handler = PhotoLibraryAssetsRoutinesHandler()
  private var datasource: [PHAsset] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    handler.requestAccessToPhotoLibrary { [weak self] authorized in
      guard let self = self, authorized else { return }

      DispatchQueue.global(qos: .userInteractive).async {
        let assets = self.handler.fetchAssets()
        self.datasource = assets
        self.handler.cacheAssets(assets: assets)
        DispatchQueue.main.async {
          self.assetsCollectionView.reloadData()
        }
      }
    }

    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(appEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    center.addObserver(self, selector: #selector(appEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
  }

  @objc private func appEnterBackground() {
    handler.stopCachingAssets()
    handler.stopRequestingImages()
  }

  @objc private func appEnterForeground() {
  }

}

extension AssetsListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  private enum Constants {
    static let numberOfItemsInRow = 4
    static let cellReuseIdentifier = "AssetPreviewCollectionViewCell"
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datasource.count
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    let numberOfItemsInRow = Constants.numberOfItemsInRow

    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    let totalSpace = flowLayout.sectionInset.left
    + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsInRow - 1))

    let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsInRow))
    print("size: \(size)")
    return CGSize(width: size, height: size)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as?
            AssetPreviewCollectionViewCell else { return UICollectionViewCell() }

    let asset = datasource[indexPath.row]
    handler.requestImage(for: asset) { image in
      DispatchQueue.main.async {
        cell.update(with: AssetPreviewCollectionViewCellModel(thumbnailImage: image))
      }
    }

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let viewController = AssetViewerViewController()
    navigationController?.pushViewController(viewController, animated: true)
  }
}
