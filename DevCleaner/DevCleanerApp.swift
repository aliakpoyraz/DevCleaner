import SwiftUI

@main
struct DevCleanerApp: App {

    var body: some Scene {
        WindowGroup {
            HomeView()
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
        }
    }
}
