import Foundation
import SwiftUI

// MARK: - Scan Status
enum ScanStatus: Equatable {
    case idle
    case scanning
    case done
    case error(String)

    var isScanning: Bool { self == .scanning }

    var label: String {
        switch self {
        case .idle:          return "Taranmadı"
        case .scanning:      return "Taranıyor..."
        case .done:          return "Tamam"
        case .error(let m):  return "Hata: \(m)"
        }
    }
}

// MARK: - Cleanup Category
struct CleanupCategory: Identifiable {
    let id: UUID
    let name: String
    let icon: String           // SF Symbol adı
    let description: String
    let color: Color
    let paths: [URL]
    var scannedSize: Int64
    var isSelected: Bool
    var status: ScanStatus

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        description: String,
        color: Color,
        paths: [URL],
        scannedSize: Int64 = 0,
        isSelected: Bool = true,
        status: ScanStatus = .idle
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.color = color
        self.paths = paths
        self.scannedSize = scannedSize
        self.isSelected = isSelected
        self.status = status
    }
}

// MARK: - Default Categories Factory
extension CleanupCategory {

    static func defaultCategories() -> [CleanupCategory] {
        [
            CleanupCategory(
                name: "Xcode DerivedData",
                icon: "hammer.circle.fill",
                description: "Xcode derleme önbellekleri. Yeniden açıldığında otomatik oluşur.",
                color: .blue,
                paths: [Constants.Paths.derivedData]
            ),
            CleanupCategory(
                name: "Uygulama Önbellekleri",
                icon: "internaldrive.fill",
                description: "Tarayıcı, Spotlight ve diğer uygulamaların geçici dosyaları.",
                color: .orange,
                paths: [Constants.Paths.userCaches]
            ),
            CleanupCategory(
                name: "Sistem & Uygulama Logları",
                icon: "doc.text.fill",
                description: "Uygulama çökmesi ve sistem aktivite kayıtları.",
                color: .purple,
                paths: [Constants.Paths.userLogs, Constants.Paths.systemLogs]
            ),
            CleanupCategory(
                name: "Çöp Kutusu",
                icon: "trash.fill",
                description: "Silinen ama sistemden atılmayan dosyalar.",
                color: .red,
                paths: [Constants.Paths.trash]
            ),
            CleanupCategory(
                name: "Node Modules (30g+)",
                icon: "folder.badge.gearshape",
                description: "30 günden uzun süredir erişilmeyen node_modules klasörleri.",
                color: .indigo,
                paths: [Constants.Paths.userHome]
            ),
            CleanupCategory(
                name: "CocoaPods Repos",
                icon: "shippingbox.fill",
                description: "Eski CocoaPods repository önbellekleri.",
                color: .brown,
                paths: [Constants.Paths.cocoaPods]
            ),
            CleanupCategory(
                name: "Swift Package Manager",
                icon: "cube.box.fill",
                description: "SwiftPM tarafından indirilmiş paket önbellekleri.",
                color: .cyan,
                paths: [Constants.Paths.swiftPM]
            ),
            CleanupCategory(
                name: "Simulator Devices",
                icon: "iphone.circle.fill",
                description: "iOS Simulator'lerinde biriken geçici veriler ve loglar.",
                color: .teal,
                paths: [Constants.Paths.simulatorDevices]
            ),
            CleanupCategory(
                name: "Mail İndirmeleri",
                icon: "envelope.open.fill",
                description: "Mail uygulamasının açtığı geçici ek dosyaları.",
                color: .pink,
                paths: [Constants.Paths.mailDownloads]
            ),
            CleanupCategory(
                name: "Database Logs",
                icon: "externaldrive.badge.exclamationmark",
                description: "PostgreSQL ve MySQL sistem logları.",
                color: .green,
                paths: [Constants.Paths.postgresLog, Constants.Paths.mysqlLog]
            ),
            CleanupCategory(
                name: "Homebrew Cache",
                icon: "mug.fill",
                description: "Homebrew tarafından indirilen paket arşivleri ve geçici veriler.",
                color: .orange,
                paths: [Constants.Paths.homebrew]
            ),
            CleanupCategory(
                name: "Docker Cache & Logs",
                icon: "square.stack.3d.down.right.fill",
                description: "Docker builder cache ve sistem logları.",
                color: .blue,
                paths: [Constants.Paths.docker]
            ),
            CleanupCategory(
                name: "Flutter & Dart Cache",
                icon: "bolt.ring.closed",
                description: "Pub-cache ve Dart SDK geçici dosyaları.",
                color: .cyan,
                paths: [Constants.Paths.flutter, Constants.Paths.dart]
            )
        ]
    }
}
