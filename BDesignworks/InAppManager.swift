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
    case Trial  = "com.bdesignworks.pearup.trial"
    case Montly = "com.bdesignworks.pearup.monthly"
    case Yearly = "com.bdesignworks.pearup.yearly"
}

enum InAppErrors: Swift.Error {
    case noSubscriptionPurchased
    case noProductsAvailable
}

protocol InAppManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    
}

class InAppManager: NSObject {
    static let shared = InAppManager()
    
    weak var delegate: InAppManagerDelegate?
    
    var products: [SKProduct] = []
    
    var isSubscriptionAvailable: Bool {
        //TODO: check for receipt fields
        
        //if we unsubscribed do we still get valid receipts? - No, receipt updates automatically only if user subscribed; look at expiration date
        //subscribed -> unsubscribed -> sunscribed - will i get receipt?
        
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl),
            let receiptJson = try? JSONSerialization.jsonObject(with: receiptData, options: []) as? [String: AnyObject],
            let latestInfo = receiptJson?["receiptJson"] as? [String: AnyObject],
            let expiresDate = latestInfo["expires_date_pst"] as? Double
        else {return false}
        
        return Date().timeIntervalSince1970 < expiresDate
    }
    
    func startMonitoring() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopMonitoring() {
        SKPaymentQueue.default().remove(self)
    }
    
    func loadProducts() {
        var productIdentifiers = Set<String>()
        productIdentifiers.insert(ProductType.Montly.rawValue)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let product = self.products.filter({$0.productIdentifier == productType.rawValue}).first else {return}
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restoreSubscription() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.delegate?.inAppLoadingStarted()
    }
    
    func validateReceipt() -> Bool {
        //TODO: add receipt validation with apple server (https://sandbox.itunes.apple.com/verifyReceipt)
        //http://www.brianjcoleman.com/tutorial-receipt-validation-in-swift/ - receipt validation example
        return true
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
                //verify
                self.delegate?.inAppLoadingSucceded(productType: productType)
            case .failed:
                Logger.debug("failed: \(transaction.error)")
                self.delegate?.inAppLoadingFailed(error: transaction.error)
            case .restored:
                //called when restored from itunes
                Logger.debug("restored")
                //verify
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
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if self.isSubscriptionAvailable {
            guard let receiptUrl = Bundle.main.appStoreReceiptURL,
                let receiptData = try? Data(contentsOf: receiptUrl),
                let receiptJson = try? JSONSerialization.jsonObject(with: receiptData, options: []) as? [String: AnyObject],
                let latestInfo = receiptJson?["receiptJson"] as? [String: AnyObject],
                let productId = latestInfo["product_id"] as? String,
                let productType = ProductType(rawValue: productId)
                else {self.delegate?.inAppLoadingFailed(error: nil); return}
            self.delegate?.inAppLoadingSucceded(productType: productType)
        }
        else {
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noSubscriptionPurchased)
        }
    }
}

extension InAppManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //TODO: add some inapp delegate function
        guard response.products.count > 0 else {
            Logger.debug("fuck fuck fuck: \(response.invalidProductIdentifiers)")
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noProductsAvailable)
            return
        }
        self.products = response.products
        Logger.debug(response.products)
    }
}
