//
//  CryptoManager.swift
//  IMEPayQRScanner
//
//  Created by Manoj Karki on 10/4/18.
//  Copyright © 2018 Manoj Karki. All rights reserved.
//

import CryptoSwift

final class CryptoManager {

    private struct Constants {
        static let imePayIv: String = "190db824fe56c37a"
        static let imePaySecretKey: String = "081a49b37c56e2fd"
    }

    class func decrypt(qrString: String) -> String {
        do {
            let decrypted =   try AES(key: Constants.imePaySecretKey, iv: Constants.imePayIv, blockMode: .CBC, padding: .noPadding).decrypt(Array<UInt8>(hex: qrString))
            return String(data: Data(decrypted), encoding: String.Encoding.utf8) ?? ""
        } catch _ {
            print("Failed to decrypt the QR Data")
        }
        return ""
    }
}
