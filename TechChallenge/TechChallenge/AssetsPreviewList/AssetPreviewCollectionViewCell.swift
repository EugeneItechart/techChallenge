//
//  AssetPreviewCollectionViewCell.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit

class AssetPreviewCollectionViewCell: UICollectionViewCell {

  let thumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.backgroundColor = .white
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()

  func update(with image: UIImage?) {
    thumbnailImageView.image = image
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    contentView.contentMode = .scaleAspectFill
    addSubview(thumbnailImageView)

    NSLayoutConstraint.activate([
      thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
      thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
      thumbnailImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor)
    ])
    setNeedsLayout()
  }

}
