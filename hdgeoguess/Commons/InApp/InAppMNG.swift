//
//  InAppMNG.swift
//

import Foundation
import SwiftyStoreKit
import ProgressHUD
import Toast_Swift

class InAppMNG {
    
    fileprivate static let sharedInstance = InAppMNG()
    
    public class func completeTransactions(completion: @escaping ([Purchase]) -> Void) -> Void {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                default:
                    break
                }
            }
            completion(purchases)
        }
    }

    public class func retrieveProductsInfo(productIds: Set<String>, interaction: Bool = true, completion: @escaping (RetrieveResults) -> (Void)) {
        if !interaction {
            ProgressHUD.show("Please wait!", interaction: false)
        }
        SwiftyStoreKit.retrieveProductsInfo(productIds) { (result) in
            ProgressHUD.dismiss()
            completion(result)
        }
    }

    public class func purchaseProduct(productID: String, completion: @escaping (PurchaseResult) -> Void) -> Void {
        ProgressHUD.show("Please wait!", interaction: false)
        SwiftyStoreKit.purchaseProduct(productID, atomically: true) { (result) in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                ProgressHUD.showSuccess("Success.")
                setPurchase(productID, true)
            case .error(let error):
                setPurchase(productID, false)
                ProgressHUD.showError((error as NSError).localizedDescription)
            }
            completion(result)
        }
    }

    public class func restorePurchases(completion: @escaping (RestoreResults) -> Void) -> Void {
        ProgressHUD.show("Please wait!", interaction: false)
        SwiftyStoreKit.restorePurchases(atomically: true) { (result) in
            if result.restoredPurchases.count > 0 {
                result.restoredPurchases.forEach { (purchase) in
                    setPurchase(purchase.productId, true)
                }
                ProgressHUD.showSuccess("Success!")
            } else {
                if result.restoreFailedPurchases.count > 0 {
                    result.restoreFailedPurchases.forEach { (product) in
                        guard let productID = product.1 else {return}
                        setPurchase(productID, false)
                    }
                    ProgressHUD.showError("Failed!!!")
                } else {
                    ProgressHUD.showError("Nothing to restore!")
                }
            }
            completion(result)
        }
    }

    public class func validatePurchase(productID: String, completion: @escaping (VerifyReceiptResult) -> Void) -> Void {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: appSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productID,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let receiptItem):
                    print("\(productID) is purchased: \(receiptItem)")
                    setPurchase(productID, true)
                case .notPurchased:
                    print("The user has never purchased \(productID)")
                    setPurchase(productID, false)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                setPurchase(productID, false)
            }
            completion(result)
        }
    }

    public class func validateSubsciption(productID: String, completion: @escaping (VerifyReceiptResult) -> Void) -> Void {
        #if DEBUG
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: appSecretKey)
        #else
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: appSecretKey)
        #endif
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productID,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productID) is valid until \(expiryDate)\n\(items)\n")
                    setPurchase(productID, true)
                case .expired(let expiryDate, let items):
                    print("\(productID) is expired since \(expiryDate)\n\(items)\n")
                    setPurchase(productID, false)
                case .notPurchased:
                    print("The user has never purchased \(productID)")
                    setPurchase(productID, false)
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                setPurchase(productID, false)
            }
            completion(result)
        }
    }
    
    public class func didPurchase(_ productID: String) -> Bool {
        return UserDefaults.standard.bool(forKey: productID)
    }
    
    private class func setPurchase(_ productID: String, _ didPurchase:Bool) -> Void {
        UserDefaults.standard.set(didPurchase, forKey: productID)
    }
}

extension InAppMNG {
    
    public static let appSecretKey = "8e9ead16c81348a2b86fbf712484e788"
    public static let appID = "id6467369468"
    
    public static let privacyURL = "https://www.freeprivacypolicy.com/live/5b75b483-f19a-4844-aa50-ec26abfa6ac3"
    public static let termOfUseURL = "https://sites.google.com/view/miulinh"

    public static let keyProversion1Month = "com.miulinh.geo.photo.hd.month"
    public static let keyProversion12Month = "com.miulinh.geo.photo.hd.year"

    static func isProVersion() -> Bool {
        return InAppMNG.didPurchase(InAppMNG.keyProversion1Month) ||
        InAppMNG.didPurchase(InAppMNG.keyProversion12Month)
    }

    static func goPremium(vc: UIViewController) {
        let inapp = RNInAppViewController()
        inapp.modalPresentationStyle = .overFullScreen
        vc.present(inapp, animated: true, completion: nil)
    }
    
}
