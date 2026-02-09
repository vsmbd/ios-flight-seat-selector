//
//  SceneDelegate.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 08/02/26.
//

import UIKit
import UIKitCore

@available(iOS 13.0, *)
class SceneDelegate: CheckpointedSceneDelegate {
	override func scn(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = ViewController()
		window?.makeKeyAndVisible()
	}
}
