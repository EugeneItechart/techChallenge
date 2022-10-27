//
//  ContentModeAnimatableView.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit

class ContentModeAnimatableView: UIView {

  var image: UIImage? {
    get { return imageView.image }
    set {
      imageView.image = newValue
      setNeedsLayout()
    }
  }

  private let imageView = UIImageView()

  public init() {
    super.init(frame: .zero)

    addSubview(imageView)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layoutImageView()
  }

  override var contentMode: UIView.ContentMode {
    didSet { layoutImageView() }
  }

  private func layoutImageView() {
    guard let image = imageView.image else { return }

    if contentMode == .scaleAspectFit {
      layoutAspectFit(image: image)
    } else if contentMode == .scaleAspectFill {
      layoutAspectFill(image: image)
    }
  }

  private func imageToBoundsWidthRatio(image: UIImage) -> CGFloat  {
    return image.size.width / bounds.size.width
  }

  private func imageToBoundsHeightRatio(image: UIImage) -> CGFloat {
    return image.size.height / bounds.size.height
  }

  private func imageViewBoundsToSize(size: CGSize) {
    imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
  }

  private func centerImageView() {
    imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
  }

  private func layoutAspectFit(image: UIImage) {
    let widthRatio = imageToBoundsWidthRatio(image: image)
    let heightRatio = imageToBoundsHeightRatio(image: image)
    let size = CGSize(width: image.size.width / max(widthRatio, heightRatio),
                      height: image.size.height / max(widthRatio, heightRatio))
    imageViewBoundsToSize(size: size)
    centerImageView()
  }

  private func layoutAspectFill(image: UIImage) {
    let widthRatio = imageToBoundsWidthRatio(image: image)
    let heightRatio = imageToBoundsHeightRatio(image: image)
    let size = CGSize(width: image.size.width / min(widthRatio, heightRatio),
                      height: image.size.height / min(widthRatio, heightRatio))
    imageViewBoundsToSize(size: size)
    centerImageView()
  }

}
