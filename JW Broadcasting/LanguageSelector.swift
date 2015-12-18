//
//  LanguageSelector.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/22/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//

/*

We needed some way to switch languages right now all we can come up with is having a large list.
To load in this list we will just use an actual variable defined in the AppDelegate.swift file languageList.
languageList is an array of the downloaded information from jw.org.
The Array is ordered alphebetically (unicode alphebetically?) and all we need is a UITableView to display all these languages.
When selected the UITableView then brings up a prompt to confirm the switch. To make this universal we are using "x" and "✓".



*/



import UIKit

class LanguageSelector: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped=true
        self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        // Loading indicator though there should be none
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.view.hidden=false // For some bugs I noticed in switching UIViewControllers to quickly (not our code) displaying multiple UIViewControllers simultaneously
    }
    
    override func viewDidDisappear(animated: Bool) {
        (self.tabBarController as! rootController).disableNavBarTimeOut=false
        self.view.hidden=true // For some bugs I noticed in switching UIViewControllers to quickly (not our code) displaying multiple UIViewControllers simultaneously
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // Only one list of languages
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (languageList == nil){
            print("[ERROR] Language file not downloaded!")
            return 0 // There is an issue if this ever happens but let's not break the app anyway
        }
        
        return languageList!.count // How many rows do we need? the same amount as there are languages
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let language=languageList![indexPath.row] //Get language data ready to use
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) // Bring up a new cell for displaying the language
        let languageText=NSMutableAttributedString(string: (language.objectForKey("vernacular") as? String)!) // Get the language in how it appears locally, so the user can understand what is going on
        if (language.objectForKey("isSignLanguage")?.boolValue == true){ // If the language is a sign language let's show them just to be nice (:
            languageText.appendAttributedString(NSAttributedString(string: "", attributes: NSDictionary(object: UIFont(name: "jwtv", size: 36)!, forKey: NSFontAttributeName) as? [String : AnyObject])) // Append the icon inside the font to the visible string
            //NSFontAttributeName
        }
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){ //Handle right to left language alignment
            cell.textLabel?.textAlignment=NSTextAlignment.Right
        }
        else {
            cell.textLabel?.textAlignment=NSTextAlignment.Left
            
        }
        
        
        cell.textLabel?.attributedText=languageText // Now we can finally set the text so the user can see
        
        return cell
    }
    
    func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
        
        /*Do not allow the user to use the language page when changing language content*/
        
        if (disableNavBar==true) {
            return false
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /*
        
        The user has selected a new language. First we prompt the user to confirm that they intend to change languages.
        The prompt to change languages needs to be internationalized and handle different languages. HOWEVER, we do not have provided translated text from jw.org to prompt a language change. Current concept that appears to work is use "Language" in current language and the vernacular language text exp, "English" separated by a ":".

        The buttons are x and ✓
        When x is pressed nothing happens
        When ✓ is pressed the downloads are prompted for the new language.
        We predownload Featured videos, Streaming meta, Latest videos, Video on Demand and Audio because we are going to send the user to the home page and we want the app to be responsive. (The user shouldn't have to scroll all the way down the language list and back up.)
        
        We call rootController.setLanguage(...) to change the languageCode variable and change the top bar text (This includes making it RTL.)
        
        Once we finish we reload the table because we have a fresh copy of the language list.
        
        Lastly we send the user to the home page.
        
        */
        
        //Get the data on the language to go to
        let language=languageList![indexPath.row]
        
        //Bring up the prompt for the user
        let alert=UIAlertController(title: (dictionaryOfPath(base+"/"+version+"/translations/"+languageCode)!["translations"]![languageCode]!!["hdgLanguage"] as? String)!+": "+(language["vernacular"] as? String)!, message: "", preferredStyle: .Alert)
        //This was to make the "✓" button green but it didn't work
        alert.view.tintColor = UIColor.greenColor()
        //This "x" button is destructive to give it the red color and nothing needs to happen when it is pressed.
        alert.addAction(UIAlertAction(title: "x", style: .Destructive, handler: nil))
        //Create the "✓" button with the closure to execute when the user has confirmed the change.
        let action=UIAlertAction(title: "✓", style: .Default, handler: { (action:UIAlertAction) in
        
            disableNavBar=true // Prevent the user from interacting until we are finished loading the new language
            tableView.hidden=true // Prevent the language table from being seen until it is reloaded
            self.activityIndicator.startAnimating() // Give the user a spinning wheel so they know the app is working.
            
            
            fetchDataUsingCache(base+"/"+version+"/languages/"+languageCode+"/web", downloaded: {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    //Make sure we actually have a root controller (This is incase this gets changed it will not cause the app to crash.
                    
                    if ((self.tabBarController?.isKindOfClass(rootController.self)) == true){
                        
                        //Let the tab bar update itself
                        (self.tabBarController as! rootController).setLanguage(language.objectForKey("code") as! String, newTextDirection: ( language.objectForKey("isRTL")?.boolValue == true ? UIUserInterfaceLayoutDirection.RightToLeft : UIUserInterfaceLayoutDirection.LeftToRight ))
                        (self.tabBarController as? rootController)!.setTabBarVisible(true, animated: true) //Now that we have updated the tab bar let the user see it
                        
                        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
                        let VODURL=categoriesDirectory+"/VideoOnDemand?detailed=1"
                        fetchDataUsingCache(VODURL, downloaded: { //Predownload VOD
                            print("[VOD] preloaded")
                        })
                        let AudioURL=categoriesDirectory+"/Audio?detailed=1"
                        fetchDataUsingCache(AudioURL, downloaded: { //Predownload Audio
                            print("[Audio] preloaded")
                        })
                        
                        
                        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
                        
                        fetchDataUsingCache(pathForSliderData, downloaded: { //Predownload Featured videos
                            let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
                            fetchDataUsingCache(streamingScheduleURL, downloaded: { //Predownload Streaming meta
                                let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
                                fetchDataUsingCache(latestVideosPath, downloaded: { //Predownload Latest videos
                                    dispatch_async(dispatch_get_main_queue()) {
                                    disableNavBar=false // Allow the user to interact now that we finished the downloads.
                                    tableView.hidden=false
                                    self.activityIndicator.stopAnimating() // No longer processing anything so hide this
                                    if (ReturnToHome){ // Togglable feature in the control.swift file
                                        if (textDirection == .RightToLeft){ //If the app is in RTL then send it to the far right tab (home)
                                            self.tabBarController!.selectedIndex=(self.tabBarController?.viewControllers?.count)!-1
                                        }
                                        else { //If the app is in LTR then send it to the far left tab (home)
                                            self.tabBarController!.selectedIndex=0
                                        }
                                        tableView.reloadData()
                                    }
                                    }
                                })
                            })
                        })
                        
                    }
                }
            })

        
        
        })
        alert.addAction(action) // present the "✓" button
        self.presentViewController(alert, animated: true, completion: nil) // present the prompt
        //lblSave : "Save"
        
        
    }

}
