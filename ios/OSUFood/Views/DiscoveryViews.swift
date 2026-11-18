import SwiftUI

private enum DiscoveryFormat {
    static func money(_ cents: Int) -> String {
        (Double(cents) / 100).formatted(.currency(code: "USD"))
    }

    static func pickup(_ start: Date, _ end: Date) -> String {
        "\(start.formatted(date: .abbreviated, time: .shortened)) – \(end.formatted(date: .abbreviated, time: .shortened))"
    }

    static func unit(_ plural: String) -> String {
        plural == "boxes" ? "box" : String(plural.dropLast())
    }
}

struct BrowseView: View {
    @Bindable var store: AppStore
    @State private var search = ""
    @State private var category = "All"
    @State private var source = "All"
    @State private var urgency = "All"

    private var listings: [Listing] {
        let cutoff = Date().addingTimeInterval(24 * 60 * 60)
        return (store.snapshot?.listings ?? [])
            .filter { listing in
                ["AVAILABLE", "PARTIALLY_RESERVED"].contains(listing.status)
                    && listing.pickupEnd > Date()
                    && (store.role != .student || listing.originalPriceCents > 0)
                    && (category == "All" || listing.category == category)
                    && (source == "All" || listing.organizationId == source)
                    && (urgency == "All" || (urgency == "Next 24 hours" ? listing.pickupStart < cutoff : listing.pickupStart >= cutoff))
                    && (search.isEmpty || "\(listing.title) \(listing.description) \(listing.organizationName)".localizedCaseInsensitiveContains(search))
            }
            .sorted { $0.pickupEnd == $1.pickupEnd ? $0.id < $1.id : $0.pickupEnd < $1.pickupEnd }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(store.role == .student ? "STUDENT ORDERING PREVIEW" : "FIND THE NEXT GOOD HANDOFF")
                    .font(.caption.weight(.bold)).tracking(2).foregroundStyle(FoodStyle.accent)
                Text(store.role == .student ? "Half-price food" : "Available food")
                    .font(.largeTitle.bold())
                Text(store.role == .student
                     ? "Reserve at a 50% demo discount. No payment or live pickup service."
                     : "Fictional pantry partners and dining centers. Listings sorted by earliest pickup deadline.")
                    .foregroundStyle(FoodStyle.muted)

                if store.role == .pantry, let organizations = store.snapshot?.organizations {
                    let pantries = organizations.filter { ["FOOD_PANTRY", "REDISTRIBUTION_PARTNER"].contains($0.type) }
                    Picker("Pickup organization / campus site", selection: $store.selectedOrganizationID) {
                        Text("Select a site").tag(Optional<String>.none)
                        ForEach(pantries) { organization in
                            Text(organization.name).tag(Optional(organization.id))
                        }
                    }
                    .tint(FoodStyle.accent)
                }

                VStack(alignment: .leading, spacing: 12) {
                    TextField("Search food or dining center", text: $search)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Search food")
                    Picker("Category", selection: $category) {
                        Text("All categories").tag("All")
                        ForEach(["Produce", "Prepared meals", "Bakery", "Dairy", "Packaged"], id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                    Picker("Dining source", selection: $source) {
                        Text("All dining centers").tag("All")
                        ForEach((store.snapshot?.organizations ?? []).filter { $0.type == "DINING_FACILITY" }) { organization in
                            Text(organization.name).tag(organization.id)
                        }
                    }
                    Picker("Pickup availability", selection: $urgency) {
                        ForEach(["All", "Next 24 hours", "Later"], id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                }
                .tint(FoodStyle.accent)
                .padding(16)
                .background(FoodStyle.surface, in: RoundedRectangle(cornerRadius: 17))

                Text("\(listings.count) available listing\(listings.count == 1 ? "" : "s")")
                    .font(.subheadline).foregroundStyle(FoodStyle.muted)
                if store.snapshot == nil {
                    Text(store.errorMessage ?? "Loading demonstration listings…")
                        .foregroundStyle(FoodStyle.muted)
                } else if listings.isEmpty {
                    ContentUnavailableView.search(text: search)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(listings) { listing in
                            NavigationLink(value: listing.id) {
                                DiscoveryListingCard(listing: listing, student: store.role == .student)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("View pickup details and reserve food")
                        }
                    }
                }
                FoodDisclaimer()
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle(store.role == .student ? "Browse student food" : "Browse food")
        .navigationDestination(for: String.self) { id in
            ListingDetailView(store: store, listingID: id)
        }
        .refreshable { await store.reload() }
    }
}

private struct DiscoveryListingCard: View {
    let listing: Listing
    let student: Bool

    var body: some View {
        FoodCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title).foregroundStyle(FoodStyle.accent).accessibilityHidden(true)
                    Text(listing.category.uppercased())
                        .font(.caption.bold()).foregroundStyle(FoodStyle.accent)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption.bold())
                        .foregroundStyle(FoodStyle.muted).accessibilityHidden(true)
                }
                Text(listing.title).font(.title3.bold()).foregroundStyle(FoodStyle.ink)
                Text(listing.organizationName).font(.subheadline).foregroundStyle(FoodStyle.muted)
                Text("\(listing.quantityAvailable) \(listing.quantityUnit) available").fontWeight(.semibold)
                if student && listing.originalPriceCents > 0 {
                    Text("\(DiscoveryFormat.money((listing.originalPriceCents + 1) / 2)) per \(DiscoveryFormat.unit(listing.quantityUnit)) · 50% off")
                        .font(.subheadline.bold()).foregroundStyle(FoodStyle.green)
                }
                Label(DiscoveryFormat.pickup(listing.pickupStart, listing.pickupEnd), systemImage: "calendar")
                    .font(.subheadline)
                Label(listing.pickupLocation, systemImage: "mappin.and.ellipse")
                    .font(.subheadline).foregroundStyle(FoodStyle.muted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ListingDetailView: View {
    let store: AppStore
    let listingID: String
    @State private var quantity = 1
    @State private var actionError: String?
    @State private var showReservations = false

    private var listing: Listing? { store.snapshot?.listings.first { $0.id == listingID } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let listing {
                    Text(listing.category.uppercased())
                        .font(.caption.bold()).tracking(2).foregroundStyle(FoodStyle.accent)
                    Text(listing.title).font(.largeTitle.bold())
                    Text("Shared by \(listing.organizationName)")
                        .foregroundStyle(FoodStyle.muted)
                    FoodCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About this food").font(.title3.bold())
                            Text(listing.description)
                            Divider()
                            Text("Pickup details").font(.title3.bold())
                            Label(listing.pickupLocation, systemImage: "mappin.and.ellipse")
                            Label(DiscoveryFormat.pickup(listing.pickupStart, listing.pickupEnd), systemImage: "calendar")
                            Text("Pickup instructions: \(listing.pickupInstructions)")
                            Text("Collect only during this window. Do not take food from an unattended pickup box.")
                                .font(.footnote).foregroundStyle(FoodStyle.muted)
                            Divider()
                            Text("Organization-supplied handling information").font(.headline)
                            Text(listing.storageRequirements.isEmpty ? "No handling information supplied." : listing.storageRequirements)
                            Text("Organization-supplied allergen information").font(.headline)
                            Text(listing.allergenInformation.isEmpty ? "No allergen information supplied. Ask the source organization." : listing.allergenInformation)
                            Text("This prototype does not certify food safety.")
                                .font(.footnote).foregroundStyle(FoodStyle.muted)
                        }
                    }
                    FoodCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(listing.status.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption.bold()).foregroundStyle(FoodStyle.accent)
                            Text("\(listing.quantityAvailable) \(listing.quantityUnit) available")
                                .font(.title2.bold())
                            Text("\(listing.originalQuantity) \(listing.quantityUnit) originally listed")
                                .font(.subheadline).foregroundStyle(FoodStyle.muted)
                            if store.role == .student && listing.originalPriceCents > 0 {
                                Text("Original \(DiscoveryFormat.money(listing.originalPriceCents)) per \(DiscoveryFormat.unit(listing.quantityUnit))")
                                    .strikethrough().foregroundStyle(FoodStyle.muted)
                                Text("50% off · \(DiscoveryFormat.money((listing.originalPriceCents + 1) / 2)) per \(DiscoveryFormat.unit(listing.quantityUnit))")
                                    .fontWeight(.bold).foregroundStyle(FoodStyle.green)
                                Text("Demo reservation only. No payment collected.")
                                    .font(.footnote).foregroundStyle(FoodStyle.muted)
                            }
                            if (store.role == .pantry || (store.role == .student && listing.originalPriceCents > 0))
                                && ["AVAILABLE", "PARTIALLY_RESERVED"].contains(listing.status)
                                && listing.pickupEnd > Date() && listing.quantityAvailable > 0 {
                                Stepper("Quantity to reserve: \(quantity) \(listing.quantityUnit)", value: $quantity, in: 1...listing.quantityAvailable)
                                    .accessibilityLabel("Quantity to reserve in \(listing.quantityUnit)")
                                    .accessibilityValue("\(quantity)")
                                if store.role == .student {
                                    Text("Demo total: \(DiscoveryFormat.money(((listing.originalPriceCents + 1) / 2) * quantity)) · no payment collected")
                                        .fontWeight(.bold)
                                }
                                Button {
                                    Task { await reserve(listing) }
                                } label: {
                                    Text(store.role == .student ? "Reserve student order" : "Reserve food")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent).tint(FoodStyle.accent)
                                .foregroundStyle(FoodStyle.buttonInk)
                                .disabled(store.isPerformingAction || store.selectedOrganizationID == nil || quantity > listing.quantityAvailable)
                            }
                            if let actionError {
                                Text(actionError).foregroundStyle(.red).accessibilityAddTraits(.updatesFrequently)
                            }
                        }
                    }
                    FoodDisclaimer()
                } else {
                    ContentUnavailableView("Listing unavailable", systemImage: "shippingbox", description: Text("This demonstration listing could not be found."))
                }
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle("Food details")
        .navigationDestination(isPresented: $showReservations) {
            ReservationsView(store: store)
        }
        .refreshable { await store.reload() }
        .onChange(of: listing?.quantityAvailable) { _, available in
            quantity = min(quantity, max(1, available ?? 1))
        }
    }

    private func reserve(_ listing: Listing) async {
        guard let organizationID = store.selectedOrganizationID,
              (1...listing.quantityAvailable).contains(quantity) else {
            actionError = "Choose a valid organization and quantity before reserving."
            return
        }
        do {
            _ = try await store.perform(.reserve(input: ReserveInput(listingId: listing.id, organizationId: organizationID, quantity: quantity)))
            actionError = nil
            showReservations = true
        } catch {
            actionError = error.localizedDescription
        }
    }
}

struct ReservationsView: View {
    @Bindable var store: AppStore
    @State private var cancellationID: String?
    @State private var actionError: String?
    @State private var feedback: String?

    private var mine: [Reservation] {
        (store.snapshot?.reservations ?? [])
            .filter { $0.organizationId == store.selectedOrganizationID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("YOUR COMMITMENTS")
                    .font(.caption.bold()).tracking(2).foregroundStyle(FoodStyle.accent)
                Text(store.role == .student ? "My orders" : "My reservations")
                    .font(.largeTitle.bold())
                Text(store.role == .student
                     ? "Demo orders only. No payment or real pickup service. Keep your pickup code ready."
                     : "Fictional campus sites. Keep your pickup code ready for the dining team.")
                    .foregroundStyle(FoodStyle.muted)

                if store.role == .pantry, let organizations = store.snapshot?.organizations {
                    Picker("Pickup organization / campus site", selection: $store.selectedOrganizationID) {
                        Text("Select a site").tag(Optional<String>.none)
                        ForEach(organizations.filter { ["FOOD_PANTRY", "REDISTRIBUTION_PARTNER"].contains($0.type) }) { organization in
                            Text(organization.name).tag(Optional(organization.id))
                        }
                    }
                    .tint(FoodStyle.accent)
                }
                if let feedback { Text(feedback).foregroundStyle(FoodStyle.green) }
                if let actionError { Text(actionError).foregroundStyle(.red) }
                if store.snapshot == nil {
                    Text(store.errorMessage ?? "Loading demonstration reservations…")
                        .foregroundStyle(FoodStyle.muted)
                } else {
                    reservationGroup("Upcoming", status: "RESERVED")
                    reservationGroup("Completed", status: "COMPLETED")
                    reservationGroup("Canceled", status: "CANCELED")
                }
                FoodDisclaimer()
            }
            .padding(16)
        }
        .background(FoodStyle.background)
        .navigationTitle(store.role == .student ? "My orders" : "My reservations")
        .refreshable { await store.reload() }
        .confirmationDialog("Cancel this reservation?", isPresented: Binding(
            get: { cancellationID != nil },
            set: { if !$0 { cancellationID = nil } }
        ), titleVisibility: .visible) {
            Button("Cancel reservation", role: .destructive) {
                if let id = cancellationID { Task { await cancel(id) } }
                cancellationID = nil
            }
        } message: {
            Text("Eligible inventory will become available again. This cannot be undone.")
        }
    }

    private func reservationGroup(_ title: String, status: String) -> some View {
        let matching = mine.filter { $0.status == status }
        return VStack(alignment: .leading, spacing: 12) {
            Text("\(title) · \(matching.count)").font(.title2.bold())
            if matching.isEmpty {
                Text("No \(title.lowercased()) \(store.role == .student ? "orders" : "reservations").")
                    .foregroundStyle(FoodStyle.muted)
                    .padding(.vertical, 8)
            } else {
                ForEach(matching) { reservation in
                    FoodCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(reservation.listingTitle).font(.title3.bold())
                            Text("\(reservation.organizationName) · \(reservation.quantity) \(reservation.quantityUnit)")
                                .foregroundStyle(FoodStyle.muted)
                            Label(DiscoveryFormat.pickup(reservation.pickupStart, reservation.pickupEnd), systemImage: "calendar")
                            Label(reservation.pickupLocation, systemImage: "mappin.and.ellipse")
                            Text("Pickup instructions: \(reservation.pickupInstructions)")
                            if let cents = reservation.priceCents {
                                Text("Demo total: \(DiscoveryFormat.money(cents)) · 50% off · no payment collected")
                                    .fontWeight(.semibold)
                            }
                            if reservation.status == "RESERVED" {
                                Text("Pickup code: \(reservation.pickupCode)")
                                    .font(.headline.monospacedDigit()).textSelection(.enabled)
                            }
                            Text("Reservation ID: \(reservation.id)")
                                .font(.caption).foregroundStyle(FoodStyle.muted).textSelection(.enabled)
                            if reservation.status == "RESERVED" && reservation.pickupEnd > Date() {
                                Button("Cancel reservation", role: .destructive) {
                                    cancellationID = reservation.id
                                }
                                .disabled(store.isPerformingAction)
                            }
                        }
                    }
                }
            }
        }
    }

    private func cancel(_ id: String) async {
        guard let organizationID = store.selectedOrganizationID,
              mine.contains(where: { $0.id == id && $0.status == "RESERVED" && $0.pickupEnd > Date() }) else {
            actionError = "Reservation is no longer eligible for cancellation."
            return
        }
        do {
            _ = try await store.perform(.cancel(id: id, org: organizationID))
            actionError = nil
            feedback = "Reservation canceled; eligible inventory restored."
        } catch {
            actionError = error.localizedDescription
            feedback = nil
        }
    }
}
