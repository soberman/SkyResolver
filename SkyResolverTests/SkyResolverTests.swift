import XCTest
@testable import SkyResolver

class SkyResolverTests: XCTestCase {

    override func tearDown() {
        SkyResolver.shared.reset()
    }

    func testRegisterFails_forConsequentRegistrationOfSameProtocol() {
        let resultA = SkyResolver.shared.register {
            A() as TestSubject
        }
        switch resultA {
        case .success: XCTAssertTrue(true)
        case .failure: XCTAssertTrue(false)
        }

        let resultB = SkyResolver.shared.register {
            C() as TestSubject
        }
        switch resultB {
        case .success: XCTAssertTrue(false)
        case .failure: XCTAssertTrue(true)
        }
    }

    func testRegisterSucceeds_overridingAlreadyRegisteredProtocol() {
        let resultA = SkyResolver.shared.register {
            A() as TestSubject
        }
        switch resultA {
        case .success: XCTAssertTrue(true)
        case .failure: XCTAssertTrue(false)
        }

        let resultB = SkyResolver.shared.register(override: true) {
            C() as TestSubject
        }
        switch resultB {
        case .success: XCTAssertTrue(true)
        case .failure: XCTAssertTrue(false)
        }
    }

    func testRegisteringWithProtocolCasting() {
        SkyResolver.shared.register { A() as TestSubject }
        SkyResolver.shared.register { B(a: try! SkyResolver.shared.resolve()) }

        let _: B = try! SkyResolver.shared.resolve()
        XCTAssertTrue(true, "We did not encounter fatal exception and resolved object successfully")
    }

    func testRegisterAndResolveOfComplexDependantObjects() {
        SkyResolver.shared.register { Worker() as Workerhaving }
        SkyResolver.shared.register { Manager(worker: try! SkyResolver.shared.resolve()) as ManagerHaving }
        SkyResolver.shared.register { Director(manager: try! SkyResolver.shared.resolve()) as DirectorHaving }

        let _: DirectorHaving = try! SkyResolver.shared.resolve()
        XCTAssertTrue(true, "We did not encounter fatal exception and resolved object successfully")
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

class D {
    let e: E
    init(e: E) {
        self.e = e
    }
}
class E {
    let d: D
    init(d: D) {
        self.d = d
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
