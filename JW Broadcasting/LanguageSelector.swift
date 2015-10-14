//
//  LanguageSelector.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/22/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class LanguageSelector: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageList!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let language=languageList![indexPath.row]
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.textColor=UIColor.whiteColor()
        let languageText=NSMutableAttributedString(string: (language.objectForKey("vernacular") as? String)!)
        
        if (language.objectForKey("isSignLanguage")?.boolValue == true){
            print("sign language!")
            languageText.appendAttributedString(NSAttributedString(string: "", attributes: NSDictionary(object: UIFont(name: "jwtv", size: 36)!, forKey: NSFontAttributeName) as? [String : AnyObject]))
            //NSFontAttributeName
        }
        
        cell.textLabel?.attributedText=languageText
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let language=languageList![indexPath.row]
        
        (self.tabBarController as! rootController).setLanguage(language.objectForKey("code") as! String, newTextDirection: ( language.objectForKey("isRTL")?.boolValue == true ? UIUserInterfaceLayoutDirection.RightToLeft : UIUserInterfaceLayoutDirection.LeftToRight ))
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
