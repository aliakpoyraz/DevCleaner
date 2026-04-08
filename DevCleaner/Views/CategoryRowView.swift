import SwiftUI

// MARK: - CategoryRowView
/// Her temizlik kategorisi için tek satır bileşeni.
struct CategoryRowView: View {

    let category: CleanupCategory
    let onToggle: () -> Void
    let onScan: () async -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 14) {

            // Checkbox + İkon
            HStack(spacing: 10) {
                Image(systemName: category.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(category.isSelected ? category.color : .secondary)
                    .animation(.spring(response: 0.25), value: category.isSelected)
                    .onTapGesture { onToggle() }

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(category.color.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(category.color)
                }
            }

            // Kategori Bilgisi
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Text(category.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Boyut + Durum
            VStack(alignment: .trailing, spacing: 2) {
                sizeLabel
                statusBadge
            }

            // Tara Butonu
            Button {
                Task { await onScan() }
            } label: {
                Text(category.status == .done ? "Yeniden Tara" : "Tara")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(isHovered ? 0.25 : 0.12))
                    .foregroundColor(.accentColor)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(category.status == .scanning)
            .onHover { isHovered = $0 }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered ? Color(.controlBackgroundColor).opacity(0.8) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    // MARK: - Sub Views
    @ViewBuilder
    private var sizeLabel: some View {
        switch category.status {
        case .scanning:
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 60)
        case .done:
            Text(FileSizeFormatter.string(from: category.scannedSize))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(category.scannedSize > 1_000_000_000 ? .red : .primary)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
        default:
            Text("—")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch category.status {
        case .done:
            Label("Hazır", systemImage: "checkmark")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.green)
        case .error(let msg):
            Label("Hata", systemImage: "exclamationmark.triangle")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.orange)
                .help(msg)
        default:
            EmptyView()
        }
    }
}
