import Foundation

private typealias ServiceID = Int

public final class SkyResolver {

    static let shared = SkyResolver()
    private init() {}

    private var registeredServices = [ServiceID : () -> Any]()

}

public extension SkyResolver {

    @discardableResult
    func register<Service>(override: Bool = false, _ serviceFactory: @escaping () -> Service) -> Result<Void, SkyResolverRegistrationError> {
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

    func resolve<Service>() -> Service {
        guard contains(Service.self), let service: Service = resolvedService() else {
            fatalError("\(Service.self) has not been registered.")
        }

        return service
    }

}

extension SkyResolver {

    func contains<Service>(_ service: Service.Type) -> Bool {
        let identifier = objectIdentifier(for: service)
        return registeredServices.contains(where: { $0.key == identifier })
    }

    func reset() {
        registeredServices.removeAll()
    }

}

private extension SkyResolver {

    func objectIdentifier<Service>(for service: Service.Type) -> ServiceID {
        ObjectIdentifier(service).hashValue
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
