//
//  GeniusPillView.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import UIKit

/// The pink-to-orange "+ Genius" capsule badge. Rendered in code so it scales with Dynamic Type
/// and needs no asset round-trip. Used on the Therapy row in Additional Info and on any
/// Therapy-category row whose slot has AI-generated suggestions.
final class GeniusPillView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // Pink → orange horizontal gradient matching Sketch — values eyed from the export until
        // design supplies exact hex. Left=pink #FF3366, right=orange #FF9933.
        gradientLayer.colors = [
            UIColor(red: 1.00, green: 0.20, blue: 0.40, alpha: 1.0).cgColor,
            UIColor(red: 1.00, green: 0.60, blue: 0.20, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.masksToBounds = true

        // NSTextAttachment (rather than a sibling UIImageView) so the sparkle scales with
        // the label's font if the copy ever switches to Dynamic Type.
        let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "sparkle")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        // y:-2 aligns the symbol's baseline with the label's (attachment sits on the line,
        // not the cap — without the offset the sparkle reads as floating above the text).
        attachment.bounds = CGRect(x: 0, y: -2, width: font.pointSize, height: font.pointSize)
        let attributed = NSMutableAttributedString(attachment: attachment)
        attributed.append(NSAttributedString(
            string: " Genius",
            attributes: [.font: font, .foregroundColor: UIColor.white]
        ))
        label.attributedText = attributed
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        // Capsule corner — match the shorter axis.
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    override var intrinsicContentSize: CGSize {
        let base = label.intrinsicContentSize
        return CGSize(width: base.width + 20, height: base.height + 10)
    }
}
