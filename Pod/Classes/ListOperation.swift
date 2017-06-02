//
//  ListOperation.swift
//  Pods
//
//  Created by Christian Praiß on 12/26/15.
//
//

import Foundation
import Kanna

internal class ListOperation: OsmosisOperation {
    
    var next: OsmosisOperation?
    var callback: OsmosisListCallback
    
    init(callback: @escaping OsmosisListCallback){
        self.callback = callback
    }
    
    func execute(_ doc: HTMLDocument?, currentURL: URL?, node: XMLElement?, dict: [String : AnyObject]) {
        callback(dict)
        
        next?.execute(doc, currentURL: currentURL, node: node, dict: dict)
    }
}
