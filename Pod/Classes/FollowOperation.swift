//
//  PopulateOperation.swift
//  Pods
//
//  Created by Christian Praiß on 12/25/15.
//
//

import Foundation
import Kanna

internal class FollowOperation: OsmosisOperation {
    
    var query: OsmosisSelector
    var type: HTMLSelectorType
    var next: OsmosisOperation?
    var errorHandler: OsmosisErrorCallback?

    init(query: OsmosisSelector, type: HTMLSelectorType, errorHandler: OsmosisErrorCallback? = nil){
        self.query = query
        self.type = type
        self.errorHandler = errorHandler
    }
    
    func execute(_ doc: HTMLDocument?, currentURL: URL?, node: XMLElement?, dict: [String: AnyObject]) {
        switch type {
        case .css:
            let nodes = node?.css(query.selector)
            if let node = nodes?.first {
                if let href = node["href"], let url = currentURL?.absoluteURL {
                    let newURL = url.appendingPathComponent(href)
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let task = session.dataTask(with: newURL.absoluteURL) { (data, response, error) -> Void in
                        guard let error = error else {
                            if let data = data, let string = String(data: data, encoding: String.Encoding.utf8), let newdoc = HTML(html: string, encoding: String.Encoding.utf8) {
                                self.next?.execute(newdoc, currentURL: newURL, node: newdoc.body, dict: dict)
                            }else{
                                self.errorHandler?(NSError(domain: "HTML parse error", code: 500, userInfo: nil))
                            }
                            return
                        }
                        self.errorHandler?(error as NSError)
                    }
                    
                    task.resume()
                }else{
                    self.errorHandler?(NSError(domain: "No node found for follow \(self.query)", code: 500, userInfo: nil))
                }
            }
        case .xPath:
            let nodes = node?.xpath(query.selector)
            if let node = nodes?.first {
                if let href = node["href"], let url = currentURL {
                    let newURL = url.deletingLastPathComponent().appendingPathComponent(href)
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let task = session.dataTask(with: newURL) { (data, response, error) -> Void in
                        guard let error = error else {
                            if let data = data, let string = String(data: data, encoding: String.Encoding.utf8), let newdoc = HTML(html: string, encoding: String.Encoding.utf8) {
                                self.next?.execute(newdoc, currentURL: newURL, node: newdoc.body, dict: dict)
                            }else{
                                self.errorHandler?(NSError(domain: "HTML parse error", code: 500, userInfo: nil))
                            }
                            return
                        }
                        self.errorHandler?(error as NSError)
                    }
                    
                    task.resume()
                }else{
                    self.errorHandler?(NSError(domain: "No node found for follow \(self.query)", code: 500, userInfo: nil))
                }
            }
        }
    }
}
