//
//  Osmosis.swift
//  Pods
//
//  Created by Christian Praiß on 12/25/15.
//
//

import Foundation
import Kanna

public enum HTMLSelectorType {
    case css
    case xPath
}

typealias OperationCallback = (_ doc: HTMLDocument?, _ node: XMLElement?, _ dict: [String: AnyObject]?, _ error: NSError?)->Void
public typealias OsmosisErrorCallback = (_ error: NSError)->Void
public typealias OsmosisInfoCallback = (_ info: String)->Void
public typealias OsmosisListCallback = (_ dict: [String: AnyObject])->Void

public struct OsmosisSelector {
    var selector: String
    var attribute: String?
    
    public init(selector: String, attribute: String? = nil){
        self.selector = selector
        self.attribute = attribute
    }
}

public enum OsmosisPopulateKey: Hashable, Equatable {
    case array(String)
    case single(String)
    
    public var hashValue: Int {
        switch self {
        case .array(let arg):
            return arg.hashValue
        case .single(let arg):
            return arg.hashValue
        }
    }
}

internal class FinishOperation: OsmosisOperation {
    var next: OsmosisOperation?
    
    func execute(_ doc: HTMLDocument?, currentURL: URL?, node: XMLElement?, dict: [String : AnyObject]) {
        print("done")
    }
}

public func == (lhs: OsmosisPopulateKey, rhs: OsmosisPopulateKey) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

open class Osmosis {
    
    var errorHandler: OsmosisErrorCallback?
    var infoHandler: OsmosisInfoCallback?
    
    var operations = [OsmosisOperation]()
    
    public init(errorHandler: OsmosisErrorCallback? = nil, infoHandler: OsmosisInfoCallback? = nil){
        self.errorHandler = errorHandler
        self.infoHandler = infoHandler
    }
    
    open func find(_ string: OsmosisSelector, type: HTMLSelectorType = .css)->Osmosis {
        
        let new = FindOperation(query: string, type: type, errorHandler: errorHandler)
        if var operation = operations.last {
            operation.next = new
        }else{
            print("First operation must be get or load")
            return self
        }
        operations.append(new)
        
        return self
    }
    
    open func populate(_ dict: [OsmosisPopulateKey:OsmosisSelector], type: HTMLSelectorType = .css)->Osmosis {
        
        let new = PopulateOperation(queries: dict, type: type, errorHandler: errorHandler)
        if var operation = operations.last {
            operation.next = new
        }else{
            print("First operation must be get or load")
            return self
        }
        operations.append(new)
        
        return self
    }
    
    open func follow(_ string: OsmosisSelector, type: HTMLSelectorType = .css)->Osmosis {
        
        let new = FollowOperation(query: string, type: type, errorHandler: errorHandler)
        if var operation = operations.last {
            operation.next = new
        }else{
            print("First operation must be get or load")
            return self
        }
        operations.append(new)
        
        return self
    }
    
    open func get(_ url: URL)->Osmosis {
        
        let new = GetOperation(url: url, errorHandler: errorHandler)
        if var operation = operations.last {
            operation.next = new
        }
        operations.append(new)
        
        return self
    }
    
    open func list(_ callback: @escaping OsmosisListCallback)->Osmosis{
        let new = ListOperation(callback: callback)
        if var operation = operations.last {
            operation.next = new
        }else{
            print("First operation must be get or load")
            return self
        }
        operations.append(new)
        return self
    }
    
    open func load(_ html: Data, encoding: String.Encoding)->Osmosis {
        
        let new = LoadOperation(data: html, encoding: encoding, errorHandler: errorHandler)
        if var operation = operations.last {
            operation.next = new
        }
        operations.append(new)
        
        return self
    }
    
    open func start(){
        operations.first?.execute(nil, currentURL: nil, node: nil, dict: [String: AnyObject]())
    }
}

internal protocol OsmosisOperation {
    var next: OsmosisOperation? { get set }
    func execute(_ doc: HTMLDocument?, currentURL: URL?, node: XMLElement?, dict: [String: AnyObject])
}
