import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {

    @AppStorage(Constants.UserDefaultsKeys.useTrash) var useTrash: Bool = true
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Label("Ayarlar", systemImage: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button("Kapat") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // İçerik
            Form {
                Section("Silme Modu") {
                    Toggle(isOn: $useTrash) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Çöp Kutusuna Taşı")
                                .font(.system(size: 13, weight: .medium))
                            Text("Kapatırsanız dosyalar kalıcı olarak silinir.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Hakkında") {
                    LabeledContent("Versiyon", value: "1.0.0")
                    LabeledContent("Geliştirici", value: "Ali Akpoyraz")
                    Link("GitHub'da Görüntüle",
                         destination: URL(string: "https://github.com/aliakpoyraz/DevCleaner")!)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 420, height: 400)
    }
}
