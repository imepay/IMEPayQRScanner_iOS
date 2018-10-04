//
//  QRModel.swift
//  IMEPayQRScanner
//
//  Created by Manoj Karki on 10/3/18.
//  Copyright © 2018 Manoj Karki. All rights reserved.
//

import Foundation

// QR Data model

struct IMPQRInfo {

    // Transaction Modes

    enum QRTransactionMode: String {
        case sendMoney = "RECEIVE"
        case payMerchat = ""
        case agent = "WITHDRAW"
    }

    var qrTransactionMode: QRTransactionMode? {
        let tranKeyword = decodedString.components(separatedBy: ",")[0].uppercased()
        if tranKeyword != QRTransactionMode.sendMoney.rawValue && tranKeyword != QRTransactionMode.agent.rawValue {
            return QRTransactionMode.payMerchat
        }
        return QRTransactionMode(rawValue: tranKeyword)
    }
    
    var decodedString: String!
    
    // Initialization

    init(withDecodedString string: String) {
        self.decodedString = string
    }

    // Merchant Name

    var name: String? {
        guard let transactionMode = self.qrTransactionMode else {
            return nil
        }
        var fullname: String?

        switch transactionMode {
        case .payMerchat:
            fullname = decodedString.components(separatedBy: ",").first
        default: return nil
        }
        return fullname?.replacingOccurrences(of: "_", with: " ")
    }
    
    // Mobile Number Or Merchant Code in case of Merchant Pay
    
    var mobileNumberOrCode: String? {
        guard let transactionMode = self.qrTransactionMode else {
            return nil
        }

        var number: String?
        switch transactionMode {
        case .payMerchat:
            let firstComponent =  decodedString.components(separatedBy: ",")[1]
            if let i = firstComponent.unicodeScalars.index(where: { $0.value < 48 || ($0.value > 57 && $0.value < 65 ) || ( $0.value > 90 && $0.value < 97) || $0.value > 122 }) {
                let asciiPrefix = String(firstComponent.unicodeScalars[..<i])
                number = asciiPrefix
            }
            break
        default: return nil
        }
        return number
    }

}
