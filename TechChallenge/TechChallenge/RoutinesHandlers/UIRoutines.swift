//
//  UIRoutines.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/28/22.
//

import UIKit

func imageScale(of imageView: UIImageView) -> CGFloat {
  guard let image = imageView.image else { return 1 }

  let imageViewHeight = imageView.bounds.height
  let imageViewWidth = imageView.bounds.width
  let scaledImageHeight = min(image.size.height * (imageViewWidth / image.size.width), imageViewHeight)
  let ratio = scaledImageHeight / imageView.bounds.height

  return ratio
}
