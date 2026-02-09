//
//  AppDelegate.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 08/02/26.
//

import UIKit
import UIKitCore

@main
class AppDelegate: CheckpointedAppDelegate {
	override func initialize() {
		super.initialize()
	}

	override func app(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		if #available(iOS 13.0, *) {
			return true  // window created by SceneDelegate
		}

		// iOS 12: create window here
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = ViewController()
		window?.makeKeyAndVisible()

		return super.app(
			application,
			didFinishLaunchingWithOptions: launchOptions
		)
	}

	@available(iOS 13.0, *)
	override func app(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		let config = UISceneConfiguration(
			name: "Main",
			sessionRole: connectingSceneSession.role
		)
		config.delegateClass = SceneDelegate.self
		return config
	}

	@available(iOS 13.0, *)
	override func app(
		_ application: UIApplication,
		didDiscardSceneSessions sceneSessions: Set<UISceneSession>
	) {
		super.app(
			application,
			didDiscardSceneSessions: sceneSessions
		)
	}
}
