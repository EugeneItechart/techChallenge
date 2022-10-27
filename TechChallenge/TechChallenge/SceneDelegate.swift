//
//  SceneDelegate.swift
//  TechChallenge
//
//  Created by Eugene Bessilko on 10/27/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    let rootViewController = UINavigationController(rootViewController: AssetsListViewController())
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    self.window = window
  }

}
