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
@testable import PearUp

class VerificationModelTest: XCTestCase {
    
    private typealias MockContainer = MVPContainer<VerificationViewMock, VerificationPresenterMock, VerificationModel>
    
    private var container: MockContainer!
    
    //    var presenter: VerificationPresenterMock?
    
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
        
        self.container = MockContainer(view: VerificationViewMock(), makeAssemble: true)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        LSNocilla.sharedInstance().stop()
        LSNocilla.sharedInstance().clearStubs()
        //        self.presenter = nil
    }
    
    func testUserWithNoProvider() {
        let registrationStatus: [String: AnyObject?] = ["phone_registered": true as AnyObject, "provider": nil]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: registrationStatus, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            XCTAssertTrue(false)
            return
        }
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            XCTAssertTrue(false)
            return
        }
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/registration_status" as NSString).andReturn(200)?.withBody(json as NSString)
        
        self.container.presenter.checkForProviderTest = true
        
        self.container.presenter.model?.checkUserStatus(phone: "")
        
        let checkUserStateExpectation = expectation(description: "User state loading")
        
        FSDispatch_after_short(1, block: {
            checkUserStateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.2, handler: nil)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.userHasNoProvider], self.container.presenter.callsOrder)
    }
    
    func testUnregisteredUser() {
        let registrationStatus: [String: AnyObject?] = ["phone_registered": false as AnyObject, "provider": nil]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: registrationStatus, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            XCTAssertTrue(false)
            return
        }
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            XCTAssertTrue(false)
            return
        }
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/registration_status" as NSString).andReturn(200)?.withBody(json as NSString)
        
        self.container.presenter.checkForRegistrationTest = true
        
        self.container.presenter.model?.checkUserStatus(phone: "")
        
        let checkUserStateExpectation = expectation(description: "User state loading")
        
        FSDispatch_after_short(1, block: {
            checkUserStateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.2, handler: nil)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.userNotRegistered], self.container.presenter.callsOrder)
    }
    
    func testRegisteredUser() {
        let registrationStatus: [String: AnyObject?] = ["phone_registered": true as AnyObject, "provider": nil]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: registrationStatus, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            XCTAssertTrue(false)
            return
        }
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            XCTAssertTrue(false)
            return
        }
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/registration_status" as NSString).andReturn(200)?.withBody(json as NSString)
        let _ = stubRequest("POST", "\(Router.BaseURL)/auth_phone_codes" as NSString).andReturn(404)
        
        self.container.presenter.checkForRegistrationTest = true
        
        self.container.presenter.model?.checkUserStatus(phone: "")
        
        let checkUserStateExpectation = expectation(description: "User state loading")
        
        FSDispatch_after_short(1.5, block: {
            checkUserStateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.6, handler: nil)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.loadingStarted, VerificationResult.errorOccured(error: nil)], self.container.presenter.callsOrder)
    }
    
    func testUserWithProvider() {
        let registrationStatus: [String: AnyObject?] = ["phone_registered": true as AnyObject, "provider": "hbf" as AnyObject]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: registrationStatus, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            XCTAssertTrue(false)
            return
        }
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {
            XCTAssertTrue(false)
            return
        }
        
        let _ = stubRequest("POST", "\(Router.BaseURL)/registration_status" as NSString).andReturn(200)?.withBody(json as NSString)
        let _ = stubRequest("POST", "\(Router.BaseURL)/auth_phone_codes" as NSString).andReturn(404)
        
        self.container.presenter.checkForProviderTest = true
        
        self.container.presenter.model?.checkUserStatus(phone: "")
        
        let checkUserStateExpectation = expectation(description: "User state loading")
        
        FSDispatch_after_short(1.5, block: {
            checkUserStateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 1.6, handler: nil)
        
        XCTAssertEqual([VerificationResult.loadingStarted, VerificationResult.loadingStarted, VerificationResult.errorOccured(error: nil)], self.container.presenter.callsOrder)
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