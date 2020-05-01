//
//  HttpRequest.swift
//  Postal
//

import UIKit

protocol HttpRequestDelegate: class {
    func didReceiveJsonData(jsonData data: Data?)
}

class HttpClient: NSObject, URLSessionDelegate {

    let requestString = "https://zip-cloud.appspot.com/api/search"
    
    let urlSession: URLSession?
    
    override init() {
        self.urlSession = URLSession()
    }
    
    func searchAddress(_ postalCode: String) {
        
        // 入力された文字列のチェック
        
        // HTTP request
        var components = URLComponents(string: requestString)!
        components.queryItems = [URLQueryItem(name: "zipcode", value: postalCode)]
        
        URLSession.shared.dataTask(with: components.url!, completionHandler: { (data, respons, error) in
            let json = String(data: data!, encoding: .utf8)!
            print(json)
        }).resume()
    }
    
    
}
