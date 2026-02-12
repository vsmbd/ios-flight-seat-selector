//
//  AircraftListViewController.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit
import UIKitCore

// MARK: - AircraftListViewController

/// First screen: list of supported aircrafts. User selects one (later navigates to seat map).
final class AircraftListViewController: CheckpointedViewController {
	// MARK: + Private scope

	private lazy var tableView: CheckpointedTableView = {
		let table = self.table(id: "aircraft-list")
		table.delegate = self
		table.dataSource = self
		table.register(
			UITableViewCell.self,
			forCellReuseIdentifier: Self.cellReuseId
		)
		return table
	}()

	private static let cellReuseId = "AircraftCell"

	private var aircrafts: [Aircraft] = Aircraft.supported

	// MARK: + Overrides

	override func vcLoadView() {
		super.vcLoadView()
		view.embed(tableView)
	}

	override func vcViewDidLoad() {
		super.vcViewDidLoad()
		title = "Select aircraft"
		navigationController?.navigationBar.prefersLargeTitles = true
	}
}

// MARK: - UITableViewDataSource

extension AircraftListViewController: UITableViewDataSource {
	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		aircrafts.count
	}

	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: Self.cellReuseId,
			for: indexPath
		)
		let item = aircrafts[indexPath.row]
		cell.textLabel?.text = item.displayName
		cell.accessoryType = .disclosureIndicator
		return cell
	}
}

// MARK: - UITableViewDelegate

extension AircraftListViewController: UITableViewDelegate {
	func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		tableView.deselectRow(at: indexPath, animated: true)
		let selectedAircraft = aircrafts[indexPath.row]
		let cabinVC = CabinViewController(aircraft: selectedAircraft)
		navigationController?.pushViewController(cabinVC, animated: true)
	}
}
