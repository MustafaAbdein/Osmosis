//
//  ContentTableViewController.swift
//  Osmosis
//
//  Created by Christian Praiß on 12/25/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import Osmosis
import Async

class ContentTableViewController: UITableViewController {
    
    var array: [[String: AnyObject]] = [[String: AnyObject]]() {
        didSet {
            Async.main {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Async.background {
            Osmosis(errorHandler: { (error) -> Void in
                print(error)
            })
                .get(URL(string: "http://www.onlinecontest.org/olc-2.0/gliding/daily.html?st=olc&rt=olc&df=2015-12-22&sp=2016&c=C0&sc=#p:0;")!)
                .find(OsmosisSelector(selector: "#dailyScore tr.valid"), type: .css)
                .populate([
                    OsmosisPopulateKey.single("points") : OsmosisSelector(selector: "td:nth-child(2)"),
                    OsmosisPopulateKey.single("name") : OsmosisSelector(selector: "td:nth-child(3) a")
                    ], type: .css)
                .follow(OsmosisSelector(selector: "td:nth-child(13) a"))
                .populate([
                    OsmosisPopulateKey.single("aircraft"): OsmosisSelector(selector: "#tt_aircraft b")
                    ], type: .css)
                .list { (dict) -> Void in
                    self.array.append(dict)
                }
                .start()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
        let content = array[indexPath.row]
        var text = ""
        for (key, value) in content {
            text += "\(key): \(value)\n"
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
