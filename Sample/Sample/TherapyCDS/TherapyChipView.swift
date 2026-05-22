//
//  TherapyChipView.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import UIKit

/// One of the six CDS input chips on the Therapy card — label on top, value on bottom.
/// Unfilled state shows a pink "Select" CTA in place of the value.
final class TherapyChipView: UIView {

    enum State: Equatable {
        case filled(value: String)
        case empty
    }

    private let stack = UIStackView()
    private let labelView = UILabel()
    private let valueView = UILabel()
    var onTap: (() -> Void)?

    init(label: String, state: State) {
        super.init(frame: .zero)
        setup()
        configure(label: label, state: state)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = 12
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 1
        backgroundColor = .systemBackground

        labelView.font = .systemFont(ofSize: 11, weight: .regular)
        labelView.textColor = .secondaryLabel
        valueView.font = .systemFont(ofSize: 13, weight: .semibold)
        valueView.numberOfLines = 1

        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.addArrangedSubview(labelView)
        stack.addArrangedSubview(valueView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    func configure(label: String, state: State) {
        labelView.text = label
        switch state {
        case .filled(let value):
            valueView.text = value
            valueView.textColor = .label
        case .empty:
            valueView.text = L.str("THERAPY_CHIP_SELECT_ACTION")
            valueView.textColor = UIColor.imPink
        }
    }

    @objc private func tapped() { onTap?() }
}
