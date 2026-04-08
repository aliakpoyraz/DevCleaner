import Foundation

// MARK: - NodeModulesScanner
/// Tüm kullanıcı dizinini tarayarak 30 günden eski node_modules klasörlerini bulur.
actor NodeModulesScanner {

    struct NodeModulesResult {
        let url: URL
        let size: Int64
        let lastAccessDate: Date
    }

    private let scanner = FileScanner()

    // MARK: - Ana Tarama
    func scan(
        in rootURL: URL,
        progressHandler: ((URL) -> Void)? = nil
    ) async -> [NodeModulesResult] {
        // Enumerator sync API'sini Task.detached içinde çalıştırıyoruz
        let candidateURLs: [(url: URL, accessDate: Date)] = await Task.detached(priority: .utility) {
            Self.collectNodeModuleCandidates(in: rootURL)
        }.value

        var results: [NodeModulesResult] = []

        for candidate in candidateURLs {
            progressHandler?(candidate.url)
            let size = (try? await scanner.calculateSize(at: candidate.url)) ?? 0
            results.append(NodeModulesResult(
                url: candidate.url,
                size: size,
                lastAccessDate: candidate.accessDate
            ))
        }

        return results
    }

    // MARK: - Sync Tarama (Task.detached içinde çalışır)
    private static func collectNodeModuleCandidates(in rootURL: URL) -> [(url: URL, accessDate: Date)] {
        let fm = FileManager.default
        let thresholdDays = Constants.NodeModules.accessThresholdDays
        let blacklist = Constants.systemBlacklist
        let folderName = Constants.NodeModules.folderName

        let threshold = Calendar.current.date(
            byAdding: .day,
            value: -thresholdDays,
            to: Date()
        )!

        guard let enumerator = fm.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [
                .contentAccessDateKey,
                .isDirectoryKey,
                .nameKey
            ],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var candidates: [(url: URL, accessDate: Date)] = []

        // NSEnumerator.nextObject() — async context dışında güvenli
        while let url = enumerator.nextObject() as? URL {
            // Sistem dizinlerini atla
            let path = url.path
            let isBlocked = blacklist.contains { path.hasPrefix($0) }
            if isBlocked {
                enumerator.skipDescendants()
                continue
            }

            let resourceValues = try? url.resourceValues(
                forKeys: [.isDirectoryKey, .contentAccessDateKey]
            )

            guard resourceValues?.isDirectory == true else { continue }
            guard url.lastPathComponent == folderName else { continue }

            // node_modules altına inme
            enumerator.skipDescendants()

            let accessDate = resourceValues?.contentAccessDate ?? Date()
            guard accessDate < threshold else { continue }

            candidates.append((url: url, accessDate: accessDate))
        }

        return candidates
    }

    // MARK: - Toplam Boyut
    func totalSize(of results: [NodeModulesResult]) -> Int64 {
        results.reduce(0) { $0 + $1.size }
    }
}
