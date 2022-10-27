//
//  AssetPreviewCollectionViewCell.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit

class AssetPreviewCollectionViewCell: UICollectionViewCell {

  @IBOutlet var previewImageView: UIImageView!

  func update(with item: AssetPreviewCollectionViewCellModel) {
     previewImageView.image = item.thumbnailImage
  }

}
