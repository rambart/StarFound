//
//  IAP.swift
//  StarFound
//
//  Created by Tom on 2/27/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import StoreKit


class IAPService: NSObject {
    private override init() {}
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        let products: Set = ["Rambart.StarFound.unlock"]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(_ product: String) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product}).first else {return}
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
}


extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased, .restored:
                let id = transaction.payment.productIdentifier
                UserDefaults.standard.set(true, forKey: id)
                queue.finishTransaction(transaction)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchased"), object: nil)
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    
}


