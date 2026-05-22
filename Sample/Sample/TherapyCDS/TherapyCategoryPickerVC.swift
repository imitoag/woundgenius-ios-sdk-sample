//
//  TherapyCategoryPickerVC.swift
//  WoundGeniusApp
//
//  Created by Petro Kulakov on 17.04.2026.
//

import UIKit

/// Second-level picker for a single therapy slot. Grouped UITableView with two sections:
///   1. "Suggested" — the engine's per-slot recommendation (shown only when a suggestion exists)
///   2. "All <category>" — every other family in the slot
///
/// Multi-select. Selections are returned via `onDone` on dismissal (pop / back button).
/// AC 7.10 (contra-indications) deliberately not rendered — out of MVP scope.
final class TherapyCategoryPickerVC: UITableViewController {

    private let slot: TherapySlot
    private let suggested: TherapyReference?
    private let suggestedFamily: TherapyFamily?
    private let allFamilies: [TherapyFamily]
    private var picked: Set<String>
    var onDone: ((Set<String>) -> Void)?

    private let reuseId = "cell"
    private static let suggestedSectionTitleKey = "THERAPY_PICKER_SUGGESTED_HEADER"

    init(slot: TherapySlot,
         catalog: TherapyCatalog,
         suggested: TherapyReference?,
         preselected: Set<String>) {
        self.slot = slot
        self.suggested = suggested
        self.suggestedFamily = suggested.flatMap { catalog.families[$0.id] }
        // Everything in this slot, minus the suggested one (it lives in its own section).
        self.allFamilies = catalog.families(forSlot: slot)
            .filter { $0.id != suggested?.id }
        self.picked = preselected
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L.str(slot.displayKey)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.allowsMultipleSelection = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onDone?(picked)
        }
    }

    // MARK: - Data source

    private var hasSuggestedSection: Bool { suggestedFamily != nil }

    override func numberOfSections(in tableView: UITableView) -> Int {
        hasSuggestedSection ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasSuggestedSection && section == 0 { return 1 }
        return allFamilies.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if hasSuggestedSection && section == 0 { return L.str(Self.suggestedSectionTitleKey) }
        return String(format: L.str("THERAPY_PICKER_ALL_HEADER"), L.str(slot.displayKey))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        let family = self.family(at: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = family.name
        config.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
        if hasSuggestedSection && indexPath.section == 0 {
            config.textProperties.color = UIColor.imPink
        }
        cell.contentConfiguration = config
        cell.accessoryType = picked.contains(family.id) ? .checkmark : .none
        cell.tintColor = UIColor.imPink
        return cell
    }

    // MARK: - Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let family = self.family(at: indexPath)
        if picked.contains(family.id) {
            picked.remove(family.id)
        } else {
            picked.insert(family.id)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func family(at indexPath: IndexPath) -> TherapyFamily {
        if hasSuggestedSection && indexPath.section == 0 {
            return suggestedFamily!
        }
        return allFamilies[indexPath.row]
    }
}
