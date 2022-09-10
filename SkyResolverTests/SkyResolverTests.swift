import XCTest
@testable import SkyResolver

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
        SkyResolver.shared.register { B(a: SkyResolver.shared.resolve()) }

        let _: B = SkyResolver.shared.resolve()
        XCTAssertTrue(true, "We did not encounter fatal exception and resolved object successfully")
    }

}
