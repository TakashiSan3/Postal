//
//  HttpClient.swift
//  Postal
//

import UIKit

protocol HttpRequestDelegate: class {
    func didReceiveJsonData(jsonData data: Data?)
    func didReceiveError(_ error: Error)
}

class HttpClient: NSObject {

    let requestString = "https://zip-cloud.appspot.com/api/search"
    weak var delegate:HttpRequestDelegate?
    
    override init() {
        super.init()
        self.delegate = nil
    }
    
    func searchAddress(_ postalCode: String) {

        // HTTP request
        var components = URLComponents(string: requestString)!
        components.queryItems = [URLQueryItem(name: "zipcode", value: postalCode)]
        
        URLSession.shared.dataTask(with: components.url!, completionHandler: { (data, respons, error) in
            
            // Error
            if let error = error   {
                self.delegate?.didReceiveError(error)
            }
            
            // 通信が成功した場合
            if let respons = respons as? HTTPURLResponse {
                if respons.statusCode == 200 {
                    self.delegate?.didReceiveJsonData(jsonData: data)
                } else {
                    // ここはどうするか、、、、
                }
            }
    
        }).resume()
    }
}
