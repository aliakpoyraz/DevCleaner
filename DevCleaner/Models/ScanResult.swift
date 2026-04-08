import Foundation

// MARK: - Tarama Sonucu
struct ScanResult {
    let categoryId: UUID
    let urls: [URL]       // Silinecek dosya/klasör URL'leri
    let totalSize: Int64
    let scannedAt: Date

    var formattedSize: String {
        FileSizeFormatter.string(from: totalSize)
    }
}
