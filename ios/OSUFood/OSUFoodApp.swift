import SwiftUI

@main
struct OSUFoodApp: App {
    @State private var store = AppStore()
    @State private var selectedTab: AppTab = .home
    @State private var editingListing: Listing?
    @State private var showEditor = false

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(store: store) { selectedTab = .browse }
                }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)

                NavigationStack {
                    BrowseView(store: store)
                }
                .tabItem { Label("Browse", systemImage: "leaf") }
                .tag(AppTab.browse)

                if store.role == .staff {
                    NavigationStack {
                        StaffDashboardView(store: store, onCreate: {
                            editingListing = nil
                            showEditor = true
                        }, onEdit: { listing in
                            editingListing = listing
                            showEditor = true
                        }, onManagePickups: {
                            selectedTab = .pickups
                        })
                    }
                    .tabItem { Label("Overview", systemImage: "square.grid.2x2") }
                    .tag(AppTab.staff)

                    NavigationStack {
                        PickupManagementView(store: store)
                    }
                    .tabItem { Label("Pickups", systemImage: "checkmark.seal") }
                    .tag(AppTab.pickups)
                } else if store.role == .pantry || store.role == .student {
                    NavigationStack {
                        ReservationsView(store: store)
                    }
                    .tabItem { Label(store.role == .student ? "Orders" : "Reservations", systemImage: "ticket") }
                    .tag(AppTab.reservations)
                }

                if store.role != .student {
                    NavigationStack { ImpactView(store: store) }
                        .tabItem { Label("Impact", systemImage: "chart.bar") }
                        .tag(AppTab.impact)
                }

                if store.role == .admin {
                    NavigationStack { AdminView(store: store) }
                        .tabItem { Label("Controls", systemImage: "slider.horizontal.3") }
                        .tag(AppTab.admin)
                }

                NavigationStack { GuideView() }
                    .tabItem { Label("Guide", systemImage: "list.number") }
                    .tag(AppTab.guide)
            }
            .tint(FoodStyle.accent)
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 0) {
                            Text("OSU").foregroundStyle(FoodStyle.ink)
                            Text("Food").foregroundStyle(FoodStyle.accent)
                        }
                        .font(.title3.weight(.heavy))
                        Text("AFTER HOURS · DEMO")
                            .font(.system(size: 9, weight: .bold)).tracking(0.7)
                            .foregroundStyle(FoodStyle.muted)
                    }
                    Spacer(minLength: 4)
                    Menu {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Button {
                                store.role = role
                                selectedTab = role.startTab
                            } label: {
                                if role == store.role {
                                    Label(role.label, systemImage: "checkmark")
                                } else {
                                    Text(role.label)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.role.label).lineLimit(1).minimumScaleFactor(0.8)
                            Image(systemName: "chevron.down").font(.caption2)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FoodStyle.ink)
                        .padding(.horizontal, 10).padding(.vertical, 9)
                        .background(.white, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(FoodStyle.border))
                    }
                    .accessibilityLabel("Preview as \(store.role.label). Not a login.")
                }
                .padding(.horizontal, 16).padding(.vertical, 7)
                .background(.white)
                .overlay(alignment: .bottom) { FoodStyle.border.frame(height: 1) }
            }
            .overlay(alignment: .top) {
                if let error = store.errorMessage {
                    HStack {
                        Image(systemName: "wifi.exclamationmark")
                        Text(error).font(.footnote)
                        Spacer(minLength: 4)
                        Button("Retry") { Task { await store.reload() } }
                    }
                    .padding(12)
                    .background(.red.opacity(0.95), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .padding(12)
                }
            }
            .overlay {
                if store.isLoading && store.snapshot == nil {
                    ProgressView("Loading local demo…")
                        .padding(24)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    ListingEditorView(store: store, listing: editingListing, onSaved: {
                        showEditor = false
                        selectedTab = .staff
                    })
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showEditor = false }
                        }
                    }
                }
            }
            .task { await store.load() }
        }
    }
}

private enum AppTab: Hashable {
    case home, browse, reservations, staff, pickups, impact, admin, guide
}

private extension UserRole {
    var label: String {
        switch self {
        case .staff: "Dining Staff"
        case .pantry: "Pantry Volunteer"
        case .student: "Student"
        case .admin: "Administrator"
        }
    }
    var startTab: AppTab {
        switch self {
        case .staff: .staff
        case .pantry, .student: .browse
        case .admin: .admin
        }
    }
}
