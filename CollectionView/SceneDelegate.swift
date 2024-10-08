//
//  SceneDelegate.swift
//  CollectionView
//
//  Created by Steven Kirke on 24.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let scene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: scene)
		self.window = window
		let navigationController = MainViewController()
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}
}
