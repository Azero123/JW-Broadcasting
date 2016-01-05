//
//  SearchController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/21/15.
//  Copyright © 2015 xquared. All rights reserved.
//


/*

WIP


This is code for a keyboard view controller this will likely be torn down and added to MOD or presented ontop of MOD.

*/





import UIKit

class SearchController: UISearchController, UISearchControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var resultsTableView: UITableView!
    var searchIndex:[String]=[]
    var searchItems:[NSDictionary]=[]
    var results:[String]=[]
    
    /*override init(searchController: UISearchController) {
        super.init(searchController: searchController)
        supportInit()
    }*/
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        self.searchResultsUpdater=searchResultsController as? UISearchResultsUpdating
        supportInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        supportInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        supportInit()
    }
    
    
    /*
    let _searchController=UISearchController(searchResultsController: SearchTableHandlerViewController())
    override var searchController:UISearchController {
        get {
            return _searchController
        }
    }*/
    
    func supportInit(){
        /*
        self.tabBarItem=UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Search, tag: 0)
        mySearchController=UISearchController(searchResultsController: SearchTableHandlerViewController())
        mySearchController?.delegate=self
        mySearchController!.definesPresentationContext=true*/
        //searchController=UISearchController(searchResultsController: SearchTableHandlerViewController())
        //self.delegate=self
        //searchController.definesPresentationContext=true
        //self.view.backgroundColor=UIColor.clearColor()
        self.definesPresentationContext=false
    }
    /*
    var mySearchController:UISearchController?=nil
    
    */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    let backgroundImageView=UIImageView(frame: UIScreen.mainScreen().bounds)
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        /*
        Every time the view goes to reappear this code runs to check if the language was changed by the Language tab. If it was then everything gets refreshed.
        */
        print("may refresh language")
        
        if (previousLanguageCode != languageCode){
            print("[Search] REFRESH LANGUAGE")
            (self.searchResultsController as! SearchTableHandlerViewController).results=[]
            (self.searchResultsController as! SearchTableHandlerViewController).searchItems=[]
            (self.searchResultsController as! SearchTableHandlerViewController).searchIndex=[]
            (self.searchResultsController as! SearchTableHandlerViewController).prepareIndex()
            previousLanguageCode=languageCode
        }
    }
    
    override func viewDidAppear(animated: Bool) {

        self.view.superview?.backgroundColor=UIColor.blackColor()
        backgroundImageView.image=UIImage(named: "LaunchScreenEarth.png")
        self.view.superview?.insertSubview(backgroundImageView, atIndex:0)
        
        
        let backgroundEffect=UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        backgroundEffect.frame=(UIScreen.mainScreen().bounds)
        backgroundImageView.alpha=0.75
        backgroundEffect.alpha=0.99
        self.view.superview?.insertSubview(backgroundEffect, atIndex:0)
        self.view.superview!.superview!.insertSubview(backgroundEffect, atIndex: 0)
        
        
        print("input accessory\(self.searchBar.inputAccessoryView)")
        print("\(self.searchBar.inputAccessoryViewController)")
    }
    /*
    
    func didPresentSearchController(searchController: UISearchController) {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let player=SuperMediaPlayer()
        player.updatePlayerUsingDictionary(searchItems[ indexPath.row ])
        player.playIn(self)
        
    }
    */
}
