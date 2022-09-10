import Foundation

public enum SkyResolverRegistrationError: LocalizedError {
    case typeAlreadyRegistered

    public var failureReason: String? {
        switch self {
        case .typeAlreadyRegistered:
            return "Type has already been registered."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .typeAlreadyRegistered:
            return "user `override` parameter to user the latest object registered OR register conformance to another protocol"
        }
    }
}
