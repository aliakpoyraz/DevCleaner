import Foundation
import AppKit
import Combine

// MARK: - PermissionService
/// macOS Sandbox kısıtlamalarını aşmak için Security-Scoped Bookmarks yönetimi.
/// Kullanıcının izin verdiği klasörlere erişimi kaydeder ve uygulama yeniden açıldığında otomatik yükler.
@MainActor
final class PermissionService: ObservableObject {

    static let shared = PermissionService()

    @Published var isHomeFolderAuthorized: Bool = false
    @Published var authorizedURL: URL?

    private let bookmarkKey = "securityScopedHomeFolderBookmark"

    init() {
        Task {
            checkInitialAccess()
        }
    }

    // MARK: - İzin İste
    /// NSOpenPanel açarak kullanıcıdan klasör erişimi ister.
    func requestHomeFolderAccess() async -> Bool {
        let panel = NSOpenPanel()
        panel.message = "Uygulamanın temizlik yapabilmesi için ana dizine erişim izni vermeniz gerekiyor."
        panel.prompt = "Erişim Ver"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser

        let response = panel.runModal()

        if response == .OK, let url = panel.url {
            return saveBookmark(for: url)
        }

        return false
    }

    // MARK: - Bookmark Kaydet
    private func saveBookmark(for url: URL) -> Bool {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)

            self.authorizedURL = url
            // Hemen erişimi başlat
            return startAccessing(url: url)
        } catch {
            print("Bookmark kaydedilemedi: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Erişimi Başlat/Yükle
    private func checkInitialAccess() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            isHomeFolderAuthorized = false
            return
        }

        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                // Bookmark eskimiş, tekrar isteyebiliriz veya yenilemeyi deneyebiliriz
                _ = saveBookmark(for: url)
            }

            self.authorizedURL = url
            isHomeFolderAuthorized = startAccessing(url: url)
        } catch {
            print("Bookmark çözülemedi: \(error.localizedDescription)")
            isHomeFolderAuthorized = false
        }
    }

    private func startAccessing(url: URL) -> Bool {
        let success = url.startAccessingSecurityScopedResource()
        if success {
            // Manuel kontrol: Klasörün içine bakabiliyor muyuz?
            isHomeFolderAuthorized = FileManager.default.isReadableFile(atPath: url.path)
        }
        return success
    }

    // MARK: - URL Yetkilendirme
    /// Verilen URL'yi, Sandbox izni alınmış olan asıl URL nesnesine bağlar.
    /// Bu işlem yapılmazsa Sandbox alt klasörlere erişimi engeller.
    func mapToAuthorizedURL(_ originalURL: URL) -> URL {
        guard let base = authorizedURL else { return originalURL }

        let homePath = FileManager.default.homeDirectoryForCurrentUser.path
        let targetPath = originalURL.path

        if targetPath.hasPrefix(homePath) {
            let relativePath = String(targetPath.dropFirst(homePath.count))
            let cleanRelative = relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
            return base.appendingPathComponent(cleanRelative)
        }

        return originalURL
    }

    // MARK: - Yetki Kontrolü
    /// Verilen URL'nin Sandbox dışı olmasına rağmen erişilebilir olup olmadığını kontrol eder.
    func hasAccess(to url: URL) -> Bool {
        let authorized = mapToAuthorizedURL(url)
        return FileManager.default.isReadableFile(atPath: authorized.path) &&
               FileManager.default.isWritableFile(atPath: authorized.path)
    }
}
