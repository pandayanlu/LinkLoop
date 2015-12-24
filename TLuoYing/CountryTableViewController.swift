//
//  CountryTableViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/20/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

class CountryTableViewController: UITableViewController {

    var countryList: [String]?
    var countryDataDelegate: MyDataDelegate?
    @IBOutlet var countryTabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path : String? = NSBundle.mainBundle().pathForResource("country-list-iso-codes", ofType: "txt")
        countryList = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding).componentsSeparatedByString("\n") as [String]
        
//        dispatch_async(dispatch_get_main_queue()){
//            self.countryTabelView.reloadData()
//            self.displayAlertMessage(self.countryList![0])
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: CountryTableViewCell = tableView.dequeueReusableCellWithIdentifier("CountryTableViewCell") as! CountryTableViewCell
        
        let country = countryList![indexPath.row]
        let countryArray = country.componentsSeparatedByString(":") as [String]
        cell.setCell(countryArray[1])

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let country = countryList![indexPath.row]
        self.countryDataDelegate?.didSelectRow(indexPath, data: country)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
