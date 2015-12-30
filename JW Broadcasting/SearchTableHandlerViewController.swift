//
//  SearchTableHandlerViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/27/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class SearchTableHandlerViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    
    let resultsTableView=UITableView(frame: CGRect(x: (UIScreen.mainScreen().bounds.size.width-920)/2, y: 0, width: 920, height: 900))
    var searchIndex:[String]=[]
    var searchItems:[NSDictionary]=[]
    var results:[String]=[]
    
    let backgroundImageView=UIImageView(frame: UIScreen.mainScreen().bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.addSubview(resultsTableView)
        resultsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "item")
        resultsTableView.delegate=self
        resultsTableView.dataSource=self
        resultsTableView.reloadData()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
            0)) {
            self.prepareIndex()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        self.view.superview!.superview!.insertSubview(backgroundImageView, atIndex: 1)
        //backgroundImageView.layer.zPosition = -1000
        self.view.backgroundColor=UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        let backgroundEffect=UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        backgroundEffect.frame=(UIScreen.mainScreen().bounds)
        self.view.superview?.superview!.insertSubview(backgroundEffect, atIndex: 1)
        //backgroundEffect.layer.zPosition = -1
        
        self.view.removeFromSuperview()
        backgroundEffect.superview!.addSubview(self.view)*/
    }
    
    func prepareIndex(){
        
        print("[Search] Beginning index...")
        
        var itemsIndex:[String]=[]
        var items:[NSDictionary]=[]
        var i=0
        
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        let subcats=unfold("\(categoryDataURL)|category|subcategories") as? NSArray
        if (subcats == nil){
            fetchDataUsingCache("\(categoryDataURL)", downloaded: { self.prepareIndex() })
            return
        }
        for subcat in subcats! {
            let subcatKey=unfold(subcat, instructions: ["key"]) as! String
            let categoryDataURL=categoriesDirectory+"/"+subcatKey+"?detailed=1"
            let subcats=unfold("\(categoryDataURL)|category|subcategories") as? NSArray
            if (subcats == nil){
                fetchDataUsingCache("\(categoryDataURL)", downloaded: { self.prepareIndex() })
                return
            }
            else {
                for subcat in subcats! {
                    for item in ((subcat as! NSDictionary).objectForKey("media")) as! NSArray {
                        
                        if ((unfold(subcat, instructions: ["key"]) as! String).containsString("Featured")){
                            break
                        }
                        
                        itemsIndex.append(searchableString(item.objectForKey("title") as! String))
                        items.append(item as! NSDictionary)
                        i++
                        //items[(item.objectForKey("title") as! String).lowercaseString]=item as? NSDictionary //.append((item.objectForKey("title") as! String).lowercaseString)
                    }
                    searchIndex=itemsIndex
                    searchItems=items
                }
            }
        }
        searchIndex=itemsIndex
        searchItems=items
        print("[Search] index finished")
        resultsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let search=searchableString(searchController.searchBar.text!)
        print(search)
        var newResults:[String]=[]
        var i=0
        for itemKey in searchIndex {
            let itemKeyAfterProcess=itemKey
            if (itemKeyAfterProcess.containsString(search) || search.containsString(itemKeyAfterProcess)){
                newResults.append(searchItems[i].objectForKey("title") as! String)
            }
            i++
        }
        results=newResults
        resultsTableView.reloadData()
    }
    
    func searchableString(var originalString:String) -> String {
        originalString=originalString.lowercaseString
        originalString=originalString.stringByReplacingOccurrencesOfString("a", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("á", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("à", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("e", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("é", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("è", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("i", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("î", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("í", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("ì", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("u", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("ü", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("ú", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("ù", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("ó", withString: "o")
        originalString=originalString.stringByReplacingOccurrencesOfString("ò", withString: "o")
        
        for chr in originalString.characters {
            while (originalString.containsString("\(chr)\(chr)")){
                originalString=originalString.stringByReplacingOccurrencesOfString("\(chr)\(chr)", withString: "\(chr)")
            }
        }
        
        return originalString
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        cell.tag=indexPath.row
        let imageURL=unfold(searchItems[searchIndex.indexOf(searchableString(results[indexPath.row]))!], instructions: ["images",["wss","cvr","lss","wsr","pss","pns",""],["lg","md","sm",""]]) as? String
        if (imageURL != nil){
            fetchDataUsingCache(imageURL!, downloaded: {
                
                dispatch_async(dispatch_get_main_queue()) {
                    let image=imageUsingCache(imageURL!)
                    cell.imageView?.image=image
                }
            })
        }
        
        cell.textLabel?.text=results[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedIndexPath != nil){
        let imageURL=unfold(searchItems[searchIndex.indexOf(searchableString(results[context.nextFocusedIndexPath!.row]))!], instructions: ["images",["wss","cvr","lss","wsr","pss","pns",""],["lg","md","sm",""]]) as? String
            if (imageURL != nil){
                fetchDataUsingCache(imageURL!, downloaded: {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                            if (context.nextFocusedView==UIScreen.mainScreen().focusedView){
                                
                                UIView.transitionWithView((self.parentViewController as! SearchController).backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                                    
                                    let image=imageUsingCache(imageURL!)
                                    (self.parentViewController as! SearchController).backgroundImageView.image=image
                                    }, completion: nil)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let player=SuperMediaPlayer()
        player.updatePlayerUsingDictionary(searchItems[ indexPath.row ])
        player.playIn(self)
        
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
