//
//  TherapySuggestions.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import Foundation

/// Result of running the engine — one suggested item per slot (may be nil for nullable slots)
/// plus a reference to the matched rule for downstream persistence / PDF traceability.
struct TherapySuggestions {
    let matchedConditionId: String?
    let primary: TherapyReference?
    let secondary: TherapyReference?
    let fixation: TherapyReference?
    let periwound: TherapyReference?
    let therapeutic: TherapyReference?

    var anySuggestion: Bool {
        matchedConditionId != nil &&
            (primary != nil || secondary != nil || fixation != nil || periwound != nil || therapeutic != nil)
    }

    func suggestion(for slot: TherapySlot) -> TherapyReference? {
        switch slot {
        case .primary:     return primary
        case .secondary:   return secondary
        case .fixation:    return fixation
        case .periwound:   return periwound
        case .therapeutic: return therapeutic
        }
    }

    static let empty = TherapySuggestions(
        matchedConditionId: nil, primary: nil, secondary: nil,
        fixation: nil, periwound: nil, therapeutic: nil
    )
}

/// Narrow contract the engine needs from a catalog: just the rule set. Decouples
/// `TherapyEngine` from the concrete `TherapyCatalog` struct (DIP) so tests can feed a
/// single-rule fixture without having to build the 67-family catalog or stand up the
/// bundled JSON, and so alternate catalog sources (e.g. a remote-fetched decision tree)
/// can slot in behind the same engine.
protocol TherapyDecisionTreeProviding {
    var decisionTree: [TherapyDecisionRule] { get }
}

extension TherapyCatalog: TherapyDecisionTreeProviding {}

/// On-device matcher. AC 2.2: suggestions are only generated when all six inputs are present.
struct TherapyEngine {
    let catalog: TherapyDecisionTreeProviding

    init(catalog: TherapyDecisionTreeProviding = TherapyCatalog.shared) {
        self.catalog = catalog
    }

    func suggest(for inputs: TherapyInputs?) -> TherapySuggestions {
        guard let inputs = inputs, inputs.allPresent else { return .empty }

        let matches = catalog.decisionTree.filter { rule in Self.matches(rule.criteria, inputs: inputs) }
        guard let chosen = preferred(rules: matches) else { return .empty }

        let rec = chosen.therapy
        return TherapySuggestions(
            matchedConditionId: chosen.conditionId,
            primary:     rec.primary,
            secondary:   rec.secondary,
            fixation:    rec.fixation,
            periwound:   rec.periwound,
            therapeutic: rec.therapeutic
        )
    }

    /// Prefer rules with `validation_verdict == "PASS"`; otherwise first match wins.
    private func preferred(rules: [TherapyDecisionRule]) -> TherapyDecisionRule? {
        if let passed = rules.first(where: { $0.evidence?.validationVerdict == "PASS" }) {
            return passed
        }
        return rules.first
    }

    /// Every non-nil criterion must match. Tissue matches on non-empty intersection.
    static func matches(_ criteria: TherapyCriteria, inputs: TherapyInputs) -> Bool {
        if let w = criteria.woundType,    w != inputs.woundTypeForEngine { return false }
        if let b = criteria.bodyLocation, b != inputs.bodyLocation { return false }
        if let d = criteria.depth,        d != inputs.depth        { return false }
        if let e = criteria.exudate,      e != inputs.exudate      { return false }
        if let i = criteria.infection,    i != inputs.infection    { return false }
        if let t = criteria.tissue, !t.isEmpty {
            let overlap = !Set(t).isDisjoint(with: inputs.tissue)
            if !overlap { return false }
        }
        return true
    }
}
