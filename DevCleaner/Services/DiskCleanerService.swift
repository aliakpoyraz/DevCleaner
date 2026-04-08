import Foundation

// MARK: - DiskCleanerService
/// Dosya silme işlemlerini yönetir.
/// İki mod desteklenir: çöp kutusuna taşı (güvenli) veya kalıcı sil.
actor DiskCleanerService {

    enum DeleteMode {
        case trash      // Varsayılan — FileManager.trashItem
        case permanent  // FileManager.removeItem
    }

    // MARK: - Toplu Silme
    func clean(
        urls: [URL],
        mode: DeleteMode,
        progressHandler: ((URL) -> Void)? = nil
    ) async -> (deleted: Int64, errors: [String]) {
        var totalDeleted: Int64 = 0
        var errors: [String] = []

        for url in urls {
            progressHandler?(url)
            do {
                let size = (try? await FileScanner().calculateSize(at: url)) ?? 0

                switch mode {
                case .trash:
                    try FileManager.default.trashItem(at: url, resultingItemURL: nil)
                case .permanent:
                    try FileManager.default.removeItem(at: url)
                }

                totalDeleted += size
            } catch {
                errors.append("\(url.lastPathComponent): \(error.localizedDescription)")
            }
        }

        return (totalDeleted, errors)
    }

    // MARK: - Çöp Kutusunu Boşalt
    /// ~/.Trash altındaki tüm öğeleri doğrudan siler (macOS 10.11+ uyumlu)
    func emptyTrash() async -> (deleted: Int64, errors: [String]) {
        let trashURL = Constants.Paths.trash
        let fm = FileManager.default

        guard let items = try? fm.contentsOfDirectory(
            at: trashURL,
            includingPropertiesForKeys: [.fileSizeKey],
            options: []
        ) else { return (0, []) }

        let result = await clean(urls: items, mode: .permanent)
        return result
    }

    // MARK: - Tek Öğe Sil
    func delete(url: URL, mode: DeleteMode) async throws {
        switch mode {
        case .trash:
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        case .permanent:
            try FileManager.default.removeItem(at: url)
        }
    }
}
