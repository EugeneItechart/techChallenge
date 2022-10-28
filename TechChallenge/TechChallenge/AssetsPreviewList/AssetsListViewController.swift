//
//  AssetsListViewController.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit
import Photos

class AssetsListViewController: UIViewController, UINavigationControllerDelegate {

  private let handler = PhotoLibraryAssetsRoutinesHandler()
  private var datasource: [PHAsset] = []

  private lazy var assetsCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.prefetchDataSource = self
    collectionView.register(AssetPreviewCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellReuseIdentifier)

    return collectionView
  }()

  private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
    $0.scrollDirection = .vertical
    $0.minimumInteritemSpacing = 5
    $0.minimumLineSpacing = 5
    $0.sectionInset = .zero

    let numberOfItemsInRow = Constants.numberOfItemsInRow
    let totalSpace = $0.minimumInteritemSpacing * CGFloat(numberOfItemsInRow - 1)
    let size = (view.bounds.width - totalSpace) / CGFloat(numberOfItemsInRow)
    $0.itemSize = CGSize(width: size, height: size)
    return $0
  }(UICollectionViewFlowLayout())

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Recents"
    view.backgroundColor = .white

    configureContainerView()
    requestAssetsFromPhotoLibrary()

    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(appEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    center.addObserver(self, selector: #selector(appEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
  }

  private func configureContainerView() {
    view.addSubview(assetsCollectionView)
    NSLayoutConstraint.activate([
      assetsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      assetsCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      assetsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      assetsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  private func requestAssetsFromPhotoLibrary() {
    handler.requestAccessToPhotoLibrary { [weak self] authorized in
      guard let self = self, authorized else { return }

      DispatchQueue.global(qos: .userInteractive).async {
        let assets = self.handler.fetchPhotoAssets()
        self.datasource = assets
        DispatchQueue.main.async {
          self.assetsCollectionView.reloadData()
        }
      }
    }
  }

  @objc private func appEnterBackground() {
    //handler.stopCachingAssets()
    handler.stopRequestingImages()
  }

  @objc private func appEnterForeground() {
  }

}

extension AssetsListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
  private enum Constants {
    static let numberOfItemsInRow = 4
    static let cellReuseIdentifier = "AssetPreviewCollectionViewCell"
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datasource.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as?
            AssetPreviewCollectionViewCell else { return UICollectionViewCell() }

    let asset = datasource[indexPath.row]
    cell.identifier = asset.localIdentifier
    DispatchQueue.global(qos: .userInteractive).async {
      self.handler.requestImage(for: asset, targetSize: self.collectionViewLayout.itemSize) { image in
        if asset.localIdentifier == cell.identifier {
          DispatchQueue.main.async {
            cell.image = image
          }
        }
      }
    }

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let viewController = AssetViewerViewController()
    let thumbnailImage = (collectionView.cellForItem(at: indexPath) as? AssetPreviewCollectionViewCell)?.thumbnailImageView.image
    let asset = datasource[indexPath.row]
    viewController.setupWithImageInfo(thumbnailImage, asset: asset)
    navigationController?.pushViewController(viewController, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    print("prefetchItemsAt indexPaths: \(indexPaths)")

    let rows = indexPaths.map { $0.row }
    var assets = [PHAsset]()
    for row in rows {
      let asset = datasource[row]
      assets.append(asset)
    }
    DispatchQueue.global(qos: .userInteractive).async {
      self.handler.cacheAssets(assets: assets, targetSize: self.collectionViewLayout.itemSize)
    }
  }

  func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    print("cancel prefetching indexPaths: \(indexPaths)")
  }
}
