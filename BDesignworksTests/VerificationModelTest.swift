//
//  VerificationModelTest.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 14/11/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//


import XCTest
import Foundation
import Nocilla
@testable import Pair_Up

class VerificationModelTest: XCTestCase {
    
    private typealias MockContainer = MVPContainer<VerificationViewMock, VerificationPresenterMock, VerificationModel>
    
    private var container: MockContainer!
    
    var userNotRegisteredJson: String!
    var userWithProviderJson: String!
    var userWithNoProviderJson: String!
    let providerName = "HBF"
    
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
        
        self.container = MockContainer(view: VerificationViewMock(), makeAssemble: true)
        
        let userNotRegisteredDict: [String: AnyObject?] = ["phone_registered": false as AnyObject, "provider": nil, "subscriber": false as Optional<AnyObject>]
        let userNotRegisteredJsonData = try! JSONSerialization.data(withJSONObject: userNotRegisteredDict, options: .prettyPrinted)
        self.userNotRegisteredJson = String(data: userNotRegisteredJsonData, encoding: .utf8)
        
        
        let userWithProviderDict: [String: AnyObject?] = ["phone_registered": true as AnyObject, "provider": self.providerName as AnyObject, "subscriber": false as Optional<AnyObject>]
        let userWithProviderJsonData = try! JSONSerialization.data(withJSONObject: userWithProviderDict, options: .prettyPrinted)
        self.userWithProviderJson = String(data: userWithProviderJsonData, encoding: .utf8)
        
        
        let userWithNoProviderDict: [String: AnyObject?] = ["phone_registered": true as AnyObject, "provider": nil, "subscriber": true as Optional<AnyObject>]
        let userWithNoProviderJsonData = try! JSONSerialization.data(withJSONObject: userWithNoProviderDict, options: .prettyPrinted)
        self.userWithNoProviderJson = String(data: userWithNoProviderJsonData, encoding: .utf8)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        LSNocilla.sharedInstance().stop()
        LSNocilla.sharedInstance().clearStubs()
        UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.ChosenProvider)
        UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
    }
    
    func prepareStubs(registrationStatusMock: String) {
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/registration_status" as NSString).andReturn(200)?.withBody(registrationStatusMock as NSString)
        let _ = stubRequest("POST", "\(Router.BaseURL)/auth_phone_codes" as NSString).andReturn(404)
        
        self.container.presenter.model?.checkUserStatus(phone: "")
        
        let checkUserStateExpectation = expectation(description: "User state loading")
        
        FSDispatch_after_short(1, block: {
            checkUserStateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.2, handler: nil)
    }
    
    func testNotRegisteredUserRegistrationCase() {
        
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userNotRegisteredJson)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.loadingStarted, VerificationResult.errorOccured(error: nil)], self.container.presenter.callsOrder)
    }
    
    func testNotRegisteredUserAlreadyRegisteredCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userNotRegisteredJson)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.userNotRegistered], self.container.presenter.callsOrder)
    }
    
    func testNotRegisteredUserHasProviderCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userNotRegisteredJson)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.userHasNoProvider], self.container.presenter.callsOrder)
    }
    
    func testUserWithNoProviderRegistrationCase() {
        
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithNoProviderJson)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.userAlreadyRegisteredWithoutProvider], self.container.presenter.callsOrder)
    }
    
    func testUserWithNoProviderAlreadyRegisteredCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithNoProviderJson)
        
        XCTAssertEqual([.loadingStarted, .loadingStarted, .errorOccured(error: nil)], self.container.presenter.callsOrder)
    }
    
    func testUserWithNoProviderHasProviderCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithNoProviderJson)
        
        XCTAssertEqual([.loadingStarted, .userHasNoProvider], self.container.presenter.callsOrder)
    }
    
    func testUserWithProviderRegistrationCase() {
        
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithProviderJson)
        
        XCTAssertEqual([.loadingStarted, .userAlreadyRegisteredWithProvider], self.container.presenter.callsOrder)
    }
    
    func testUserWithProviderAlreadyRegisteredCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithProviderJson)
        
        XCTAssertEqual([.loadingStarted, .loadingStarted, .errorOccured(error: nil)], self.container.presenter.callsOrder)
    }
    
    func testUserWithProviderHasRightProviderCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.set(self.providerName, forKey: FSUserDefaultsKey.ChosenProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithProviderJson)
        
        XCTAssertEqual([.loadingStarted, .loadingStarted, .errorOccured(error: nil)], self.container.presenter.callsOrder)
    }
    
    func testUserWithProviderHasWrongProviderCase() {
        
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.RegistrationValue)
        UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.ShouldCheckProvider)
        UserDefaults.standard.set(self.providerName + "qqq", forKey: FSUserDefaultsKey.ChosenProvider)
        UserDefaults.standard.synchronize()
        
        self.prepareStubs(registrationStatusMock: self.userWithProviderJson)
        
        XCTAssertEqual([.loadingStarted, .wrongProviderSelected], self.container.presenter.callsOrder)
    }
    
    func testReceivingPhoneCodeWithValidPhone() {
        let authPhoneAnswer: [String: AnyObject?] = ["id": 1 as AnyObject, "phone_registered": true as AnyObject]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["auth_phone_code": authPhoneAnswer], options: JSONSerialization.WritingOptions.prettyPrinted) else {
            XCTAssertTrue(false)
            return
        }
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            XCTAssertTrue(false)
            return
        }
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/auth_phone_codes" as NSString).andReturn(200)?.withBody(json as NSString)
        
        self.container.model.receivePhoneCode("")
        
        let receiveCodeExpectation = expectation(description: "User code loading")
        
        FSDispatch_after_short(1, block: {
            receiveCodeExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.2, handler: nil)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.phoneCodeReceived], self.container.presenter.callsOrder)
        
        guard let authCode = BDRealm?.objects(AuthInfo.self).first,
            BDRealm?.objects(AuthInfo.self).count == 1 else {
                XCTAssertTrue(false)
                return
        }
        
        XCTAssertEqual(authCode.id, 1)
        XCTAssertEqual(authCode.isRegistered, true)
        
        XCTAssertEqual(BDRealm?.objects(ENUser.self).count, 0)
    }
    
    func testReceivingPhoneCodeWithInvalidPhone() {
        
        let validationErrorAnswer: [String: AnyObject?] = ["validations": ["phone_number": "isInvalid"] as AnyObject, "status": 422 as AnyObject]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["error": validationErrorAnswer], options: JSONSerialization.WritingOptions.prettyPrinted) else {
            XCTAssertTrue(false)
            return
        }
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            XCTAssertTrue(false)
            return
        }
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/auth_phone_codes" as NSString).andReturn(422)?.withBody(json as NSString)
        
        self.container.presenter.shouldContainParticularError = true
        
        self.container.model.receivePhoneCode("")
        
        let receiveCodeExpectation = expectation(description: "User code loading")
        
        FSDispatch_after_short(1, block: {
            receiveCodeExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.2, handler: nil)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.errorOccured(error: RTError(backend: .invalidPhone))], self.container.presenter.callsOrder)
    }
}
