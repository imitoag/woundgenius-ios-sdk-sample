//
//  TherapyCategoryRowView.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import UIKit

/// One of the five first-level rows on the Therapy card.
/// Trailing states: count (pink "N item / items"), Genius pill (AI suggestion available), or plain chevron.
final class TherapyCategoryRowView: UIView {

    enum Trailing: Equatable {
        case count(Int)
        case geniusSuggestion
        case none
    }

    private let labelView = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let countLabel = UILabel()
    private let geniusPill = GeniusPillView()
    private let trailingContainer = UIStackView()
    private let separator = UIView()
    var onTap: (() -> Void)?

    init(title: String, trailing: Trailing) {
        super.init(frame: .zero)
        setup()
        configure(title: title, trailing: trailing)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .systemBackground

        labelView.font = .systemFont(ofSize: 17, weight: .regular)
        labelView.textColor = .label

        let chevronConfig = UIImage.SymbolConfiguration(textStyle: .body, scale: .small)
            .applying(UIImage.SymbolConfiguration(weight: .semibold))
        chevron.preferredSymbolConfiguration = chevronConfig
        chevron.tintColor = .tertiaryLabel

        countLabel.font = .systemFont(ofSize: 15, weight: .regular)
        countLabel.textColor = UIColor.imPink
        countLabel.isHidden = true

        geniusPill.isHidden = true

        trailingContainer.axis = .horizontal
        trailingContainer.alignment = .center
        trailingContainer.spacing = 8
        trailingContainer.addArrangedSubview(countLabel)
        trailingContainer.addArrangedSubview(geniusPill)
        trailingContainer.addArrangedSubview(chevron)

        labelView.translatesAutoresizingMaskIntoConstraints = false
        trailingContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelView)
        addSubview(trailingContainer)

        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            trailingContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    func configure(title: String, trailing: Trailing) {
        labelView.text = title
        switch trailing {
        case .count(let n):
            countLabel.text = String(format: L.str(n == 1 ? "THERAPY_COUNT_ITEM_ONE" : "THERAPY_COUNT_ITEM_MANY"), n)
            countLabel.isHidden = false
            geniusPill.isHidden = true
        case .geniusSuggestion:
            countLabel.isHidden = true
            geniusPill.isHidden = false
        case .none:
            countLabel.isHidden = true
            geniusPill.isHidden = true
        }
    }

    func hideSeparator(_ hide: Bool = true) { separator.isHidden = hide }

    @objc private func tapped() { onTap?() }
}
