//
//  Array+Utilities.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/28/22.
//

import Foundation

extension Array {
  subscript(safe index: Index) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}
