//
//  PostalCode.swift
//  Postal
//

import UIKit

class PostalCode: NSObject {

    var codeString = ""
    
    func setCode(inputString input: String) {
        
        // 空白と改行の削除
        let trimedString = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 数字以外のものがあればエラー。ハイフンもエラーにする
        if trimedString.isOnlyNumeric() {
            codeString = trimedString
        } else {
            codeString = ""
        }
    }
}

extension String {
    
    public func isOnly(_ characterset: CharacterSet) -> Bool {
        return self.trimmingCharacters(in: characterset).count <= 0
    }
    public func isOnlyNumeric() -> Bool {
        return isOnly(.decimalDigits)
    }
}
