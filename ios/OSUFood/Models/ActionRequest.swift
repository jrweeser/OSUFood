import Foundation

// POST /api/action accepts role-selected organization IDs, not authenticated identities.
struct ListingInput: Encodable, Sendable {
    let title: String
    let description: String
    let category: String
    let quantity: Int
    let unit: String
    let originalPriceCents: Int
    let pickupLocation: String
    let pickupInstructions: String
    let pickupStart: Date
    let pickupEnd: Date
    let storageRequirements: String
    let allergenInformation: String
    let organizationId: String
}

struct ReserveInput: Encodable, Sendable {
    let listingId: String
    let organizationId: String
    let quantity: Int
}

enum ActionRequest: Encodable, Sendable {
    case create(input: ListingInput)
    case edit(id: String, org: String, input: ListingInput)
    case close(id: String, org: String)
    case reserve(input: ReserveInput)
    case cancel(id: String, org: String)
    case complete(id: String, org: String, code: String)
    case reset

    private enum CodingKeys: String, CodingKey { case action, input, id, org, code, confirm }

    func encode(to encoder: Encoder) throws {
        var body = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .create(let input):
            try body.encode("create", forKey: .action)
            try body.encode(input, forKey: .input)
        case .edit(let id, let org, let input):
            try body.encode("edit", forKey: .action)
            try body.encode(id, forKey: .id)
            try body.encode(org, forKey: .org)
            try body.encode(input, forKey: .input)
        case .close(let id, let org):
            try body.encode("close", forKey: .action)
            try body.encode(id, forKey: .id)
            try body.encode(org, forKey: .org)
        case .reserve(let input):
            try body.encode("reserve", forKey: .action)
            try body.encode(input, forKey: .input)
        case .cancel(let id, let org):
            try body.encode("cancel", forKey: .action)
            try body.encode(id, forKey: .id)
            try body.encode(org, forKey: .org)
        case .complete(let id, let org, let code):
            try body.encode("complete", forKey: .action)
            try body.encode(id, forKey: .id)
            try body.encode(org, forKey: .org)
            try body.encode(code, forKey: .code)
        case .reset:
            try body.encode("reset", forKey: .action)
            try body.encode("RESET DEMO", forKey: .confirm)
        }
    }
}

enum ActionResult: Sendable {
    case listing(id: String) // create/edit
    case reservation(id: String, pickupCode: String, priceCents: Int?) // reserve
    case success // close/cancel/complete/reset
}
