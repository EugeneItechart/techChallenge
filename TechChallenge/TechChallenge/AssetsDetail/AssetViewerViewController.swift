//
//  AssetViewerViewController.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit
import Photos

class AssetViewerViewController: UIViewController {

  private enum Constants {
    static let magnifyingGlassIconName = "arrow.up.left.and.down.right.magnifyingglass"
    static let animationDuration = 0.8
  }

  private let saliencyHandler = VisionSaliencyHandler()
  private let salientObjectsLayer = CAShapeLayer()
  private let handler = PhotoLibraryFetchAssetsHandler()

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private var currentContentMode = UIView.ContentMode.scaleAspectFill

  override func viewDidLoad() {
    super.viewDidLoad()

    configureContainerView()
    setupSalientObjectsLayer()
    configureNavigationItem()

    view.backgroundColor = .white
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    view.backgroundColor = .clear
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    salientObjectsLayer.frame = imageView.bounds
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    view.backgroundColor = .white
    imageView.image = nil
    handler.stopRequestingImages()
    salientObjectsLayer.removeFromSuperlayer()
  }

  // setup with thumbnail image and try to load a full-size one
  func setupWithImageInfo(_ image: UIImage?, asset: PHAsset) {
    updateImage(image: image)
    DispatchQueue.global(qos: .userInteractive).async {
      self.handler.requestImage(for: asset, contentMode: .aspectFill, deliveryMode: .highQualityFormat) { [weak self] image in
        self?.updateImage(image: image)
      }
    }
  }

  private func updateImage(image: UIImage?) {
    DispatchQueue.main.async {
      self.imageView.image = image
      self.findAreasOfInterest()
    }
  }

  private func configureContainerView() {
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  private func setupSalientObjectsLayer() {
    salientObjectsLayer.strokeColor = UIColor.red.cgColor
    salientObjectsLayer.fillColor = nil
    imageView.layer.addSublayer(salientObjectsLayer)
  }

  private func configureNavigationItem() {
    let config = UIImage.SymbolConfiguration(scale: .large)
    let buttonImage = UIImage(systemName:Constants.magnifyingGlassIconName, withConfiguration: config)
    let button = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
    navigationController?.navigationBar.tintColor = .white
    navigationItem.rightBarButtonItem = button
    navigationController?.isNavigationBarHidden = false
  }

  private func findAreasOfInterest() {
    guard let cgImage = imageView.image?.cgImage else { return }

    DispatchQueue.global(qos: .userInteractive).async {
      let saliencyObjects = self.saliencyHandler.findAreasOfInterest(cgImage) ?? []
      DispatchQueue.main.async {
        self.updatePathForSaliencyLayer(with: saliencyObjects)
      }
    }
  }

  private func updatePathForSaliencyLayer(with rects: [CGRect]) {
    let size = imageView.bounds.size
    DispatchQueue.global(qos: .userInteractive).async {
      let path = self.saliencyHandler.createBoundingPathForSalientObjects(rects, size: size)
      DispatchQueue.main.async {
        self.salientObjectsLayer.path = path
      }
    }
  }

  @objc private func rightBarButtonItemTapped() {
    guard imageView.image != nil else { return }

    let ratio = imageScale(of: imageView)
    var scaleTransform: CGAffineTransform = .identity
    let newContentMode: UIView.ContentMode = currentContentMode == .scaleAspectFit ? .scaleAspectFill : .scaleAspectFit
    if newContentMode == .scaleAspectFit {
      scaleTransform = CGAffineTransform(scaleX: ratio, y: ratio)
    }
    UIView.animate(withDuration: Constants.animationDuration) {
      self.imageView.transform = scaleTransform
    } completion: { completed in
      self.currentContentMode = newContentMode
    }
  }
}
