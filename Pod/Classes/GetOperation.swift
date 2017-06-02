//
//  GetOperation.swift
//  Pods
//
//  Created by Christian Praiß on 12/25/15.
//
//

import Foundation
import Kanna

internal class GetOperation: OsmosisOperation {
    
    let url: URL
    var next: OsmosisOperation?
    var errorHandler: OsmosisErrorCallback?
    
    init(url: URL, errorHandler: OsmosisErrorCallback? = nil){
        self.url = url
        self.errorHandler = errorHandler
    }
    
    func execute(_ doc: HTMLDocument?, currentURL: URL?, node: XMLElement?, dict: [String: AnyObject]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard let error = error else {
                if let data = data, let string = String(data: data, encoding: String.Encoding.utf8), let newdoc = HTML(html: string, encoding: String.Encoding.utf8) {
                    self.next?.execute(newdoc, currentURL: self.url, node: newdoc.body, dict: dict)
                }else{
                    self.errorHandler?(NSError(domain: "HTML parse error", code: 500, userInfo: nil))
                }
                return
            }
            self.errorHandler?(error as NSError)
        }) 
        
        task.resume()
    }
}

internal class LoadOperation: OsmosisOperation {
    
    let data: Data
    var next: OsmosisOperation?
    var errorHandler: OsmosisErrorCallback?
    let encoding: String.Encoding
    
    init(data: Data, encoding: String.Encoding, errorHandler: OsmosisErrorCallback? = nil){
        self.data = data
        self.encoding = encoding
        self.errorHandler = errorHandler
    }
    
    func execute(_ doc: HTMLDocument?, currentURL: URL?, node: XMLElement?, dict: [String: AnyObject]) {
        if let html = HTML(html: data, encoding: String.Encoding.utf8) {
            self.next?.execute(html, currentURL: nil, node: html.body, dict: dict)
        }else{
            self.errorHandler?(NSError(domain: "HTML parse error", code: 500, userInfo: nil))
        }
    }
}
