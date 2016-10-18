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

protocol InAppManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    
}

class InAppManager: NSObject {
    static let shared = InAppManager()
    
    weak var delegate: InAppManagerDelegate?
    
    var products: [SKProduct] = []
    
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
        //find receipt, validate
        //if no receipt found address apple server in tour app, validate
        
        //if we unsubscribed do we still get valid receipts? - No, receipt updates automatically only if user subscribed; look at expiration date
        //subscribed -> unsubscribed -> sunscribed - will i get receipt?
        
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.delegate?.inAppLoadingStarted()
    }
    
    func validateReceipt() -> Bool {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {return false}
        guard let receipt = try? Data(contentsOf: receiptUrl) else {return false}
        Logger.debug(String(data: receipt, encoding: .utf8))
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
        //TODO: add receipt reading for last date
    }
}

extension InAppManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //TODO: add some inapp delegate function
        guard response.products.count > 0 else {Logger.debug("fuck fuck fuck: \(response.invalidProductIdentifiers)"); return}
        self.products = response.products
        Logger.debug(response.products)
    }
}
