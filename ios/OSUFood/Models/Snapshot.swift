import Foundation

// Matches the complete JSON returned by GET /api/state. Dates are decoded by APIClient.
struct Snapshot: Codable {
    let organizations: [Organization]
    let listings: [Listing]
    let reservations: [Reservation]
    let activity: [Activity]
    let metrics: Metrics
}

struct Organization: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let description: String
    let location: String
    let createdAt: Date
}

struct Listing: Codable, Identifiable {
    let id: String
    let organizationId: String
    let organizationName: String
    let title: String
    let description: String
    let category: String
    let quantityAvailable: Int
    let originalQuantity: Int
    let quantityUnit: String
    let originalPriceCents: Int
    let pickupLocation: String
    let pickupInstructions: String
    let pickupStart: Date
    let pickupEnd: Date
    let storageRequirements: String
    let allergenInformation: String
    let status: String
    let createdAt: Date
    let updatedAt: Date
}

struct Reservation: Codable, Identifiable {
    let id: String
    let listingId: String
    let organizationId: String
    let organizationName: String
    let listingTitle: String
    let quantityUnit: String
    let quantity: Int
    let priceCents: Int?
    let status: String
    let pickupCode: String
    let pickupLocation: String
    let pickupInstructions: String
    let pickupStart: Date
    let pickupEnd: Date
    let createdAt: Date
    let confirmedAt: Date?
    let collectedAt: Date?
    let canceledAt: Date?
}

struct Activity: Codable, Identifiable {
    let id: Int
    let action: String
    let entityType: String
    let entityId: String
    let description: String
    let timestamp: Date
}

struct Metrics: Codable {
    let completed: Int
    let canceled: Int
    let active: Int
    let organizations: Int
    let rate: Int
    let byUnit: [UnitQuantity]
    let byCategory: [CategoryQuantity]
    let byDay: [DayCount]
}

struct UnitQuantity: Codable {
    let unit: String
    let quantity: Int
}

struct CategoryQuantity: Codable {
    let category: String
    let unit: String
    let quantity: Int
}

struct DayCount: Codable {
    let day: String // YYYY-MM-DD; not an instant in time.
    let count: Int
}
