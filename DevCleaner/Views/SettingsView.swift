import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {

    @StateObject private var locManager = LocalizationManager.shared
    @AppStorage(Constants.UserDefaultsKeys.useTrash) var useTrash: Bool = true
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Label("Settings", systemImage: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // İçerik
            Form {
                Section(header: Text("Language")) {
                    Picker("Language", selection: $locManager.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Delete Mode")) {
                    Toggle(isOn: $useTrash) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Move to Trash")
                                .font(.system(size: 13, weight: .medium))
                            Text("If turned off, files will be permanently deleted.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("About")) {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Developer", value: "Ali Akpoyraz")
                    Link("View on GitHub",
                         destination: URL(string: "https://github.com/aliakpoyraz/DevCleaner")!)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 420, height: 400)
        .id(locManager.locale.identifier)
        .environment(\.locale, locManager.locale)
    }
}
