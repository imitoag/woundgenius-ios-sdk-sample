//
//  TherapyInputMapping.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import Foundation

/// Translates SDK formsModel selectBox / pickerView keys into the human-readable values the
/// `TherapyCatalog.decision_tree` was authored against. `nil` → "missing input, rule does not match".
enum TherapyInputMapping {

    /// Aligned with decision_tree_1.7.3+e8132cd.json. Labels match the tree's `criteria.wound_type`.
    /// Where the SDK form has finer-grained options than the tree (acute/chronic burns, acute/chronic
    /// surgical wounds, individual atypicals), they collapse to the tree's consolidated label.
    static let woundType: [String: String] = [
        "ma_wound_type_pressure_ulcer_injury":              "Pressure Injury",
        "ma_wound_type_venous_leg_ulcer":                   "Venous Leg Ulcer",
        "ma_wound_type_arterial_leg_ulcer":                 "Arterial Leg Ulcer",
        "ma_wound_type_mixed_leg_ulcer":                    "Mixed Arterial Venous Leg Ulcer",
        "ma_wound_type_diabetic_foot":                      "Diabetic Foot Ulcer",
        "ma_wound_type_burn_acute":                         "Burn",
        "ma_wound_type_burn_chronic":                       "Burn",
        "ma_wound_type_postoperative_acute":                "Surgical Wound",
        "ma_wound_type_postoperative_chronic":              "Surgical Wound",
        "ma_wound_type_skin_tear":                          "Traumatic Wound",
        "ma_wound_type_traumatic":                          "Traumatic Wound",
        "ma_wound_type_malignant_fungating_wound":          "Malignant / Fungating Wound",
        // Atypical wounds — tree has a single catch-all.
        "ma_wound_type_pyoderma_gangrenosum":               "Other / Atypical Wound",
        "ma_wound_type_calciphylaxis":                      "Other / Atypical Wound",
        "ma_wound_type_hidradenitis_suppurativa":           "Other / Atypical Wound",
        "ma_wound_type_ecythma":                            "Other / Atypical Wound",
        "ma_wound_type_ecythma_gangrenosum":                "Other / Atypical Wound",
        "ma_wound_type_martorell_hytilu":                   "Other / Atypical Wound",
        "ma_wound_type_incontinence_associated_dermatitis": "Other / Atypical Wound"
    ]

    static let exudate: [String: String] = [
        "ma_exudate_amount_none":      "None",
        "ma_exudate_amount_light":     "Light",
        "ma_exudate_amount_moderate":  "Moderate",
        "ma_exudate_amount_high":      "High",
        "ma_exudate_amount_excessive": "Excessive"
    ]

    /// The binary infection pickerView — not the multi-select signs list.
    static let infection: [String: String] = [
        "ma_wound_is_infected_yes": "Yes",
        "ma_wound_is_infected_no":  "No"
        // ma_wound_is_infected_not_specified intentionally absent — treat as missing.
    ]

    static let tissue: [String: String] = [
        "ma_tissue_type_epithelialisation": "Epithelialisation",
        "ma_tissue_type_granulation":       "Granulation",
        "ma_tissue_type_fibrin":            "Fibrin",
        "ma_tissue_type_slough":            "Slough",
        "ma_tissue_type_necrosis":          "Necrosis",
        "ma_tissue_type_bone_or_tendon":    "Bone or Tendon"
    ]

    /// AC 3 skipped for MVP — relative depth derived from the measurement flow's mm value.
    static func depth(key: String) -> String? {
        switch key {
        case "ma_wound_depth_category_deep":
            return "Deep"
        case "ma_wound_depth_category_superficial":
            return "Superficial"
        default:
            return nil
        }
    }

    /// Loaded from `BodyRegionMap.json` at first access. 650+ granular UBPPSection keys → 7 regions.
    static let bodyRegion: [String: String] = {
        guard let url = Bundle.main.url(forResource: "BodyRegionMap", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            assertionFailure("BodyRegionMap.json missing or malformed")
            return [:]
        }
        return dict
    }()

    /// Aggregates a set of granular body-part IDs to a single region.
    /// If multiple regions are represented, falls back to the first one encountered —
    /// the decision tree matches a single location per rule.
    static func bodyLocation(fromGranularKeys keys: [String]) -> String? {
        for key in keys {
            if let region = bodyRegion[key] { return region }
        }
        return nil
    }
}

/// Inputs assembled from the formsModel + measurement capture before the engine runs.
///
/// `woundType` splits into two values because the SDK form offers finer-grained options than the
/// decision tree's ten consolidated buckets (e.g. the form has Pyoderma Gangrenosum / Calciphylaxis /
/// Martorell / etc. — the tree just has "Other / Atypical Wound"). The chip on screen must show
/// the diagnosis the user actually picked; the engine needs the collapsed label to match rules.
struct TherapyInputs {
    /// What the user picked in the wound_type form — e.g. "Pyoderma Gangrenosum". Renders on the
    /// Therapy card's Wound Type chip so the clinician sees their exact diagnosis.
    var woundTypeDisplay: String?
    /// Collapsed label that matches decision_tree `criteria.wound_type` — e.g. "Other / Atypical Wound".
    var woundTypeForEngine: String?
    var bodyLocation: String?
    var depth: String?          // "Superficial" / "Deep"
    var exudate: String?
    var infection: String?      // "Yes" / "No"
    var tissue: [String]        // decision_tree strings, multi

    init(woundTypeDisplay: String?, woundTypeForEngine: String?, bodyLocation: String?, depth: String?, exudate: String?, infection: String?, tissue: [String]) {
        self.woundTypeDisplay = woundTypeDisplay
        self.woundTypeForEngine = woundTypeForEngine
        self.bodyLocation = bodyLocation
        self.depth = depth
        self.exudate = exudate
        self.infection = infection
        self.tissue = tissue
    }
    
    /// True when every criterion is populated — a prerequisite for any suggestion match.
    var allPresent: Bool {
        woundTypeForEngine != nil && bodyLocation != nil && depth != nil &&
        exudate != nil && infection != nil && !tissue.isEmpty
    }
}
