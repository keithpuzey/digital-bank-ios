//
//  LocationOutputView.swift
//  Digital Bank
//
//  Created by Keith Puzey on 4/8/24.
//

import UIKit
// Custom UIView subclass for formatted output
class LocationOutputView: UIView {
    private var iconImageView: UIImageView!

    init(icon: UIImage?) {
        super.init(frame: .zero)
        setupUI(icon: icon)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(icon: nil) // You can pass nil for the icon since it's not available from the storyboard/nib
    }

    private func setupUI(icon: UIImage?) {
        // Initialize and configure iconImageView
        iconImageView = UIImageView(image: icon)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        // Set constraints for iconImageView
        // You need to define constraints according to your UI layout
    }

    func updateOutput(with text: String) {
        // Update output text if needed
    }
}
