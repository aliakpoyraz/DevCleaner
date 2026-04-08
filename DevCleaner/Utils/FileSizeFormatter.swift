import Foundation

struct FileSizeFormatter {

    /// Byte değerini kullanıcı dostu formata çevirir: "2.3 GB", "450 MB" vb.
    static func string(from bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB, .useBytes]
        formatter.countStyle = .file
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: bytes)
    }

    /// İki boyut arasındaki yüzde farkını hesaplar
    static func percentage(part: Int64, total: Int64) -> Double {
        guard total > 0 else { return 0 }
        return Double(part) / Double(total)
    }
}
