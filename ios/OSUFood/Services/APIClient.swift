import Foundation

// localhost reaches the host Mac from iOS Simulator; a physical device needs a reachable host URL.
final class APIClient: Sendable {
    static let simulatorURL = URL(string: "http://localhost:3000")!

    let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = APIClient.simulatorURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchState() async throws -> Snapshot {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/state"))
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let data = try await send(request)
        do {
            return try Self.decoder().decode(Snapshot.self, from: data)
        } catch {
            throw APIClientError.invalidResponse("Could not decode /api/state: \(error.localizedDescription)")
        }
    }

    func send(_ action: ActionRequest) async throws -> ActionResult {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/action"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try Self.encoder().encode(action)
        let data = try await send(request)

        // A 2xx status alone is not proof of success: each action has a specific result shape.
        let response: ActionResponse
        do {
            response = try JSONDecoder().decode(ActionResponse.self, from: data)
        } catch {
            throw APIClientError.invalidResponse("Could not decode /api/action: \(error.localizedDescription)")
        }
        if let error = response.error {
            throw APIClientError.server(error)
        }
        if response.ok == false {
            throw APIClientError.invalidResponse("Action was not successful.")
        }
        switch action {
        case .create, .edit:
            guard let id = response.id, !id.isEmpty else {
                throw APIClientError.invalidResponse("Listing action did not return an ID.")
            }
            return .listing(id: id)
        case .reserve(let input):
            guard let id = response.id, !id.isEmpty,
                  let code = response.pickupCode, !code.isEmpty,
                  response.hasPriceCents,
                  (input.organizationId != "student" || response.priceCents != nil) else {
                throw APIClientError.invalidResponse("Reservation did not return a pickup code and price.")
            }
            return .reservation(id: id, pickupCode: code, priceCents: response.priceCents)
        case .close, .cancel, .complete, .reset:
            guard response.ok == true else {
                throw APIClientError.invalidResponse("Action did not confirm success.")
            }
            return .success
        }
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .cannotConnectToHost, .cannotFindHost, .notConnectedToInternet, .networkConnectionLost, .timedOut:
                throw APIClientError.connection("Cannot reach \(baseURL.host ?? "server") at \(baseURL.absoluteString). Start the local web server, or use a reachable host URL on a device. (\(error.localizedDescription))")
            default:
                throw APIClientError.connection("Network request failed: \(error.localizedDescription)")
            }
        }
        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse("Server returned a non-HTTP response.")
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? JSONDecoder().decode(ServerError.self, from: data).error)
            throw APIClientError.http(status: http.statusCode, message: message)
        }
        return data
    }

    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let value = try decoder.singleValueContainer().decode(String.self)
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let standard = ISO8601DateFormatter()
            standard.formatOptions = [.withInternetDateTime]
            guard let date = fractional.date(from: value) ?? standard.date(from: value) else {
                throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(), debugDescription: "Invalid ISO 8601 date: \(value)")
            }
            return date
        }
        return decoder
    }

    private static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Zulu UTC, accepted by z.string().datetime().
        return encoder
    }
}

enum APIClientError: LocalizedError {
    case connection(String)
    case http(status: Int, message: String?)
    case server(String)
    case invalidResponse(String)

    var errorDescription: String? {
        switch self {
        case .connection(let message), .server(let message), .invalidResponse(let message):
            return message
        case .http(let status, let message):
            return "Server error (HTTP \(status)): \(message?.isEmpty == false ? message! : "Request failed.")"
        }
    }
}

private struct ServerError: Decodable {
    let error: String
}

private struct ActionResponse: Decodable {
    let id: String?
    let pickupCode: String?
    let priceCents: Int?
    let hasPriceCents: Bool
    let ok: Bool?
    let error: String?

    private enum CodingKeys: String, CodingKey { case id, pickupCode, priceCents, ok, error }

    init(from decoder: Decoder) throws {
        let body = try decoder.container(keyedBy: CodingKeys.self)
        id = try body.decodeIfPresent(String.self, forKey: .id)
        pickupCode = try body.decodeIfPresent(String.self, forKey: .pickupCode)
        hasPriceCents = body.contains(.priceCents)
        priceCents = try body.decodeIfPresent(Int.self, forKey: .priceCents)
        ok = try body.decodeIfPresent(Bool.self, forKey: .ok)
        error = try body.decodeIfPresent(String.self, forKey: .error)
    }
}
