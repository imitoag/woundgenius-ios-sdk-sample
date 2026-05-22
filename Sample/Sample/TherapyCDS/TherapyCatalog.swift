//
//  TherapyCatalog.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import Foundation

/// On-device catalogue of therapy products + the decision tree that maps the six CDS inputs
/// to a suggested item per slot. Bundled as `TherapyCatalog.json`.
struct TherapyCatalog: Decodable {
    let catalogueVersion: String
    let slotModel: [String: TherapySlotModel]
    let families: [String: TherapyFamily]
    let decisionTree: [TherapyDecisionRule]

    enum CodingKeys: String, CodingKey {
        case catalogueVersion = "catalogue_version"
        case slotModel = "slot_model"
        case families
        case decisionTree = "decision_tree"
    }

    /// The catalogue JSON stores family IDs as dictionary keys rather than as a field on each
    /// family. Decode raw, then write the key back into each `TherapyFamily.id` so downstream
    /// code (engine matcher, picker selections, PDF payload) can rely on `family.id` everywhere.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.catalogueVersion = try container.decode(String.self, forKey: .catalogueVersion)
        self.slotModel = try container.decode([String: TherapySlotModel].self, forKey: .slotModel)
        self.decisionTree = try container.decode([TherapyDecisionRule].self, forKey: .decisionTree)
        var rawFamilies = try container.decode([String: TherapyFamily].self, forKey: .families)
        for key in rawFamilies.keys {
            rawFamilies[key]?.id = key
        }
        self.families = rawFamilies
    }

    init(catalogueVersion: String, slotModel: [String: TherapySlotModel] = [:], families: [String: TherapyFamily], decisionTree: [TherapyDecisionRule]) {
        self.catalogueVersion = catalogueVersion
        self.slotModel = slotModel
        self.families = families
        self.decisionTree = decisionTree
    }

    static let shared: TherapyCatalog = {
        guard let url = Bundle.main.url(forResource: "TherapyCatalog", withExtension: "json") else {
            assertionFailure("TherapyCatalog.json missing from bundle")
            return TherapyCatalog(catalogueVersion: "0", families: [:], decisionTree: [])
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(TherapyCatalog.self, from: data)
        } catch {
            assertionFailure("TherapyCatalog decode failed: \(error)")
            return TherapyCatalog(catalogueVersion: "0", families: [:], decisionTree: [])
        }
    }()

    func families(forSlot slot: TherapySlot) -> [TherapyFamily] {
        families.values.filter { $0.slot == slot.rawValue }.sorted { $0.id < $1.id }
    }
}

struct TherapySlotModel: Decodable {
    let prefix: String
    let nullable: Bool
}

struct TherapyFamily: Decodable, Identifiable, Hashable {
    /// Catalogue stable ID (e.g. "PRM_005"). Written after decode from the parent dictionary key —
    /// the JSON doesn't carry it inside each family object.
    var id: String = ""
    let name: String
    let emdnCode: String?
    let slot: String
    let importance: String?
    let indication: String?
    let contraindications: String?
    let guidelines: String?

    enum CodingKeys: String, CodingKey {
        case name
        case emdnCode = "emdn_code"
        case slot
        case importance
        case indication
        case contraindications
        case guidelines
    }
}

/// Rule from `decision_tree[]`. A profile matches when every non-nil criterion equals the rule's
/// value (exception: `tissue` is an array, matches on non-empty intersection).
struct TherapyDecisionRule: Decodable {
    let conditionId: String
    let criteria: TherapyCriteria
    let therapy: TherapyRecommendation
    let evidence: TherapyEvidence?

    enum CodingKeys: String, CodingKey {
        case conditionId = "condition_id"
        case criteria, therapy, evidence
    }
}

struct TherapyCriteria: Decodable {
    let woundType: String?
    let bodyLocation: String?
    let depth: String?
    let exudate: String?
    let infection: String?
    let tissue: [String]?

    enum CodingKeys: String, CodingKey {
        case woundType = "wound_type"
        case bodyLocation = "body_location"
        case depth, exudate, infection, tissue
    }
}

struct TherapyRecommendation: Decodable {
    let primary: TherapyReference?
    let secondary: TherapyReference?
    let fixation: TherapyReference?
    let periwound: TherapyReference?
    let therapeutic: TherapyReference?
    let adjunctiveTherapy: String?
    let rationale: String?

    enum CodingKeys: String, CodingKey {
        case primary, secondary, fixation, periwound, therapeutic, rationale
        case adjunctiveTherapy = "adjunctive_therapy"
    }
}

struct TherapyReference: Decodable, Hashable {
    let id: String
    let name: String
}

struct TherapyEvidence: Decodable {
    let validationVerdict: String?
    let validationConfidence: Int?
    let isExpertOverride: Bool?

    enum CodingKeys: String, CodingKey {
        case validationVerdict = "validation_verdict"
        case validationConfidence = "validation_confidence"
        case isExpertOverride = "is_expert_override"
    }
}

/// The five slot families the suggestion engine emits. Raw values match `TherapyCatalog.families[].slot`.
enum TherapySlot: String, CaseIterable {
    case primary     = "primary"
    case secondary   = "secondary"
    case fixation    = "fixation"
    case periwound   = "periwound"
    case therapeutic = "therapeutic"

    var displayKey: String {
        switch self {
        case .primary:     return "THERAPY_CATEGORY_PRIMARY"
        case .secondary:   return "THERAPY_CATEGORY_SECONDARY"
        case .fixation:    return "THERAPY_CATEGORY_FIXATION"
        case .periwound:   return "THERAPY_CATEGORY_PERIWOUND"
        case .therapeutic: return "THERAPY_CATEGORY_THERAPEUTIC"
        }
    }

    /// Slot-level localization key for the row title in the PDF therapy section. Emitted with
    /// the `ma_` prefix applied at the call site (e.g. `"${ma_primary_dressing}"`). Values match
    /// the catalog's `slot_model` keys so backend translators can map 1:1. Paired POEditor
    /// entries are tagged `CDS` / `CDS:slot-title` in the main WoundGenius project.
    var backendSlotKey: String {
        switch self {
        case .primary:     return "primary_dressing"
        case .secondary:   return "secondary_dressing"
        case .fixation:    return "fixation"
        case .periwound:   return "periwound_care"
        case .therapeutic: return "therapeutic_system"
        }
    }
}
