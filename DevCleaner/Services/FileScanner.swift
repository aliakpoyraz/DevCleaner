import Foundation

// MARK: - FileScanner
/// Genel amaçlı async dosya tarayıcı.
/// Task.detached kullanarak UI thread'ini asla bloklamaz.
actor FileScanner {

    // MARK: - Recursive Boyut Hesaplama
    /// Verilen URL'deki tüm dosyaların toplam boyutunu hesaplar.
    func calculateSize(at url: URL) async throws -> Int64 {
        // DirectoryEnumerator'ın makeIterator'ı async context'te kullanılamaz.
        // Bu yüzden hesaplamayı Task.detached içinde sync olarak çalıştırıyoruz.
        return try await Task.detached(priority: .utility) {
            try Self.calculateSizeSync(at: url)
        }.value
    }

    // MARK: - Sync boyut hesaplama (Task.detached içinde çağrılır)
    private static func calculateSizeSync(at url: URL) throws -> Int64 {
        let fm = FileManager.default

        guard fm.fileExists(atPath: url.path) else { return 0 }

        var isDir: ObjCBool = false
        fm.fileExists(atPath: url.path, isDirectory: &isDir)

        if !isDir.boolValue {
            let attrs = try fm.attributesOfItem(atPath: url.path)
            return (attrs[.size] as? Int64) ?? 0
        }

        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return 0 }

        var total: Int64 = 0
        // NSEnumerator.nextObject() kullanıyoruz (Sequence.makeIterator değil)
        while let fileURL = enumerator.nextObject() as? URL {
            let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            guard resourceValues?.isRegularFile == true else { continue }
            total += Int64(resourceValues?.fileSize ?? 0)
        }
        return total
    }

    // MARK: - Dizin İçeriğini Listele
    func listTopLevelItems(at url: URL) -> [URL] {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return items
    }

    // MARK: - Yol Güvenlik Kontrolü
    func isPathSafe(_ url: URL) -> Bool {
        let path = url.path
        for blocked in Constants.systemBlacklist {
            if path.hasPrefix(blocked) { return false }
        }
        return true
    }
}
