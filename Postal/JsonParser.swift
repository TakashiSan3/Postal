//
//  JsonParser.swift
//  Postal
//


import UIKit

class JsonParser: NSObject {

    func parse(data jsonData: Data?) -> [Address]? {
        
        guard let json = jsonData else { return nil}
        
        do {
            let serialed = try JSONSerialization.jsonObject(with: json, options: .allowFragments)

            let dic = serialed as? [String:Any]
            
            let status = dic?["status"] as! Int
            
            if status == 200 {
                
                guard let results = dic?["results"] as? [[String:Any]] else { return nil }
                
                var addresses = [Address]()
                for result in results {
                    let address1 = result["address1"] as! String
                    let address2 = result["address2"] as! String
                    let address3 = result["address3"] as! String
                    
                    let address = Address(address1: address1, address2: address2, address3: address3)
                    addresses.append(address)
                }
            
                return addresses
                
            } else {
                // 200以外でメッセージがnilでなければ表示させる
                if let message = dic?["message"] as? String {
                    print(message)
                }
                return nil
            }
            
        } catch {
            print("error")
            return nil
        }
    }
}
