import UIKit

class Config: NSObject {
    
    
    // MARK: - The payment brands for Ready-to-use UI
    static let checkoutPaymentBrands = ["VISA", "MASTER", "PAYPAL"]
    
    // MARK: - Other constants
    static let asyncPaymentCompletedNotificationKey = "AsyncPaymentCompletedNotificationKey"
    static let urlScheme = "msdk.demo.async"
    static let mainColor: UIColor = UIColor.init(red: 10.0/255.0, green: 134.0/255.0, blue: 201.0/255.0, alpha: 1.0)
}
