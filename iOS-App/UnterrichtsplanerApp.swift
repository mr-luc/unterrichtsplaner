import SwiftUI

@main
struct UnterrichtsplanerApp: App {
    @StateObject private var repository = PlanRepository()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repository)
        }
    }
}
