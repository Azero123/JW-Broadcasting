//
//  LanguageSelector.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/22/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//

import UIKit

class LanguageSelector: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped=true
        self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.view.hidden=false
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.view.hidden=true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (languageList == nil){
            print("[ERROR] Language file not downloaded!")
            return 0
        }
        
        return languageList!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let language=languageList![indexPath.row]
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        //cell.textLabel?.textColor=UIColor.whiteColor()
        let languageText=NSMutableAttributedString(string: (language.objectForKey("vernacular") as? String)!)
        if (language.objectForKey("isSignLanguage")?.boolValue == true){
            languageText.appendAttributedString(NSAttributedString(string: "", attributes: NSDictionary(object: UIFont(name: "jwtv", size: 36)!, forKey: NSFontAttributeName) as? [String : AnyObject]))
            //NSFontAttributeName
        }
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            cell.textLabel?.textAlignment=NSTextAlignment.Right
        }
        else {
            cell.textLabel?.textAlignment=NSTextAlignment.Left
            
        }
        
        
        cell.textLabel?.attributedText=languageText
        
        return cell
    }
    
    func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
        if ((context.nextFocusedView?.isKindOfClass(UITableViewCell.self)) == true){
            (context.nextFocusedView as! UITableViewCell).backgroundColor=UIColor(colorLiteralRed: 0.3, green: 0.44, blue: 0.64, alpha: 1.0)
        }
        
        if ((context.nextFocusedView?.isKindOfClass(UITableViewCell.self)) == true){
            (context.nextFocusedView as! UITableViewCell).backgroundColor=UIColor.clearColor()
        }
        if (disableNavBar==true) {
            return false
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let language=languageList![indexPath.row]
        
        let alert=UIAlertController(title: (dictionaryOfPath(base+"/"+version+"/translations/"+languageCode)!["translations"]![languageCode]!!["hdgLanguage"] as? String)!+": "+(language["vernacular"] as? String)!, message: "", preferredStyle: .Alert)
        alert.view.tintColor = UIColor.greenColor()
        alert.addAction(UIAlertAction(title: "x", style: .Destructive, handler: nil))
        let action=UIAlertAction(title: "✓", style: .Default, handler: { (action:UIAlertAction) in
        
            
            disableNavBar=true
            tableView.hidden=true
            self.activityIndicator.startAnimating()
            fetchDataUsingCache(base+"/"+version+"/languages/"+languageCode+"/web", downloaded: {
                dispatch_async(dispatch_get_main_queue()) {
                    disableNavBar=false
                    tableView.hidden=false
                    self.activityIndicator.stopAnimating()
                    if ((self.tabBarController?.isKindOfClass(rootController.self)) == true){
                        
                        (self.tabBarController as! rootController).setLanguage(language.objectForKey("code") as! String, newTextDirection: ( language.objectForKey("isRTL")?.boolValue == true ? UIUserInterfaceLayoutDirection.RightToLeft : UIUserInterfaceLayoutDirection.LeftToRight ))
                        tableView.reloadData()
                        (self.tabBarController as? rootController)!.setTabBarVisible(true, animated: true)
                        
                        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
                        let VODURL=categoriesDirectory+"/VideoOnDemand?detailed=1"
                        fetchDataUsingCache(VODURL, downloaded: {
                            print("[VOD] preloaded")
                        })
                        let AudioURL=categoriesDirectory+"/Audio?detailed=1"
                        fetchDataUsingCache(AudioURL, downloaded: {
                            print("[Audio] preloaded")
                        })
                        
                        
                        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
                        
                        fetchDataUsingCache(pathForSliderData, downloaded: {
                            let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
                            fetchDataUsingCache(streamingScheduleURL, downloaded: {
                                let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
                                fetchDataUsingCache(latestVideosPath, downloaded: {
                                    if (ReturnToHome){
                                        if (textDirection == .RightToLeft){
                                            self.tabBarController!.selectedIndex=(self.tabBarController?.viewControllers?.count)!-1
                                        }
                                        else {
                                            self.tabBarController!.selectedIndex=0
                                        }
                                        tableView.reloadData()
                                    }
                                    
                                })
                            })
                        })
                        
                    }
                }
            })

        
        
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
        //lblSave : "Save"
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
