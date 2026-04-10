# Unterrichtsplaner iOS

Native Apple-Version des Unterrichtsplaners als SwiftUI-App für iPhone und iPad.

## Ziel
Diese App bildet die Weblösung als reine Apple-App nach – mit einer Apple-typischen Bedienung, lokaler Datenspeicherung und einer klaren Struktur für Unterricht, Klassen, Stunden und Notizen.

## Funktionsumfang
- Übersicht über Klassen und Unterrichtseinheiten
- Thema, Notiz und Status pro Klasse
- Stundenplanung
- **Lokale Speicherung + automatischer iCloud-Sync** ✓

## iCloud-Sync Einrichtung (Xcode)

Der Sync läuft über `NSUbiquitousKeyValueStore` – kein CloudKit-Container nötig.

### Schritte in Xcode:
1. Projekt öffnen → Target auswählen → **Signing & Capabilities**
2. **+ Capability** → **iCloud** hinzufügen
3. Unter iCloud: Haken bei **Key-value storage** setzen
4. Entitlements-Datei `Unterrichtsplaner.entitlements` ist bereits vorbereitet

### So funktioniert der Sync:
- Daten werden bei jeder Änderung lokal (UserDefaults) **und** in iCloud gespeichert
- Auf anderen Geräten (iPhone, iPad, Mac) werden Änderungen automatisch empfangen
- Bei der ersten App-Öffnung werden iCloud-Daten bevorzugt geladen
- Ein blaues „iCloud aktiv"-Badge erscheint beim Start wenn iCloud verfügbar ist

## Technischer Ansatz
- SwiftUI
- `NSUbiquitousKeyValueStore` für iCloud Key-Value-Sync
- `UserDefaults` als lokaler Fallback
- NavigationStack / TabView
- iPhone- und iPad-optimiert

## Projektstruktur
- `UnterrichtsplanerApp.swift` – Einstiegspunkt, erstellt `PlanRepository`
- `Models/` – Datenmodelle (`PlanEintrag`, `PlanStatus`, …)
- `Views/` – SwiftUI-Ansichten
- `Services/PlanRepository.swift` – Datenpersistenz + iCloud-Sync
- `Unterrichtsplaner.entitlements` – iCloud-Berechtigung
