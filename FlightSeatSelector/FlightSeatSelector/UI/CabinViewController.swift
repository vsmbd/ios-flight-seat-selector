//
//  CabinViewController.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit
import UIKitCore

// MARK: - CabinViewController

final class CabinViewController: CheckpointedViewController {
	// MARK: + Private scope
	
	private let aircraft: Aircraft
	private let cabinLayout: CabinLayout
	
	private lazy var cabinView: AircraftCabinView = {
		let view = AircraftCabinView(layout: cabinLayout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		if #available(iOS 13.0, *) {
			view.backgroundColor = .systemBackground
		}
		view.onSeatSelected = { [weak self] seatId in
			self?.handleSeatSelection(seatId)
		}
		return view
	}()
	
	private lazy var headerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var confirmButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Confirm Selection", for: .normal)
		btn.setTitleColor(.white, for: .normal)
		btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
		btn.backgroundColor = .systemGreen
		btn.layer.cornerRadius = 12
		btn.layer.shadowColor = UIColor.black.cgColor
		btn.layer.shadowOffset = CGSize(width: 0, height: 4)
		btn.layer.shadowRadius = 8
		btn.layer.shadowOpacity = 0.2
		btn.alpha = 0
		btn.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)
		return btn
	}()
	
	private var selectedSeatId: String?
	
	// MARK: + Init
	
	init(aircraft: Aircraft) {
		self.aircraft = aircraft
		self.cabinLayout = .a320() // Load based on aircraft type
		super.init(viewId: "cabin-\(aircraft.model)")
	}

	@MainActor
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: + Lifecycle
	
	override func vcLoadView() {
		super.vcLoadView()
		
		// Set background
		if #available(iOS 13.0, *) {
			view.backgroundColor = .systemBackground
		} else {
			view.backgroundColor = .white
		}
		
		// Add cabin view
		view.add(cabinView)
		cabinView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		cabinView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		cabinView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		cabinView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		
		// Add confirm button
		view.add(confirmButton)
		confirmButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
		confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
		confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
		
		if #available(iOS 11.0, *) {
			confirmButton.bottomAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.bottomAnchor,
				constant: -20
			).isActive = true
		} else {
			confirmButton.bottomAnchor.constraint(
				equalTo: bottomLayoutGuide.topAnchor,
				constant: -20
			).isActive = true
		}
	}
	
	override func vcViewDidLoad() {
		super.vcViewDidLoad()
		
		title = "\(aircraft.displayName) - Select Seat"
		navigationController?.navigationBar.prefersLargeTitles = false
		
		// Add reset button to nav bar
		let resetItem = UIBarButtonItem(
			title: "Reset",
			style: .plain,
			target: self,
			action: #selector(resetView)
		)
		navigationItem.rightBarButtonItem = resetItem
	}
	
	// MARK: + Actions
	
	private func handleSeatSelection(_ seatId: String?) {
		selectedSeatId = seatId
		
		// Animate confirm button
		UIView.animate(withDuration: 0.3) {
			self.confirmButton.alpha = seatId != nil ? 1.0 : 0.0
		}
	}
	
	@objc private func confirmSelection() {
		guard let seatId = selectedSeatId else { return }
		
		// Haptic feedback
		if #available(iOS 10.0, *) {
			let generator = UINotificationFeedbackGenerator()
			generator.notificationOccurred(.success)
		}
		
		// Show confirmation
		let alert = UIAlertController(
			title: "Seat Confirmed",
			message: "You selected seat \(seatId)",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			self?.navigationController?.popViewController(animated: true)
		})
		present(alert, animated: true)
	}
	
	@objc private func resetView() {
		cabinView.resetView()
	}
}
