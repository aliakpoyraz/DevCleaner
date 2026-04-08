import SwiftUI

// MARK: - HomeView
struct HomeView: View {

    @StateObject private var vm = HomeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Toplam Boyut Hero
            totalSizeHero

            Divider()

            // İzin Banner'ı
            if vm.isPermissionRequired {
                permissionBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                Divider()
            }

            // Kategori Listesi
            HStack {
                Text("Categories")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    vm.toggleAllSelection()
                } label: {
                    Text(vm.isAllSelected ? "Deselect All" : "Select All")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 6)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach($vm.categories) { $category in
                        CategoryRowView(
                            category: category,
                            onToggle: { vm.toggleSelection(categoryId: category.id) },
                            onScan: { await vm.scan(categoryId: category.id) }
                        )
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            }

            Divider()

            // Alt Bar
            bottomBar
        }
        .frame(minWidth: 550, minHeight: 600)
        .background(Color(.windowBackgroundColor))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    vm.showSettingsView = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .overlay(alignment: .bottom) {
            if vm.lastCleanedSize > 0 && !vm.isCleaning {
                cleanSuccessBanner
                    .padding(.bottom, 60)
            }
        }
        // MARK: - Modals & Alerts
        .sheet(isPresented: $vm.showSettingsView) {
            SettingsView()
        }
        .confirmationDialog(
            Text(String(localized: "Selected \(FileSizeFormatter.string(from: vm.totalSelectedSize)) will be deleted.")),
            isPresented: $vm.showCleanConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clean", role: .destructive) {
                Task { await vm.cleanSelected() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(vm.useTrash
                 ? "Files will be moved to the trash."
                 : "This action cannot be undone. Files will be permanently deleted.")
        }
        .alert("Some files couldn't be deleted", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Hero: Toplam Boyut
    private var totalSizeHero: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(vm.hasAnyScanned
                     ? FileSizeFormatter.string(from: vm.totalSelectedSize)
                     : "—")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.red, .orange],
                                         startPoint: .leading, endPoint: .trailing)
                    )
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: vm.totalSelectedSize)

                if vm.isScanning {
                    HStack(spacing: 8) {
                        ProgressView().scaleEffect(0.5)
                        Text(LocalizedStringKey(vm.scanningCategoryName))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(vm.hasAnyScanned
                         ? "cleanable space"
                         : "Press 'Scan All' to scan your system")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            // Disk Durum Barı (Merkezi Tasarım)
            VStack(spacing: 6) {
                HStack {
                    Text(LocalizedStringKey(vm.diskSpace.volumeName))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(vm.diskSpace.usedFormatted) / \(vm.diskSpace.totalFormatted) used")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: 300)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: 300 * CGFloat(vm.diskSpace.usedPercent), height: 6)
                }
                .frame(width: 300, height: 6)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.controlBackgroundColor).opacity(0.3))
    }

    // MARK: - İzin Banner'ı
    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.trianglebadge.exclamationmark.fill")
                .font(.system(size: 18))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Permission Required")
                    .font(.system(size: 12, weight: .bold))
                Text("The app needs access to your home directory to scan system files.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                Task { await vm.requestAccess() }
            } label: {
                Text("Grant Permission")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
    }

    // MARK: - Alt Bar
    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await vm.scanAll() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                    Text("Scan All")
                }
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .disabled(vm.isScanning || vm.isCleaning)

            Button {
                vm.showCleanConfirmation = true
            } label: {
                HStack(spacing: 6) {
                    if vm.isCleaning {
                        ProgressView().scaleEffect(0.7).tint(.white)
                    } else {
                        Image(systemName: "trash.fill")
                    }
                    if vm.isCleaning {
                        Text("Cleaning...")
                    } else {
                        Text("Clean Now (\(vm.selectedCount))")
                    }
                }
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(!vm.hasAnyScanned || vm.isScanning || vm.isCleaning || vm.selectedCount == 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Başarı Banner
    private var cleanSuccessBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("\(FileSizeFormatter.string(from: vm.lastCleanedSize)) successfully cleaned!")
                .font(.system(size: 12, weight: .medium))
            Spacer()
            Button {
                vm.lastCleanedSize = 0
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    HomeView()
}
