import Foundation
import SwiftUI
import Combine

// MARK: - HomeViewModel
@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State
    @Published var categories: [CleanupCategory] = CleanupCategory.defaultCategories()
    @Published var isScanning: Bool = false
    @Published var isCleaning: Bool = false
    @Published var showCleanConfirmation: Bool = false
    @Published var showSettingsView: Bool = false
    @Published var lastCleanedSize: Int64 = 0
    @Published var errorMessage: String? = nil
    @Published var scanningCategoryName: String = ""

    // Services
    private let scanner = FileScanner()
    private let nodeScanner = NodeModulesScanner()
    private let cleaner = DiskCleanerService()


    @ObservedObject private var permissionService = PermissionService.shared

    // Node modules scan önbelleği
    private var nodeModulesURLs: [URL] = []

    // MARK: - Disk Info
    struct DiskSpaceInfo {
        var volumeName: String = "Drive"
        var total: Int64 = 0
        var free: Int64 = 0
        var used: Int64 = 0
        var usedPercent: Double = 0

        var freeFormatted: String { FileSizeFormatter.string(from: free) }
        var totalFormatted: String { FileSizeFormatter.string(from: total) }
        var usedFormatted: String { FileSizeFormatter.string(from: used) }
    }

    @Published var diskSpace = DiskSpaceInfo()

    func refreshDiskSpace() {
        let fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: "/")

        // Birim Adı
        let resourceValues = try? rootURL.resourceValues(forKeys: [.volumeNameKey])
        let vName = resourceValues?.volumeName ?? "Drive"

        if let attributes = try? fileManager.attributesOfFileSystem(forPath: "/"),
           let total = attributes[.systemSize] as? Int64,
           let free = attributes[.systemFreeSize] as? Int64 {
            let used = total - free
            let percent = Double(used) / Double(total)
            self.diskSpace = DiskSpaceInfo(
                volumeName: vName,
                total: total,
                free: free,
                used: used,
                usedPercent: percent
            )
        }
    }

    init() {
        refreshDiskSpace()
    }

    // MARK: - Hesaplanan Özellikler
    var totalSelectedSize: Int64 {
        categories
            .filter { $0.isSelected && $0.status == .done }
            .reduce(0) { $0 + $1.scannedSize }
    }

    var selectedCount: Int {
        categories.filter { $0.isSelected }.count
    }

    var hasAnyScanned: Bool {
        categories.contains { $0.status == .done }
    }

    var isPermissionRequired: Bool {
        !permissionService.isHomeFolderAuthorized
    }

    var deleteMode: DiskCleanerService.DeleteMode {
        useTrash ? .trash : .permanent
    }

    @AppStorage(Constants.UserDefaultsKeys.useTrash)
    var useTrash: Bool = true

    // MARK: - İzin Iste
    func requestAccess() async {
        _ = await permissionService.requestHomeFolderAccess()
    }

    // MARK: - Seçim Yönetimi
    @Published var isAllSelected: Bool = true

    func toggleAllSelection() {
        isAllSelected.toggle()
        for index in categories.indices {
            categories[index].isSelected = isAllSelected
        }
    }

    func toggleSelection(categoryId: UUID) {
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[index].isSelected.toggle()
            // Eğer bir tane bile seçili olmayan varsa isAllSelected false olmalı
            isAllSelected = categories.allSatisfy { $0.isSelected }
        }
    }

    // MARK: - Tüm Kategorileri Tara
    func scanAll() async {
        isScanning = true
        errorMessage = nil
        nodeModulesURLs = []

        for index in categories.indices {
            scanningCategoryName = categories[index].name
            categories[index].status = .scanning

            do {
                let category = categories[index]
                var total: Int64 = 0

                // İzin kontrolü (Sandbox'ta çöp kutusu dahil her şey izin bekler)
                if !permissionService.isHomeFolderAuthorized {
                    categories[index].status = .error("Permission Required")
                    continue
                }

                if category.name.contains("Node Modules") {
                    let authorizedHome = permissionService.mapToAuthorizedURL(Constants.Paths.userHome)
                    let results = await nodeScanner.scan(in: authorizedHome)
                    total = await nodeScanner.totalSize(of: results)
                    nodeModulesURLs = results.map(\.url)
                } else {
                    for path in category.paths {
                        let authorizedPath = permissionService.mapToAuthorizedURL(path)
                        let size = (try? await scanner.calculateSize(at: authorizedPath)) ?? 0
                        total += size
                    }
                }

                categories[index].scannedSize = total
                categories[index].status = .done
            }
        }

        scanningCategoryName = ""
        isScanning = false
        sortCategories()
    }

    // MARK: - Tek Kategori Tara
    func scan(categoryId: UUID) async {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        isScanning = true
        categories[index].status = .scanning
        scanningCategoryName = categories[index].name

        // İzin kontrolü
        if !permissionService.isHomeFolderAuthorized {
            categories[index].status = .error("Permission Required")
            scanningCategoryName = ""
            isScanning = false
            return
        }

        var total: Int64 = 0

        if categories[index].name.contains("Node Modules") {
            let authorizedHome = permissionService.mapToAuthorizedURL(Constants.Paths.userHome)
            let results = await nodeScanner.scan(in: authorizedHome)
            total = await nodeScanner.totalSize(of: results)
            nodeModulesURLs = results.map(\.url)
        } else {
            for path in categories[index].paths {
                let authorizedPath = permissionService.mapToAuthorizedURL(path)
                let size = (try? await scanner.calculateSize(at: authorizedPath)) ?? 0
                total += size
            }
        }

        categories[index].scannedSize = total
        categories[index].status = .done
        scanningCategoryName = ""
        isScanning = false
        sortCategories()
    }

    // MARK: - Seçilenleri Temizle
    func cleanSelected() async {
        isCleaning = true
        var allURLs: [URL] = []
        var cleanedCategories: [String] = []

        for category in categories where category.isSelected && category.status == .done {
            if category.name.contains("Node Modules") {
                allURLs.append(contentsOf: nodeModulesURLs)
            } else {
                for path in category.paths {
                    let authorizedPath = permissionService.mapToAuthorizedURL(path)
                    let items = await scanner.listTopLevelItems(at: authorizedPath)
                    allURLs.append(contentsOf: items)
                }
            }
            cleanedCategories.append(category.name)
        }

        let (deleted, errors) = await cleaner.clean(urls: allURLs, mode: deleteMode)
        lastCleanedSize = deleted

        if !errors.isEmpty {
            errorMessage = errors.prefix(3).joined(separator: "\n")
        }

        // Kategorileri sıfırla
        for index in categories.indices {
            if categories[index].isSelected {
                categories[index].scannedSize = 0
                categories[index].status = .idle
            }
        }
        nodeModulesURLs = []
        isCleaning = false
    }

    // MARK: - Sıralama
    private func sortCategories() {
        withAnimation(.spring(response: 0.4)) {
            let trash = categories.filter { $0.name == "Trash Bin" }
            let others = categories.filter { $0.name != "Trash Bin" }
                .sorted { $0.scannedSize > $1.scannedSize }
            
            categories = trash + others
        }
    }
}
