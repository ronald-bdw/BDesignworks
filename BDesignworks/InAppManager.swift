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
    func purchaseSucceded(productType: ProductType)
    func purchaseFailed()
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
        let productIdentifiers = Set<String>()
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let product = self.products.filter({$0.productIdentifier == productType.rawValue}).first else {return}
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func validateReceipt() -> Bool {
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
            case .purchased:
                self.delegate?.purchaseSucceded(productType: productType)
            case .failed:
                self.delegate?.purchaseFailed()
            case .restored:
                Logger.debug("restored")
            case .deferred:
                Logger.debug("deffered")
            }
        }
    }
}

extension InAppManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //TODO: add some inapp delegate function
        guard response.products.count > 0 else {Logger.debug(response); return}
        self.products = response.products
        Logger.debug(response.products)
    }
}
