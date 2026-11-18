import Foundation
import Observation

enum UserRole: String, CaseIterable, Identifiable {
    case staff, pantry, student, admin

    var id: String { rawValue }
}

// Role and organization are demo preview choices, not authentication or authorization.
@MainActor @Observable
final class AppStore {
    private(set) var snapshot: Snapshot?
    private(set) var isLoading = false
    private(set) var isPerformingAction = false
    private(set) var errorMessage: String?
    var role: UserRole = .pantry {
        didSet {
            if role != oldValue {
                selectedOrganizationID = switch role {
                case .staff: "mcnary"
                case .pantry: "pantry"
                case .student: "student"
                case .admin: nil
                }
            }
        }
    }
    var selectedOrganizationID: String? = "pantry"

    private let api: APIClient

    init(api: APIClient = APIClient()) {
        self.api = api
    }

    func load() async {
        await reload()
    }

    func reload() async {
        isLoading = true
        defer { isLoading = false }
        do {
            snapshot = try await api.fetchState()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func perform(_ action: ActionRequest) async throws -> ActionResult {
        isPerformingAction = true
        errorMessage = nil
        defer { isPerformingAction = false }
        do {
            let result = try await api.send(action)
            do {
                snapshot = try await api.fetchState()
            } catch {
                throw StoreError.refreshFailed(error.localizedDescription)
            }
            errorMessage = nil
            return result
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}

private enum StoreError: LocalizedError {
    case refreshFailed(String)

    var errorDescription: String? {
        switch self {
        case .refreshFailed(let message):
            return "Action may have succeeded, but updated state could not load: \(message). Reload before retrying."
        }
    }
}
