//
//  QRModel.swift
//  IMEPayQRScanner
//
//  Created by Manoj Karki on 10/3/18.
//  Copyright © 2018 Manoj Karki. All rights reserved.
//

import Foundation


struct QRData {
    
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
    
    init(withDecodedString string: String) {
        self.decodedString = string
    }
    
    var fullName: String? {
        
        guard let transactionMode = self.qrTransactionMode else {
            return nil
        }
        
        let components = decodedString.components(separatedBy: ",")
        var fullname: String?
        
        switch transactionMode {
        case .sendMoney:
            if 1 < components.count {
                fullname = decodedString.components(separatedBy: ",")[1]
            }
        case .payMerchat:
            fullname = decodedString.components(separatedBy: ",").first
        case .agent:
            if 1 < components.count {
                fullname = decodedString.components(separatedBy: ",")[1]
            }
        }
        return fullname?.replacingOccurrences(of: "_", with: " ")
    }
    
    //MobileNumber Or Merchant Code in case of Merchant Pay
    
    var mobileNumber: String? {
        
        guard let transactionMode = self.qrTransactionMode else {
            return nil
        }
        
        var number: String?
        
        let componets = decodedString.components(separatedBy: ",")
        
        switch transactionMode {
        case .sendMoney:
            
            if 2 < componets.count {
                number =  componets[2]
            }
            break
        case .payMerchat:
            let firstComponent =  decodedString.components(separatedBy: ",")[1]
            if let i = firstComponent.unicodeScalars.index(where: { $0.value < 48 || ($0.value > 57 && $0.value < 65 ) || ( $0.value > 90 && $0.value < 97) || $0.value > 122 }) {
                let asciiPrefix = String(firstComponent.unicodeScalars[..<i])
                number = asciiPrefix
            }
            break
        case .agent:
            if 2 < componets.count {
                number =  componets[2]
            }
            break
        }
        
        if transactionMode != .payMerchat {
            if let num = number {
               // return num.substring(to:num.index(num.startIndex, offsetBy: 10))
                let reqIndex = num.index(num.startIndex, offsetBy: 10)
                let finalStr = String(num[..<reqIndex])
                return finalStr
            }
        }else {
            return number
        }
        return nil
    }

    var payAmount: String? {
        guard let transactionMode = self.qrTransactionMode else {
            return nil
        }
        if transactionMode == .payMerchat {
            
            let components = decodedString.components(separatedBy: ",")
            if 2 < components.count {
                return decodedString.components(separatedBy: ",")[2]
            }
        }
        return nil
    }
    
    var refValue: String? {
        guard let transactionMode = self.qrTransactionMode else {
            return nil
        }
        
        if transactionMode == .payMerchat {
            let components = decodedString.components(separatedBy: ",")
            if 3 < components.count {
                return decodedString.components(separatedBy: ",")[3]
            }
        }
        return nil
    }
}
