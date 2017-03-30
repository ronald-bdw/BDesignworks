//
//  InAppManager.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 12/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import StoreKit

enum ProductType: String {
    case starter = "com.bdesignworks.habitStarter"
    case stabilizer = "com.bdesignworks.habitStabliser"
    case master = "com.bdesignworks.habitMaster"
    
    static var all: [ProductType] {
        return [.starter, .stabilizer, .master]
    }
    
    var serverDescription: String {
        switch self {
        case .starter       : return "habit_starter"
        case .stabilizer    : return "habit_stabliser"
        case .master        : return "habit_master"
        }
    }
    
    var name: String {
        switch self {
        case .starter       : return "Habit Starter"
        case .stabilizer    : return "Habit Stabilizer"
        case .master        : return "Habit Master"
        }
    }
    
    var description: String {
        switch self {
        case .starter       : return "Habit Starter (2 months) - $99.99."
        case .stabilizer    : return "Habit Stabilizer (6 months) - $179.99."
        case .master        : return "Habit Master (12 months) - $299.99."
        }
    }
}

enum InAppErrors: Swift.Error {
    case noSubscriptionPurchased
    case noProductsAvailable
    
    var localizedDescription: String {
        switch self {
        case .noSubscriptionPurchased:
            return "No subscription purchased"
        case .noProductsAvailable:
            return "No products available"
        }
    }
}

protocol InAppManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    func subscriptionStatusUpdated(value: Bool)
}

class InAppManager: NSObject {
    static let shared = InAppManager()
    
    weak var delegate: InAppManagerDelegate?
    
    var products: [SKProduct] = []
    
    var isTrialPurchased: Bool?
    var expirationDate: Date?
    var purchasedProduct: ProductType?
    
    var isSubscriptionAvailable: Bool =
        UserDefaults.standard.object(forKey: FSUserDefaultsKey.subscriptionAvailability) != nil ?
            UserDefaults.standard.bool(forKey: FSUserDefaultsKey.subscriptionAvailability) : true
    {
        didSet(value) {
            self.delegate?.subscriptionStatusUpdated(value: value)
            self.sendStatus()
        }
    }
    
    func startMonitoring() {
        SKPaymentQueue.default().add(self)
        self.updateSubscriptionStatus()
    }
    
    func stopMonitoring() {
        SKPaymentQueue.default().remove(self)
    }
    
    func loadProducts() {
        var productIdentifiers = Set<String>()
        productIdentifiers.insert(ProductType.starter.rawValue)
        productIdentifiers.insert(ProductType.stabilizer.rawValue)
        productIdentifiers.insert(ProductType.master.rawValue)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let product = self.products.filter({$0.productIdentifier == productType.rawValue}).first else {
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noProductsAvailable)
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restoreSubscription() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.delegate?.inAppLoadingStarted()
    }
    
    func checkSubscriptionAvailability(_ completionHandler: @escaping (Bool) -> Void) {
        
        //if we unsubscribed do we still get valid receipts? - No, receipt updates automatically only if user subscribed; look at expiration date
        //subscribed -> unsubscribed -> sunscribed - will i get receipt?
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString() as AnyObject else {
                completionHandler(false)
                return
        }
        
        let _ = Router.User.sendReceipt(receipt: receipt).request(baseUrl: "https://buy.itunes.apple.com").responseObject { (response: DataResponse<RTSubscriptionResponse>) in
            switch response.result {
            case .success(let value):
                guard let expirationDate = value.expirationDate,
                    let productId = value.productId else {completionHandler(false); return}
                self.expirationDate = expirationDate
                self.isTrialPurchased = value.isTrial
                self.purchasedProduct = ProductType(rawValue: productId)
                completionHandler(Date().timeIntervalSince1970 < expirationDate.timeIntervalSince1970)
            case .failure(let error):
                completionHandler(self.isSubscriptionAvailable)
                Logger.error(error)
            }
        }
    }
    
    func updateSubscriptionStatus() {
        self.checkSubscriptionAvailability({ [weak self] (isSubscribed) in
            UserDefaults.standard.set(isSubscribed, forKey: FSUserDefaultsKey.subscriptionAvailability)
            UserDefaults.standard.synchronize()
            self?.isSubscriptionAvailable = isSubscribed
        })
    }
    
    func sendStatus() {
        guard let lIsTrialPurchased = self.isTrialPurchased,
            let lExpiration = self.expirationDate,
            let lPurchasedProduct = self.purchasedProduct else {return}
        let plan = lIsTrialPurchased ?
            lPurchasedProduct.serverDescription + "_trial" :
            lPurchasedProduct.serverDescription
        let _ = Router.User.sendInAppPurchaseStatus(plan: plan, expirationDate: lExpiration, isActive: self.isSubscriptionAvailable).request().responseObject { (response: DataResponse<RTEmptyResponse>) in
            switch response.result {
            case .success:
                Logger.debug("Success sent inapp status")
            case .failure(let error):
                Logger.error(error)
            }
        }
    }
}

extension InAppManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard let productType = ProductType(rawValue: transaction.payment.productIdentifier) else {fatalError()}
            switch transaction.transactionState {
            case .purchasing:
                Logger.debug("purchasing")
                self.delegate?.inAppLoadingStarted()
            case .purchased:
                Logger.debug("purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
            case .failed:
                Logger.debug("Failed with \(transaction.error)")
                if let transactionError = transaction.error as? NSError,
                    transactionError.code != SKError.paymentCancelled.rawValue {
                    self.delegate?.inAppLoadingFailed(error: transaction.error)
                } else {
                    self.delegate?.inAppLoadingFailed(error: InAppErrors.noSubscriptionPurchased)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
            case .deferred:
                Logger.debug("deffered")
                self.delegate?.inAppLoadingSucceded(productType: productType)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Swift.Error) {
        self.delegate?.inAppLoadingFailed(error: error)
    }
    
}

//MARK: - SKProducatsRequestDelegate
extension InAppManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //TODO: add some inapp delegate function
        guard response.products.count > 0 else {return}
        self.products = response.products
        Logger.debug(response.products.map({$0.description}))
    }
}
