import XCTest
@testable import SkyResolver

class SkyResolverTests: XCTestCase {

    override func tearDown() {
        SkyContainer.shared.reset()
    }

    func testRegisterFails_forConsequentRegistrationOfSameProtocol() {
        let resultA = SkyContainer.shared.register {
            A() as TestSubject
        }
        switch resultA {
        case .success: XCTAssertTrue(true)
        case .failure: XCTAssertTrue(false)
        }

        let resultB = SkyContainer.shared.register {
            C() as TestSubject
        }
        switch resultB {
        case .success: XCTAssertTrue(false)
        case .failure: XCTAssertTrue(true)
        }
    }

    func testRegisterSucceeds_overridingAlreadyRegisteredProtocol() {
        let resultA = SkyContainer.shared.register {
            A() as TestSubject
        }
        switch resultA {
        case .success: XCTAssertTrue(true)
        case .failure: XCTAssertTrue(false)
        }

        let resultB = SkyContainer.shared.register(override: true) {
            C() as TestSubject
        }
        switch resultB {
        case .success: XCTAssertTrue(true)
        case .failure: XCTAssertTrue(false)
        }
    }

    func testRegisteringWithProtocolCasting() {
        SkyContainer.shared.register { A() as TestSubject }
        SkyContainer.shared.register { B(a: try! SkyContainer.shared.resolve()) }

        let _: B = try! SkyContainer.shared.resolve()
        XCTAssertTrue(true, "We did not encounter fatal exception and resolved object successfully")
    }

    func testRegisterAndResolveOfComplexDependantObjects() {
        SkyContainer.shared.register { Worker() as Workerhaving }
        SkyContainer.shared.register { Manager(worker: try! SkyContainer.shared.resolve()) as ManagerHaving }
        SkyContainer.shared.register { Director(manager: try! SkyContainer.shared.resolve()) as DirectorHaving }

        let _: DirectorHaving = try! SkyContainer.shared.resolve()
        XCTAssertTrue(true, "We did not encounter fatal exception and resolved object successfully")
    }

    func testCircularDependency() {
        var didTriggerCircularDependencyError = false

        SkyContainer.shared.register { Egg(chicken: try! SkyContainer.shared.resolve()) }
        SkyContainer.shared.register { () -> Chicken in
            do {
                return Chicken(egg: try SkyContainer.shared.resolve())
            } catch let error {
                if let skyError = error as? SkyResolveError, skyError == .circularDependency {
                    didTriggerCircularDependencyError = true
                }
                return Chicken(egg: Egg())
            }
        }

        let _: Egg = try! SkyContainer.shared.resolve()
        XCTAssertTrue(didTriggerCircularDependencyError)
    }

    func testCircularDependencyCheckResetsAfterBeingTrigerred() {
        var didTriggerCircularDependencyError = false

        SkyContainer.shared.register { Egg(chicken: try! SkyContainer.shared.resolve()) }
        SkyContainer.shared.register { () -> Chicken in
            do {
                return Chicken(egg: try SkyContainer.shared.resolve())
            } catch let error {
                if error is SkyResolveError {
                    didTriggerCircularDependencyError = true
                }
                return Chicken(egg: Egg())
            }
        }

        let _: Egg = try! SkyContainer.shared.resolve()
        XCTAssertTrue(didTriggerCircularDependencyError)

        didTriggerCircularDependencyError = false
        let _: Egg = try! SkyContainer.shared.resolve()
        XCTAssertTrue(didTriggerCircularDependencyError)
    }

}

protocol TestSubject: AnyObject {}

class A: TestSubject {}

class C: TestSubject {
    let sample = "sample"
}

class B {
    let a: TestSubject
    init(a: TestSubject) {
        self.a = a
    }
}

class Egg {
    let chicken: Chicken
    init(chicken: Chicken) {
        self.chicken = chicken
    }
    convenience init() {
        self.init(chicken: Chicken())
    }
}
class Chicken {
    let egg: Egg!
    init(egg: Egg?) {
        self.egg = egg
    }
    convenience init() {
        self.init(egg: nil)
    }
}

protocol Workerhaving {}
class Worker: Workerhaving {}
protocol ManagerHaving {}
class Manager: ManagerHaving {
    let worker: Workerhaving
    init(worker: Workerhaving) {
        self.worker = worker
    }
}
protocol DirectorHaving {}
class Director: DirectorHaving {
    let manager: ManagerHaving
    init(manager: ManagerHaving) {
        self.manager = manager
    }
}
