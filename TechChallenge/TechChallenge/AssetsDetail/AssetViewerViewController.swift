//
//  AssetViewerViewController.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit

class AssetViewerViewController: UIViewController {

  private enum Constants {
    static let magnifyingGlassIconName = "arrow.up.left.and.down.right.magnifyingglass"
  }

  private let saliencyHandler = VisionSaliencyHandler()
  private let salientObjectsLayer = CAShapeLayer()

  private let imageView: ContentModeAnimatableView = {
    let view = ContentModeAnimatableView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    return view
  }()

  private var salientObjectsPathTransform = CGAffineTransform.identity
  private var nextContentMode = UIView.ContentMode.scaleAspectFit

  override func viewDidLoad() {
    super.viewDidLoad()

    configureContainerView()
    setupSalientObjectsLayer()
    configureNavigationItem()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    view.setNeedsLayout()
  }

  override func viewDidLayoutSubviews() {
    updateLayersGeometry()
    super.viewDidLayoutSubviews()
  }

  func setupChosenImage(_ image: UIImage) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.imageView.image = image
      self.findAreasOfInterest()
    }
  }

  private func configureContainerView() {
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
    let saliencyObjects = self.saliencyHandler.findAreasOfInterest(URL(string: "")!) ?? []
    DispatchQueue.main.async { [weak self] in
      self?.updatePathForSaliencyLayer(with: saliencyObjects)
    }
  }

  private func updatePathForSaliencyLayer(with rects: [CGRect]) {
    DispatchQueue.global(qos: .userInteractive).async {
      let path = self.saliencyHandler.createBoundingPathForSalientObjects(rects, transform: self.salientObjectsPathTransform, imageView: self.imageView)
      DispatchQueue.main.async {
        self.salientObjectsLayer.path = path
      }
    }
  }

  private func updateLayersGeometry() {
    salientObjectsLayer.frame = view.bounds
    let scaleT = CGAffineTransform(scaleX: salientObjectsLayer.bounds.width, y: -salientObjectsLayer.bounds.height)
    let translateT = CGAffineTransform(translationX: 0, y: salientObjectsLayer.bounds.height)
    salientObjectsPathTransform = scaleT.concatenating(translateT)
  }

  @objc private func rightBarButtonItemTapped() {
    // contentMode isn't animatable property
    let contentMode: UIView.ContentMode = imageView.contentMode == .scaleAspectFit ? .scaleAspectFill : .scaleAspectFit
    UIView.animate(withDuration: 0.3, animations: {
      self.imageView.contentMode = contentMode
    }, completion: { _ in
      self.findAreasOfInterest()
    })
  }
}
