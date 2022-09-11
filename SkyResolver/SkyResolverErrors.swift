import Foundation

public enum SkyRegistrationError: LocalizedError {
    case typeAlreadyRegistered

    public var failureReason: String? {
        switch self {
        case .typeAlreadyRegistered:
            return "Type has already been registered"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .typeAlreadyRegistered:
            return "User `override` parameter to user the latest object registered OR register conformance to another protocol"
        }
    }
}

public enum SkyResolveError: LocalizedError {
    case typeNotRegistered
    case circularDependency

    public var failureReason: String? {
        switch self {
        case .typeNotRegistered:
            return "Trying resolve a type that has not been registered yet"
        case .circularDependency:
            return "Circular dependecy between registered types has been detected. This is not supported. Aborting"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .typeNotRegistered:
            return "Make sure to register the type you want to resolve"
        case .circularDependency:
            return "Try to break circular dependency between registered services with another pattern for the dendency injection"
        }
    }
}
