//
//  ViewController.swift
//  sdk_ios_swift_sample
//
//  Created by Lyra Network on 19/09/2019.
//  Copyright © 2019 Lyra Network. All rights reserved.
//

import UIKit
import LyraPaymentSDK_INTE

class ViewController: UIViewController {

    // 1. Init server comunication class for get createPayment context
    let serverCommunication = ServerCommunication()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func executeSdkPayment(_ sender: Any) {

        // 2. Execute getProcessPaymentContext for get serverResponse (required param in SDK process method)
        serverCommunication.getPaymentContext { (getContextSuccess, serverResponse) in
            if !getContextSuccess || serverResponse == nil {
                //TODO: Handle error in getProcessPaymentContext
                self.showMessage("Error getting payment context")
                return
            }
            // After the payment context has been obtained
            do {
                // 3. Call the PaymentSDK process method
                try Lyra.process(contextViewController: self, serverResponse: serverResponse!,
                                 onSuccess: { ( _ lyraResponse: LyraResponse) -> Void in

                                    //4. Verify the payment using your server: Check the response integrity by verifying the hash on your server
                                    self.verifyPayment(lyraResponse)
                },
                                 onError: { (_ error: LyraError, _ lyraResponse: LyraResponse?) -> Void in

                                    //TODO: Handle Payment SDK error in process payment request
                                    self.showMessage("Payment fail: \(error.errorMessage)")

                })
            } catch {
                //TODO: Handle Payment SDK exceptions
            }
        }
    }

    func showMessage(_ message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    /// Check the response integrity by verifying the hash on your server
    /// - Parameter LyraResponse: Response of process payment
    func verifyPayment(_ lyraResponse: LyraResponse) {
        serverCommunication.verifyPayment(lyraResponse, onVerifyPaymentCompletion: { (paymentVerified, isConnectionError) in

            if paymentVerified {
                self.showMessage("Payment success")
            } else {
                self.showMessage("Payment verification fail")
            }
        })
    }
    
}
