import Foundation

enum Constants {

    // MARK: - Scan Directories
    enum Paths {
        nonisolated static let derivedData: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Developer/Xcode/DerivedData")

        nonisolated static let userLogs: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs")

        nonisolated static let systemLogs: URL = URL(fileURLWithPath: "/Library/Logs")

        nonisolated static let userCaches: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches")

        nonisolated static let trash: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".Trash")

        nonisolated static let userHome: URL = FileManager.default.homeDirectoryForCurrentUser

        nonisolated static let cocoaPods: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".cocoapods/repos")

        nonisolated static let swiftPM: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/org.swift.swiftpm")

        nonisolated static let simulatorDevices: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Developer/CoreSimulator/Devices")

        nonisolated static let mailDownloads: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Containers/com.apple.mail/Data/Library/Mail Downloads")

        nonisolated static let homebrew: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/Homebrew")

        nonisolated static let docker: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".docker")

        nonisolated static let flutter: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".pub-cache")

        nonisolated static let dart: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/DartStore")

        nonisolated static let postgresLog: URL = URL(fileURLWithPath: "/usr/local/var/log/postgresql")
        nonisolated static let mysqlLog: URL = URL(fileURLWithPath: "/usr/local/var/log/mysql")
    }

    // MARK: - System Blacklist (NEVER scan or delete)
    nonisolated static let systemBlacklist: Set<String> = [
        "/System",
        "/usr",
        "/bin",
        "/sbin",
        "/private",
        "/Library/Application Support",
        "/Library/PreferencePanes",
        "/Library/SystemExtensions",
        "/Library/CoreMediaIO",
        "/Library/Audio",
        "/Applications"
    ]

    // MARK: - Node Modules
    enum NodeModules {
        nonisolated static let folderName = "node_modules"
        nonisolated static let accessThresholdDays: Int = 30
    }

    // MARK: - App Settings Keys
    enum UserDefaultsKeys {
        nonisolated static let useTrash = "useTrash"
        nonisolated static let cleanHistory = "cleanHistory"
        nonisolated static let lastScanDate = "lastScanDate"
    }
}
