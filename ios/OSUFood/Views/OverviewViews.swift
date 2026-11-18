import SwiftUI

// The colors are inspired by the web prototype; the app does not claim university affiliation.
enum FoodStyle {
    static let background = Color(red: 250/255, green: 247/255, blue: 243/255)
    static let ink = Color(red: 37/255, green: 35/255, blue: 33/255)
    static let muted = Color(red: 99/255, green: 94/255, blue: 88/255)
    static let accent = Color(red: 196/255, green: 79/255, blue: 17/255)
    static let border = Color(red: 228/255, green: 217/255, blue: 207/255)
    static let peach = Color(red: 255/255, green: 243/255, blue: 233/255)
    static let green = Color(red: 38/255, green: 112/255, blue: 91/255)
}

struct FoodCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.white, in: RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(FoodStyle.border))
    }
}

struct FoodDisclaimer: View {
    var body: some View {
        Text("Academic demonstration with fictional listings, prices, partners and pickup locations. Not affiliated with or operated by Oregon State University. Preview roles are not secure authentication. No payment or food-safety certification is provided.")
            .font(.footnote)
            .foregroundStyle(FoodStyle.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 18)
            .accessibilityLabel("Academic demonstration. Not a real food pickup service or secure login.")
    }
}

struct MetricTile: View {
    let value: String
    let label: String
    var body: some View {
        FoodCard {
            VStack(alignment: .leading, spacing: 7) {
                Text(value).font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(FoodStyle.ink)
                Text(label).font(.subheadline).foregroundStyle(FoodStyle.muted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ImpactView: View {
    let store: AppStore

    private func pickupCategories(_ snapshot: Snapshot) -> [(String, Int)] {
        let listingCategories = Dictionary(uniqueKeysWithValues: snapshot.listings.map { ($0.id, $0.category) })
        var counts: [String: Int] = [:]
        for reservation in snapshot.reservations where reservation.status == "COMPLETED" {
            counts[listingCategories[reservation.listingId] ?? "Other", default: 0] += 1
        }
        return counts.map { (key: $0.key, value: $0.value) }.sorted {
            if $0.value == $1.value { return $0.key < $1.key }
            return $0.value > $1.value
        }.map { ($0.key, $0.value) }
    }

    private func listingStatuses(_ snapshot: Snapshot) -> [(String, Int)] {
        var counts: [String: Int] = [:]
        for listing in snapshot.listings { counts[listing.status, default: 0] += 1 }
        return counts.map { ($0.key.replacingOccurrences(of: "_", with: " ").capitalized, $0.value) }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("DATA FROM THIS LOCAL DEMO")
                    .font(.caption.weight(.bold)).tracking(2).foregroundStyle(FoodStyle.accent)
                Text("Impact at a glance").font(.largeTitle.weight(.bold))
                Text("Seeded demonstration values plus actions made in this prototype. Not observed real-world outcomes.")
                    .foregroundStyle(FoodStyle.muted)
                if let snapshot = store.snapshot {
                    let metrics = snapshot.metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricTile(value: "\(metrics.completed)", label: "Completed pickups")
                        MetricTile(value: "\(metrics.active)", label: "Active food listings")
                        MetricTile(value: "\(metrics.organizations)", label: "Fictional organizations")
                        MetricTile(value: "\(metrics.rate)%", label: "Pickup completion rate")
                    }
                    MetricTile(value: "\(metrics.canceled)", label: "Cancellations")
                    FoodCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Redistributed quantity, by unit").font(.headline)
                            Text("Units are never combined across types.").font(.footnote).foregroundStyle(FoodStyle.muted)
                            ForEach(metrics.byUnit, id: \.unit) { row in
                                LabeledContent(row.unit, value: "\(row.quantity)")
                            }
                        }
                    }
                    ChartCard(title: "Completed pickups by day", subtitle: "Pickups · daily totals", rows: metrics.byDay.map { ($0.day, $0.count) })
                    ChartCard(title: "Completed pickups by category", subtitle: "Pickups · by listing category", rows: pickupCategories(snapshot))
                    ChartCard(title: "Listing statuses", subtitle: "Listings · current status", rows: listingStatuses(snapshot))
                }
                Text("Proposed future pilot target: reduce coordination time by 50% against existing methods. This is a hypothesis, not a measured outcome.")
                    .font(.footnote).foregroundStyle(FoodStyle.muted)
                FoodDisclaimer()
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle("Impact")
        .refreshable { await store.reload() }
    }
}

private struct ChartCard: View {
    let title: String
    let subtitle: String
    let rows: [(String, Int)]
    @State private var showTable = false

    var body: some View {
        FoodCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(title).font(.headline)
                Text(subtitle).font(.footnote).foregroundStyle(FoodStyle.muted)
                if rows.isEmpty {
                    Text("No completed records yet.").foregroundStyle(FoodStyle.muted)
                } else {
                    let maximum = max(1, rows.map(\.1).max() ?? 1)
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(row.0).lineLimit(1)
                                Spacer()
                                Text("\(row.1)").fontWeight(.semibold)
                            }
                            .font(.caption)
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color(red: 241/255, green: 238/255, blue: 231/255))
                                    Capsule().fill(FoodStyle.accent)
                                        .frame(width: max(row.1 == 0 ? 0 : 4, geometry.size.width * CGFloat(row.1) / CGFloat(maximum)))
                                }
                            }
                            .frame(height: 12)
                            .accessibilityHidden(true)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(row.0), \(row.1) \(title == "Listing statuses" ? "listings" : "pickups")")
                    }
                    DisclosureGroup("View data table", isExpanded: $showTable) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            LabeledContent(row.0, value: "\(row.1)")
                                .font(.footnote)
                        }
                    }
                    .tint(FoodStyle.accent)
                }
            }
        }
    }
}

struct AdminView: View {
    let store: AppStore
    @State private var confirmReset = false
    @State private var actionError: String?
    @State private var resetMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("PROTOTYPE ADMINISTRATION").font(.caption.weight(.bold)).tracking(2).foregroundStyle(FoodStyle.accent)
                Text("Demo controls").font(.largeTitle.weight(.bold))
                Text("These controls affect the shared local demonstration database. This preview role is not authentication.")
                    .foregroundStyle(FoodStyle.muted)
                if let snapshot = store.snapshot {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricTile(value: "\(snapshot.organizations.count)", label: "Organizations")
                        MetricTile(value: "\(snapshot.listings.count)", label: "Listings")
                        MetricTile(value: "\(snapshot.reservations.count)", label: "Reservations")
                        MetricTile(value: "\(snapshot.activity.count)", label: "Activity entries")
                    }
                    FoodCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reset demo data").font(.headline)
                            Text("Delete current demo listings, reservations and activity, then restore the original fictional sample data. This cannot be undone.")
                                .font(.subheadline).foregroundStyle(FoodStyle.muted)
                            Button(role: .destructive) { confirmReset = true } label: {
                                Label("Reset demo data", systemImage: "arrow.counterclockwise")
                            }
                            .disabled(store.isPerformingAction)
                        }
                    }
                    if let resetMessage { Text(resetMessage).foregroundStyle(FoodStyle.green) }
                    if let actionError { Text(actionError).foregroundStyle(.red) }
                    FoodCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent activity").font(.headline)
                            ForEach(snapshot.activity.prefix(30), id: \.id) { event in
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(event.description)
                                    Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption).foregroundStyle(FoodStyle.muted)
                                }
                                Divider()
                            }
                        }
                    }
                }
                FoodDisclaimer()
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle("Demo controls")
        .refreshable { await store.reload() }
        .confirmationDialog("Reset the shared demo database?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Delete and restore demo data", role: .destructive) {
                Task {
                    do {
                        _ = try await store.perform(.reset)
                        actionError = nil
                        resetMessage = "Demo data restored."
                    } catch {
                        actionError = error.localizedDescription
                    }
                }
            }
        } message: {
            Text("All current demo listings, reservations and activity will be deleted. No user accounts exist in this prototype.")
        }
    }
}

struct GuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("A 90-SECOND WALKTHROUGH").font(.caption.weight(.bold)).tracking(2).foregroundStyle(FoodStyle.accent)
                Text("One box at a time. One complete handoff.").font(.largeTitle.weight(.bold))
                Text("Use the Preview as menu to try each demonstration role. This is not a live food program.")
                    .foregroundStyle(FoodStyle.muted)
                ForEach(Array([
                    ("1", "Create", "Preview as Dining Staff. Choose McNary Dining Center, then publish a listing for 20 produce boxes with a future pickup window and price."),
                    ("2", "Reserve", "Preview as Pantry Volunteer. Choose a fictional pantry site, find the listing and reserve 5 boxes."),
                    ("3", "Check your code", "Open My reservations. Note the six-digit pickup code and confirm that 15 boxes remain available."),
                    ("4", "Confirm pickup", "Return to Dining Staff and open Pickups. Enter the code to complete the handoff."),
                    ("5", "See the impact", "Visit Impact to see the completed pickup and its correctly separated unit count. An Administrator can reset the demo afterward.")
                ].enumerated()), id: \.offset) { _, step in
                    FoodCard {
                        HStack(alignment: .top, spacing: 14) {
                            Text(step.0).font(.title2.bold()).foregroundStyle(FoodStyle.accent)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(step.1).font(.headline)
                                Text(step.2).font(.subheadline).foregroundStyle(FoodStyle.muted)
                            }
                        }
                    }
                }
                FoodDisclaimer()
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle("Demo guide")
    }
}

struct HomeView: View {
    let store: AppStore
    let onExplore: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("A BETTER PATH FOR SURPLUS FOOD")
                        .font(.caption.weight(.bold)).tracking(2).foregroundStyle(.orange)
                    Text("Good food.\nBetter connections.\nLess waste.")
                        .font(.system(size: 38, weight: .bold)).foregroundStyle(.white)
                    Text("A classroom prototype for connecting dining-center surplus with fictional pantry partners and students after hours.")
                        .foregroundStyle(.white.opacity(0.85))
                    Button(action: onExplore) {
                        Label("Explore the demo", systemImage: "arrow.right")
                            .fontWeight(.semibold).frame(maxWidth: .infinity).padding(14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FoodStyle.accent)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(FoodStyle.ink, in: RoundedRectangle(cornerRadius: 20))
                if let snapshot = store.snapshot {
                    Text("Available now").font(.title2.bold())
                    Text("Fictional sample listings, ordered by pickup deadline.").foregroundStyle(FoodStyle.muted)
                    ForEach(snapshot.listings.filter { ["AVAILABLE", "PARTIALLY_RESERVED"].contains($0.status) }.sorted { $0.pickupEnd < $1.pickupEnd }.prefix(3), id: \.id) { listing in
                        FoodCard {
                            VStack(alignment: .leading, spacing: 7) {
                                Text(listing.category.uppercased()).font(.caption.bold()).foregroundStyle(FoodStyle.accent)
                                Text(listing.title).font(.headline)
                                Text("\(listing.quantityAvailable) \(listing.quantityUnit) · \(listing.organizationName)")
                                    .font(.subheadline).foregroundStyle(FoodStyle.muted)
                                Text("Pickup until \(listing.pickupEnd.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.footnote)
                            }
                        }
                    }
                }
                ForEach([("1", "List", "Dining staff describe surplus and set a supervised pickup window."), ("2", "Reserve", "Pantry volunteers or students choose a quantity and receive a demo code."), ("3", "Collect", "Staff verify the code to record a completed handoff.")], id: \.0) { step in
                    FoodCard {
                        HStack(alignment: .top, spacing: 12) {
                            Text(step.0).font(.title2.bold()).foregroundStyle(FoodStyle.accent)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(step.1).font(.headline)
                                Text(step.2).font(.subheadline).foregroundStyle(FoodStyle.muted)
                            }
                        }
                    }
                }
                FoodDisclaimer()
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle("After Hours")
        .refreshable { await store.reload() }
    }
}
