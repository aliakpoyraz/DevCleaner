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
        case .idle:          return "Not Scanned"
        case .scanning:      return "Scanning..."
        case .done:          return "Done"
        case .error(let m):  return m
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
                description: "Xcode build caches. Regenerates automatically.",
                color: .blue,
                paths: [Constants.Paths.derivedData]
            ),
            CleanupCategory(
                name: "App Caches",
                icon: "internaldrive.fill",
                description: "Browser, Spotlight and other app temporary files.",
                color: .orange,
                paths: [Constants.Paths.userCaches]
            ),
            CleanupCategory(
                name: "System & App Logs",
                icon: "doc.text.fill",
                description: "App crash and system activity records.",
                color: .purple,
                paths: [Constants.Paths.userLogs, Constants.Paths.systemLogs]
            ),
            CleanupCategory(
                name: "Trash Bin",
                icon: "trash.fill",
                description: "Files deleted but still on system.",
                color: .red,
                paths: [Constants.Paths.trash]
            ),
            CleanupCategory(
                name: "Node Modules (30g+)",
                icon: "folder.badge.gearshape",
                description: "Node modules folders not accessed for 30+ days.",
                color: .indigo,
                paths: [Constants.Paths.userHome]
            ),
            CleanupCategory(
                name: "CocoaPods Repos",
                icon: "shippingbox.fill",
                description: "Old CocoaPods repository caches.",
                color: .brown,
                paths: [Constants.Paths.cocoaPods]
            ),
            CleanupCategory(
                name: "Swift Package Manager",
                icon: "cube.box.fill",
                description: "SwiftPM downloaded package caches.",
                color: .cyan,
                paths: [Constants.Paths.swiftPM]
            ),
            CleanupCategory(
                name: "Simulator Devices",
                icon: "iphone.circle.fill",
                description: "Temporary data and logs from iOS Simulators.",
                color: .teal,
                paths: [Constants.Paths.simulatorDevices]
            ),
            CleanupCategory(
                name: "Mail Downloads",
                icon: "envelope.open.fill",
                description: "Temporary attachments opened by Mail app.",
                color: .pink,
                paths: [Constants.Paths.mailDownloads]
            ),
            CleanupCategory(
                name: "Database Logs",
                icon: "externaldrive.badge.exclamationmark",
                description: "PostgreSQL and MySQL system logs.",
                color: .green,
                paths: [Constants.Paths.postgresLog, Constants.Paths.mysqlLog]
            ),
            CleanupCategory(
                name: "Homebrew Cache",
                icon: "mug.fill",
                description: "Packages and temporary data downloaded by Homebrew.",
                color: .orange,
                paths: [Constants.Paths.homebrew]
            ),
            CleanupCategory(
                name: "Docker Cache & Logs",
                icon: "square.stack.3d.down.right.fill",
                description: "Docker builder cache and system logs.",
                color: .blue,
                paths: [Constants.Paths.docker]
            ),
            CleanupCategory(
                name: "Flutter & Dart Cache",
                icon: "bolt.ring.closed",
                description: "Pub-cache and Dart SDK temporary files.",
                color: .cyan,
                paths: [Constants.Paths.flutter, Constants.Paths.dart]
            )
        ]
    }
}
