import SwiftUI

struct ContentView: View {
    @EnvironmentObject var repository: PlanRepository

    var body: some View {
        TabView {
            KlassenView()
                .tabItem {
                    Label("Klassen", systemImage: "person.3")
                }

            PlanungView()
                .tabItem {
                    Label("Planung", systemImage: "calendar")
                }

            NotizenView()
                .tabItem {
                    Label("Notizen", systemImage: "note.text")
                }
        }
        .overlay(alignment: .top) {
            if repository.iCloudVerfuegbar {
                iCloudBadge()
            }
        }
    }
}

private struct iCloudBadge: View {
    @State private var sichtbar = true

    var body: some View {
        if sichtbar {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.icloud.fill")
                    .foregroundStyle(.white)
                Text("iCloud aktiv")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.85), in: Capsule())
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { sichtbar = false }
                }
            }
        }
    }
}
