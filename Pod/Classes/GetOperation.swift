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
    
    let url: NSURL
    var next: OsmosisOperation?
    var errorHandler: OsmosisErrorCallback?
    
    init(url: NSURL, errorHandler: OsmosisErrorCallback? = nil){
        self.url = url
        self.errorHandler = errorHandler
    }
    
    func execute(doc: HTMLDocument?, node: XMLElement?, dict: [String: AnyObject]) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            guard let error = error else {
                if let data = data, let string = String(data: data, encoding: NSUTF8StringEncoding), let newdoc = HTML(html: string, encoding: NSUTF8StringEncoding) {
                    self.next?.execute(newdoc, node: newdoc.body, dict: dict)
                }else{
                    self.errorHandler?(error: NSError(domain: "HTML parse error", code: 500, userInfo: nil))
                }
                return
            }
            self.errorHandler?(error: error)
        }
        
        task.resume()
    }
}