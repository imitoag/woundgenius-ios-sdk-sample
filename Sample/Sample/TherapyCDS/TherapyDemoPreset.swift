//
//  TherapyDemoPreset.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import Foundation

/// DMEA demo data — pre-fills the six CDS inputs so the Therapy screen always lands on the
/// happy path, matching `decision_tree` rule 0 (Pressure Injury / Sacral / Deep / Light / No / [Necrosis]).
/// Applied from `CardsPresenter` when `WG.appEnvironment() == .dev` (staging build).
enum TherapyDemoPreset {

    /// Hardcoded TherapyInputs that exactly match the first demo rule → guaranteed suggestions.
    static let inputs = TherapyInputs(
        woundTypeDisplay: "Pressure Injury",
        woundTypeForEngine: "Pressure Injury",
        bodyLocation: "Sacral / Pelvic Area",
        depth: "Deep",
        exudate: "Light",
        infection: "No",
        tissue: ["Necrosis"]
    )

    /// Fallback wound-depth value (in mm) for rigs where the user hasn't captured a measurement.
    /// ≥ 5 mm so the derivation lands on "Deep", matching the preset.
    static let fallbackDepthMillimetres: Double = 7.0
}
