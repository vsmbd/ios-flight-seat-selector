//
//  AircraftViewController.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit
import UIKitCore

// MARK: - AircraftViewController

final class AircraftViewController: CheckpointedViewController {
	// MARK: + Private scope

	private let aircraft: Aircraft

	private let aircraftView: AircraftView

	// MARK: + Default scope

	init(aircraft: Aircraft) {
		self.aircraft = aircraft
		self.aircraftView = AircraftView(aircraft: aircraft)
		super.init(viewId: "cabin-\(aircraft.model)")
	}

	@MainActor
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func vcLoadView() {
		super.vcLoadView()

		if #available(iOS 13.0, *) {
			view.backgroundColor = .systemBackground
		} else {
			view.backgroundColor = .white
		}

		view.embed(aircraftView)
	}

	override func vcViewDidLoad() {
		super.vcViewDidLoad()
		title = "\(aircraft.displayName) - Select Seat"
		navigationController?.navigationBar.prefersLargeTitles = false
	}
}
