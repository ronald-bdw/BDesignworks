//
//  VerificationMocks.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 14/11/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
@testable import PearUp

enum VerificationResult: Equatable {
    case phoneNotValid
    case phoneValid
    case codeNotValid
    case codeValid
    case phoneCodeReceived
    case errorOccured(error: RTError?)
    case loadingStarted
    case userHasNoProvider
    case userNotRegistered
    
    var description: String {
        switch self {
        case .phoneNotValid: return "phoneNotValid"
        case .phoneValid: return "phoneValid"
        case .codeNotValid: return "codeNotValid"
        case .codeValid: return "codeValid"
        case .phoneCodeReceived: return "phoneCodeReceived"
        case .errorOccured(let error): return error?.description ?? "errorOccured"
        case .loadingStarted: return "loadingStarted"
        case .userHasNoProvider: return "userHasNoProvider"
        case .userNotRegistered: return "userNotRegistered"
        }
    }
}

func == (lht: VerificationResult, rht: VerificationResult) -> Bool {
    return lht.description == rht.description
}

extension RTError {
    var description: String {
        switch self {
        case .request:
            return "requestError"
        case .serialize(let error):
            return error.description
        case .unknown(let error):
            return error.debugDescription
        case .backend(let error):
            return error.description
        }
    }
}

class VerificationPresenterMock: MVPPresenter {
    typealias ViewProtocol = IVerificationView
    typealias ModelProtocol = IVerificationModel
    
    var view    : ViewProtocol?
    var model   : ModelProtocol?
    
    required init () {}
    
    var checkForProviderTest: Bool = false
    var checkForRegistrationTest: Bool = false
    var shouldContainParticularError: Bool = false
    
    var callsOrder: [VerificationResult] = []
}

extension VerificationPresenterMock: IVerificationModelPresenter {
    func phoneNotValid() {
        self.callsOrder.append(VerificationResult.phoneNotValid)
    }
    
    func codeNotValid() {
        self.callsOrder.append(VerificationResult.codeNotValid)
    }
    
    func phoneValid() {
        self.callsOrder.append(VerificationResult.phoneValid)
    }
    
    func codeValid() {
        self.callsOrder.append(VerificationResult.codeValid)
    }
    
    func phoneCodeReceived() {
        self.callsOrder.append(VerificationResult.phoneCodeReceived)
    }
    
    func errorOccured(error: RTError?) {
        if shouldContainParticularError {
            self.callsOrder.append(VerificationResult.errorOccured(error: error))
        }
        else {
            self.callsOrder.append(VerificationResult.errorOccured(error: nil))
        }
    }
    
    func loadingStarted() {
        self.callsOrder.append(VerificationResult.loadingStarted)
    }
    
    var shouldCheckProvider: Bool  {
        return self.checkForProviderTest
    }
    
    var shouldCheckRegistration: Bool  {
        return self.checkForRegistrationTest
    }
    
    func userHasNoProvider() {
        self.callsOrder.append(VerificationResult.userHasNoProvider)
    }
    
    func userNotRegistered() {
        self.callsOrder.append(VerificationResult.userNotRegistered)
    }
}

extension VerificationPresenterMock: IVerificationViewPresenter {
    func submitTapped(_ code: String?, phone: String?) {
        
    }
}

class VerificationViewMock: MVPView {
    typealias PresenterProtocol = IVerificationViewPresenter
    var presenter: PresenterProtocol?
    
}

extension VerificationViewMock: IVerificationView {
    
    func showPhoneInvalidView() {
        
    }
    
    func dismissPhoneInvalidView() {
        
    }
    
    func showCodeInvalidView() {
        
    }
    
    func dismissCodeInvalidView() {
        
    }
    
    func setLoadingState(_ state: LoadingState) {
        
    }
    
    func showErrorView(_ title: String, content: String, errorType: BackendError) {
        
    }
    
    var shouldCheckProvider: Bool {
        return true
    }
    
    var shouldCheckRegistration: Bool {
        return true
    }
    
    func showNoProviderAlert() {
        
    }
    
    func showNotRegisteredAlert() {
        
    }
}