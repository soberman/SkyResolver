import Foundation

private typealias ServiceID = Int


/// Dependency resolver container.
public final class SkyResolver {

    /// A singleton object used to operate on the SkyResolver.
    static let shared = SkyResolver()
    private init() {}

    private let lock = NSRecursiveLock()
    private var registeredServices = [ServiceID : () -> Any]()

}

public extension SkyResolver {

    /// Registeres provided type to be resolved in the future with the constructor closure.
    /// - Parameters:
    ///   - override: Whether it should override already registered service of the same type or not
    ///   - serviceFactory: Service constructor, that is going to be used to initialize a service
    /// - Returns: Result with either a `success` for successfull registration of the service whithing the resolver or a `failure(SkyRegistrationError)`
    @discardableResult
    func register<Service>(override: Bool = false, _ serviceFactory: @escaping () -> Service) -> Result<Void, SkyRegistrationError> {
        lock.lock()
        defer { lock.unlock() }

        guard override == false else {
            registerFactory(serviceFactory)
            return .success(Void())
        }

        if contains(Service.self) {
            return .failure(.typeAlreadyRegistered)
        } else {
            registerFactory(serviceFactory)
            return .success(Void())
        }
    }


    /// Makes a lookup through the registered services and returns the one that fits the type of the generic parameter.
    /// - Returns: Service, that fits the generic type constraint
    /// - Throws: `SkyResolveError`
    func resolve<Service>() throws -> Service {
        lock.lock()
        defer { lock.unlock() }
        
        guard contains(Service.self),
              let service: Service = resolvedService()
        else {
            throw SkyResolveError.typeNotRegistered
        }

        return service
    }


    /// Removes all registered types. Has completely prestine state afterwards.
    func reset() {
        registeredServices.removeAll()
    }

}

private extension SkyResolver {

    func objectIdentifier<Service>(for service: Service.Type) -> ServiceID {
        ObjectIdentifier(service).hashValue
    }

    func contains<Service>(_ service: Service.Type) -> Bool {
        let identifier = objectIdentifier(for: service)
        return registeredServices.contains(where: { $0.key == identifier })
    }

    func registerFactory<Service>(_ serviceFactory: @escaping () -> Service) {
        let identifier = objectIdentifier(for: Service.self)
        registeredServices[identifier] = serviceFactory
    }

    func resolvedService<Service>() -> Service? {
        let identifier = objectIdentifier(for: Service.self)
        let serviceFactory = registeredServices[identifier]
        return serviceFactory?() as? Service
    }

}
