import SwiftUI

// Staff views operate on fictional demo records. Selecting a role does not authenticate anyone.
struct StaffDashboardView: View {
    @Bindable var store: AppStore
    let onCreate: () -> Void
    let onEdit: (Listing) -> Void
    let onManagePickups: () -> Void

    @State private var search = ""
    @State private var errorMessage: String?
    @State private var feedback: String?
    @State private var listingToClose: Listing?

    private var facilities: [Organization] {
        store.snapshot?.organizations.filter { $0.type == "DINING_FACILITY" } ?? []
    }

    private var facilityID: String { store.selectedOrganizationID ?? facilities.first?.id ?? "" }
    private var listings: [Listing] {
        store.snapshot?.listings.filter { $0.organizationId == facilityID } ?? []
    }
    private var reservations: [Reservation] {
        let ids = Set(listings.map(\.id))
        return store.snapshot?.reservations.filter { ids.contains($0.listingId) } ?? []
    }

    var body: some View {
        List {
            Section {
                Text("Academic demonstration. Fictional facilities and food; no real pickups or food-safety certification. Staff role selection is not authentication.")
                    .font(.footnote).foregroundStyle(.secondary)
                facilityPicker
                Button(action: onCreate) { Label("Create food listing", systemImage: "plus") }
                Button(action: onManagePickups) { Label("Manage pickups", systemImage: "shippingbox") }
            } header: {
                Text("Dining operations")
            }

            if let feedback {
                Section { Text(feedback).foregroundStyle(.green) }
            }
            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }

            Section("Facility overview") {
                LabeledContent("Active listings", value: "\(listings.filter { ["AVAILABLE", "PARTIALLY_RESERVED"].contains($0.status) }.count)")
                LabeledContent("Pending pickups", value: "\(reservations.filter { $0.status == "RESERVED" }.count)")
                LabeledContent("Completed pickups", value: "\(reservations.filter { $0.status == "COMPLETED" }.count)")
                if let byUnit = store.snapshot?.metrics.byUnit {
                    LabeledContent("Platform-wide redistributed", value: byUnit.map { "\($0.quantity) \($0.unit)" }.joined(separator: " · ").isEmpty ? "0" : byUnit.map { "\($0.quantity) \($0.unit)" }.joined(separator: " · "))
                }
            }

            Section("Your listings") {
                TextField("Search listings", text: $search)
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel("Search your listings")
                let matches = listings.filter { search.isEmpty || $0.title.localizedCaseInsensitiveContains(search) }
                if matches.isEmpty {
                    Text(listings.isEmpty ? "No listings yet. Create your first listing." : "No listings match your search.")
                        .foregroundStyle(.secondary)
                }
                ForEach(matches) { listing in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(listing.title).font(.headline)
                        Text(listing.status.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text("\(listing.quantityAvailable) / \(listing.originalQuantity) \(listing.quantityUnit) available")
                        Text("Pickup \(listing.pickupStart.formatted(date: .abbreviated, time: .shortened)) – \(listing.pickupEnd.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                        HStack {
                            Button("Edit") { onEdit(listing) }
                                .disabled(listing.status == "CLOSED" || store.isPerformingAction)
                            if listing.status != "CLOSED" {
                                Button("Close listing", role: .destructive) { listingToClose = listing }
                                    .disabled(store.isPerformingAction)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)
                }
            }

            if let activity = store.snapshot?.activity.prefix(5), !activity.isEmpty {
                Section("Recent activity") {
                    ForEach(Array(activity), id: \.id) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.description)
                            Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Staff dashboard")
        .confirmationDialog("Close this listing? Existing reservations remain available for pickup.", isPresented: Binding(
            get: { listingToClose != nil },
            set: { if !$0 { listingToClose = nil } }
        ), titleVisibility: .visible) {
            Button("Close listing", role: .destructive) {
                guard let listing = listingToClose else { return }
                listingToClose = nil
                Task {
                    do {
                        _ = try await store.perform(.close(id: listing.id, org: listing.organizationId))
                        feedback = "Listing closed."
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private var facilityPicker: some View {
        Picker("Dining facility", selection: $store.selectedOrganizationID) {
            ForEach(facilities) { facility in
                Text(facility.name).tag(Optional(facility.id))
            }
        }
    }
}

struct ListingEditorView: View {
    @Bindable var store: AppStore
    let listing: Listing?
    let onSaved: () -> Void

    @State private var organizationID: String
    @State private var title: String
    @State private var foodDescription: String
    @State private var category: String
    @State private var quantity: Int
    @State private var unit: String
    @State private var originalPrice: String
    @State private var pickupLocation: String
    @State private var pickupInstructions: String
    @State private var pickupStart: Date
    @State private var pickupEnd: Date
    @State private var storageRequirements: String
    @State private var allergenInformation: String
    @State private var errorMessage: String?

    private let categories = ["Produce", "Prepared meals", "Bakery", "Dairy", "Packaged"]
    private let units = ["boxes", "portions", "items", "bags", "trays"]
    private let locations = ["McNary Dining Center", "Arnold Dining Center", "Marketplace West"]

    init(store: AppStore, listing: Listing? = nil, onSaved: @escaping () -> Void) {
        self.store = store
        self.listing = listing
        self.onSaved = onSaved
        let facilities = store.snapshot?.organizations.filter { $0.type == "DINING_FACILITY" } ?? []
        let id = listing?.organizationId ?? store.selectedOrganizationID ?? facilities.first?.id ?? ""
        _organizationID = State(initialValue: id)
        _title = State(initialValue: listing?.title ?? "")
        _foodDescription = State(initialValue: listing?.description ?? "")
        _category = State(initialValue: listing?.category ?? "Produce")
        _quantity = State(initialValue: listing?.originalQuantity ?? 20)
        _unit = State(initialValue: listing?.quantityUnit ?? "boxes")
        _originalPrice = State(initialValue: listing.map { String(format: "%.2f", Double($0.originalPriceCents) / 100) } ?? "8.00")
        _pickupLocation = State(initialValue: listing?.pickupLocation ?? facilities.first(where: { $0.id == id })?.name ?? "McNary Dining Center")
        _pickupInstructions = State(initialValue: listing?.pickupInstructions ?? "Collect during the listed pickup window. Staff will confirm your pickup code at the dining center. Do not take food from an unattended box.")
        _pickupStart = State(initialValue: listing?.pickupStart ?? Date().addingTimeInterval(4 * 3600))
        _pickupEnd = State(initialValue: listing?.pickupEnd ?? Date().addingTimeInterval(28 * 3600))
        _storageRequirements = State(initialValue: listing?.storageRequirements ?? "")
        _allergenInformation = State(initialValue: listing?.allergenInformation ?? "")
    }

    private var facilities: [Organization] {
        store.snapshot?.organizations.filter { $0.type == "DINING_FACILITY" } ?? []
    }

    var body: some View {
        Form {
            Section {
                Text("Clear details help partners collect food on time. Handling and allergen details come from your organization; this prototype does not certify food safety.")
                    .font(.footnote).foregroundStyle(.secondary)
                Text("Fictional demonstration only. No real food or payment; role selection is not authentication.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red).accessibilityAddTraits(.updatesFrequently) }
            }
            Section("Food details") {
                Picker("Dining facility", selection: $organizationID) {
                    ForEach(facilities) { Text($0.name).tag($0.id) }
                }
                .disabled(listing != nil)
                .onChange(of: organizationID) { _, newID in
                    if listing == nil, let facility = facilities.first(where: { $0.id == newID }) {
                        pickupLocation = facility.name
                    }
                }
                TextField("Food title", text: $title)
                    .accessibilityLabel("Food title, required")
                TextField("Description", text: $foodDescription, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityLabel("Description, required")
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10_000)
                Picker("Unit", selection: $unit) {
                    ForEach(units, id: \.self) { Text($0).tag($0) }
                }
                TextField("Original price per unit ($)", text: $originalPrice)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Original price per unit in dollars, required")
                Text("Student reservations show half this original price. Demo only; no payment collected.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Staff-supervised pickup") {
                Picker("Pickup location", selection: $pickupLocation) {
                    ForEach(locations, id: \.self) { Text($0).tag($0) }
                }
                TextField("Pickup instructions", text: $pickupInstructions, axis: .vertical)
                    .lineLimit(2...5)
                    .accessibilityLabel("Pickup instructions, required")
                Text("No automated ready-for-pickup alerts. Do not leave food in an unattended box.")
                    .font(.footnote).foregroundStyle(.secondary)
                DatePicker("Pickup starts", selection: $pickupStart, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Pickup ends", selection: $pickupEnd, displayedComponents: [.date, .hourAndMinute])
            }
            Section("Organization-supplied information") {
                TextField("Storage and handling information", text: $storageRequirements, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Allergen information", text: $allergenInformation, axis: .vertical)
                    .lineLimit(2...5)
                Text("Food safety must be assessed outside this prototype.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button(listing == nil ? "Publish listing" : "Save changes") {
                    save()
                }
                .disabled(store.isPerformingAction)
            }
        }
        .navigationTitle(listing == nil ? "Create listing" : "Edit listing")
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = foodDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let instructions = pickupInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !organizationID.isEmpty, facilities.contains(where: { $0.id == organizationID }),
              (3...100).contains(trimmedTitle.count), (3...1000).contains(trimmedDescription.count),
              (3...500).contains(instructions.count),
              storageRequirements.trimmingCharacters(in: .whitespacesAndNewlines).count <= 500,
              allergenInformation.trimmingCharacters(in: .whitespacesAndNewlines).count <= 500,
              pickupEnd > pickupStart, pickupEnd > Date() else {
            errorMessage = "Check required details, text lengths, and pickup window. Pickup must end in the future."
            return
        }
        guard let price = Decimal(string: originalPrice.trimmingCharacters(in: .whitespacesAndNewlines), locale: Locale(identifier: "en_US_POSIX")),
              price >= Decimal(string: "0.01")!, price <= 10_000,
              let cents = Int(exactly: NSDecimalNumber(decimal: price * 100)), cents > 0 else {
            errorMessage = "Enter a price between $0.01 and $10,000.00, with at most two decimal places."
            return
        }
        if let listing {
            let reserved = listing.originalQuantity - listing.quantityAvailable
            guard listing.status != "CLOSED", quantity >= reserved, reserved == 0 || unit == listing.quantityUnit else {
                errorMessage = "Quantity cannot be below reserved amount; unit cannot change after reservations. Closed listings cannot be edited."
                return
            }
        }
        let input = ListingInput(
            title: trimmedTitle, description: trimmedDescription, category: category,
            quantity: quantity, unit: unit, originalPriceCents: cents,
            pickupLocation: pickupLocation, pickupInstructions: instructions,
            pickupStart: pickupStart, pickupEnd: pickupEnd,
            storageRequirements: storageRequirements.trimmingCharacters(in: .whitespacesAndNewlines),
            allergenInformation: allergenInformation.trimmingCharacters(in: .whitespacesAndNewlines),
            organizationId: organizationID
        )
        errorMessage = nil
        Task {
            do {
                if let listing {
                    _ = try await store.perform(.edit(id: listing.id, org: listing.organizationId, input: input))
                } else {
                    _ = try await store.perform(.create(input: input))
                }
                onSaved()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct PickupManagementView: View {
    @Bindable var store: AppStore
    @State private var pickupCodes: [String: String] = [:]
    @State private var errorMessage: String?
    @State private var feedback: String?

    private var facilities: [Organization] {
        store.snapshot?.organizations.filter { $0.type == "DINING_FACILITY" } ?? []
    }
    private var facilityID: String { store.selectedOrganizationID ?? facilities.first?.id ?? "" }
    private var pickups: [Reservation] {
        let ids = Set(store.snapshot?.listings.filter { $0.organizationId == facilityID }.map(\.id) ?? [])
        return store.snapshot?.reservations.filter { ids.contains($0.listingId) } ?? []
    }

    var body: some View {
        List {
            Section {
                Text("Match the pickup code before confirming collection. Each completion is recorded once. Fictional demo pickups only; role selection is not authentication.")
                    .font(.footnote).foregroundStyle(.secondary)
                Picker("Dining facility", selection: $store.selectedOrganizationID) {
                    ForEach(facilities) { Text($0.name).tag(Optional($0.id)) }
                }
            }
            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
            if let feedback { Section { Text(feedback).foregroundStyle(.green) } }
            pickupSection("Pending pickups", status: "RESERVED")
            pickupSection("Completed pickups", status: "COMPLETED")
        }
        .navigationTitle("Pickup management")
    }

    private func pickupSection(_ title: String, status: String) -> some View {
        let matches = pickups.filter { $0.status == status }
        return Section("\(title) · \(matches.count)") {
            if matches.isEmpty {
                Text("No \(status == "RESERVED" ? "pending" : "completed") pickups.")
                    .foregroundStyle(.secondary)
            }
            ForEach(matches) { reservation in
                VStack(alignment: .leading, spacing: 8) {
                    Text(reservation.listingTitle).font(.headline)
                    Text("\(reservation.organizationName) · \(reservation.quantity) \(reservation.quantityUnit)")
                    Text("Pickup \(reservation.pickupStart.formatted(date: .abbreviated, time: .shortened)) – \(reservation.pickupEnd.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                    Text("Location: \(reservation.pickupLocation)")
                    Text("Instructions: \(reservation.pickupInstructions)")
                    if let cents = reservation.priceCents {
                        Text("Demo total: \((Double(cents) / 100).formatted(.currency(code: "USD"))) · no payment collected")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    if status == "RESERVED" {
                        TextField("Pickup code", text: Binding(
                            get: { pickupCodes[reservation.id] ?? "" },
                            set: { pickupCodes[reservation.id] = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .accessibilityLabel("Pickup code for \(reservation.listingTitle), reservation \(reservation.id)")
                        Button("Confirm pickup") { confirm(reservation) }
                            .disabled(store.isPerformingAction || (pickupCodes[reservation.id] ?? "").isEmpty)
                    }
                    Text("Reservation ID: \(reservation.id)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func confirm(_ reservation: Reservation) {
        let code = (pickupCodes[reservation.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else { errorMessage = "Enter pickup code before confirming."; return }
        Task {
            do {
                _ = try await store.perform(.complete(id: reservation.id, org: facilityID, code: code))
                pickupCodes[reservation.id] = nil
                errorMessage = nil
                feedback = "Pickup confirmed. Impact updated."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
