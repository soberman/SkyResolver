import Foundation

private typealias ServiceID = Int


/// Dependency resolver container. Use this class to register your dependencies upfront before instantiation of your classes that you are dependent on.
public final class SkyContainer {

    /// A singleton object used to operate on the SkyResolver.
    public static let shared = SkyContainer()
    public init() {}

    private let lock = NSRecursiveLock()
    private var registeredServices = [ServiceID : () -> Any]()
    private var serviceResolveAttempts = [ServiceID : Int]()

}

public extension SkyContainer {

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
        let serviceID = objectIdentifier(for: Service.self)
        defer {
            resetIncrementCounter(for: serviceID)
            lock.unlock()
        }

        try incrementServiceResolveCounter(for: serviceID)
        let service = try resolveService(Service.self)

        return service
    }

    /// Removes all registered types. Has completely prestine state afterwards.
    func reset() {
        registeredServices.removeAll()
    }

}

private extension SkyContainer {

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

    func resolveService<Service>(_ service: Service.Type) throws -> Service {
        guard contains(service), let service: Service = instantiatedService() else {
            throw SkyResolveError.typeNotRegistered
        }

        return service
    }

    func instantiatedService<Service>() -> Service? {
        let identifier = objectIdentifier(for: Service.self)
        let serviceFactory = registeredServices[identifier]
        return serviceFactory?() as? Service
    }

    func incrementServiceResolveCounter(for serviceID: ServiceID) throws {
        guard serviceResolveAttempts[serviceID] == nil else {
            throw SkyResolveError.circularDependency
        }

        serviceResolveAttempts[serviceID] = 1
    }

    func resetIncrementCounter(for serviceID: ServiceID) {
        serviceResolveAttempts[serviceID] = nil
    }

}
