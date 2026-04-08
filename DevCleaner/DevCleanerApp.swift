import SwiftUI

@main
struct DevCleanerApp: App {
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.locale, localizationManager.locale)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            // Menülere özel komutlar
            CommandGroup(replacing: .newItem) {}  // "New" menüsünü gizle
            CommandMenu("Temizle") {
                Button("Tümünü Tara") {}
                    .keyboardShortcut("r", modifiers: .command)
            }
        }

        // Ayarlar sahnesi (⌘,)
        Settings {
            SettingsView()
                .environment(\.locale, localizationManager.locale)
        }
    }
}
