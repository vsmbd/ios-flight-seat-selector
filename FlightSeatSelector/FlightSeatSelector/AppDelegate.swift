//
//  AppDelegate.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 08/02/26.
//

import UIKit
import UIKitCore
import SwiftCore
import JSON
import HTTPCore
import URLSessionHTTPClient
import Telme
import TelmeSinks

@main
class AppDelegate: CheckpointedAppDelegate {
	// MARK: + Private scope

	private var telmeRecordSink: TelmeRecordSink!

	// MARK: + Default scope

	override func initialize() {
		super.initialize()

		let baselineWallNanos = Int(truncatingIfNeeded: timeInfo.baselineWall.unixEpochNanoseconds)
		let baselineMonotonicNanos = Int(truncatingIfNeeded: timeInfo.baselineMonotonic.nanoseconds)

		let sessionJSON: [String: JSON] = [
			"session_id": .string(sessionId.uuidString),

			"bundle_id": .string(appInfo.bundleId),
			"app_version": .string(appInfo.appVersion),
			"install_id": .string(appInfo.installId.uuidString),

			"device_os": .string(deviceInfo.osName),
			"device_os_version": .string(deviceInfo.osVersion),
			"device_hardware_model": .string(deviceInfo.hardwareModel),
			"device_manufacturer": .string(deviceInfo.manufacturer),

			"baseline_wall_nanos": .int(baselineWallNanos),
			"baseline_mono_nanos": .int(baselineMonotonicNanos),
			"timezone_offset_sec": .int(Int(timeInfo.timezoneOffsetSeconds)),
		]

		if let url = URL(string: "https://sees-investigated-ham-nations.trycloudflare.com/telme/ingest") {
			let clickHouseSink = ClickHouseTelmeSink(
				http: URLSessionHTTPClient(session: .shared),
				config: .init(
					endpoint: url,
					session: sessionJSON
				)
			)

			Telme.default.addRecordSink(clickHouseSink)
			telmeRecordSink = clickHouseSink
		}
	}

	override func app(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		let superResult = super.app(
			application,
			didFinishLaunchingWithOptions: launchOptions
		)

		if #available(iOS 13.0, *) {
			// window will be created by SceneDelegate
			return superResult
		}

		// iOS 12: create window here
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = ViewController()
		window?.makeKeyAndVisible()

		return superResult
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
}
