import Foundation
import Combine

/// Zentrales Daten-Repository mit automatischem iCloud-Sync
/// via NSUbiquitousKeyValueStore + lokalem UserDefaults-Fallback.
class PlanRepository: ObservableObject {
    @Published var daten: [String: PlanEintrag] = [:]
    @Published var iCloudVerfuegbar: Bool = false

    private let storageKey = "up_plan_daten"
    private let iCloud = NSUbiquitousKeyValueStore.default

    init() {
        iCloudVerfuegbar = FileManager.default.ubiquityIdentityToken != nil
        laden()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudGeaendert(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloud
        )
        iCloud.synchronize()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: – Lesen

    func eintrag(fach: String, klasse: String) -> PlanEintrag {
        let key = "\(fach)_\(klasse)"
        return daten[key] ?? PlanEintrag(fach: fach, klasse: klasse)
    }

    // MARK: – Schreiben

    func speichern(_ eintrag: PlanEintrag) {
        daten[eintrag.key] = eintrag
        sichern()
    }

    func alleZuruecksetzen() {
        daten = [:]
        sichern()
    }

    // MARK: – Persistenz

    private func laden() {
        // iCloud bevorzugen, sonst UserDefaults
        let rohdaten: Data?
        if let ckData = iCloud.data(forKey: storageKey), !ckData.isEmpty {
            rohdaten = ckData
        } else {
            rohdaten = UserDefaults.standard.data(forKey: storageKey)
        }
        guard let data = rohdaten,
              let decoded = try? JSONDecoder().decode([String: PlanEintragData].self, from: data)
        else { return }
        DispatchQueue.main.async {
            self.daten = decoded.mapValues { $0.toPlanEintrag() }
        }
    }

    private func sichern() {
        let codable = daten.mapValues { PlanEintragData(from: $0) }
        guard let data = try? JSONEncoder().encode(codable) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        iCloud.set(data, forKey: storageKey)
        iCloud.synchronize()
    }

    @objc private func iCloudGeaendert(_ notification: Notification) {
        guard let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
              [NSUbiquitousKeyValueStoreServerChange,
               NSUbiquitousKeyValueStoreInitialSyncChange].contains(reason)
        else { return }
        DispatchQueue.main.async { self.laden() }
    }
}

// MARK: – Codable-Hilfsstruct

private struct PlanEintragData: Codable {
    let fach: String
    let klasse: String
    let thema: String
    let notiz: String
    let status: String

    init(from e: PlanEintrag) {
        fach   = e.fach
        klasse = e.klasse
        thema  = e.thema
        notiz  = e.notiz
        status = e.status.rawValue
    }

    func toPlanEintrag() -> PlanEintrag {
        PlanEintrag(
            fach: fach, klasse: klasse, thema: thema, notiz: notiz,
            status: PlanStatus(rawValue: status) ?? .geplant
        )
    }
}
