//
//  SearchTableHandlerViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/27/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class SearchTableHandlerViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    
    let resultsTableView=UITableView(frame: CGRect(x: (UIScreen.mainScreen().bounds.size.width-920-200)/2, y: 0, width: 920+200, height: 1000))
    var searchIndex:[[String]]=[]
    var searchItems:[NSDictionary]=[]
    var results:[Int]=[]
    
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
        addBranchListener("language", serverBonded: { () in
            
            self.prepareIndex()
            
        })
        // Do any additional setup after loading the view.
    }
    
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        /*
        Every time the view goes to reappear this code runs to check if the language was changed by the Language tab. If it was then everything gets refreshed.
        */
        
        if (previousLanguageCode != languageCode){
            results=[]
            searchItems=[]
            searchIndex=[]
            prepareIndex()
            previousLanguageCode=languageCode
        }
    }
    
    func prepareIndex(){
        
        print("[Search] Beginning index...")
        NSLog("time measurement begin...")
        
        var itemsIndex:[[String]]=[]
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
        
        
        let audiosubs=unfold(categoriesDirectory+"/Audio?detailed=1|category|subcategories") as? NSArray
        if (audiosubs == nil){
            fetchDataUsingCache("\(categoriesDirectory)/Audio?detailed=1", downloaded: { self.prepareIndex() })
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
                        
                        let searchableWords=searchableString(item.objectForKey("title") as! String).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
                        
                        if ((unfold(subcat, instructions: ["key"]) as! String).containsString("Featured")){
                            break
                        }
                        
                        
                        var same=true
                        
                        if (searchIndex.count==0){
                            same=false
                        }
                        
                        for searchItem in searchIndex {
                            if (searchItem.count == searchableWords.count){
                                for var i = 0 ; i<searchItem.count ; i++ {
                                    if (searchItem[i] != searchableWords[i]){
                                        same=false
                                    }
                                }
                            }
                            else {
                                same=false
                            }
                        }
                        if (same==true){
                            break
                        }
                        
                        itemsIndex.append(searchableWords)
                        //item.setObject(titleExtractor(item.objectForKey("title") as! String)["correctedTitle"], forKey: "visual-title")
                        item.setObject(item.objectForKey("title") as! String, forKey: "visual-title")
                        items.append(item as! NSDictionary)
                        i++
                        //items[(item.objectForKey("title") as! String).lowercaseString]=item as? NSDictionary //.append((item.objectForKey("title") as! String).lowercaseString)
                    }
                    searchIndex=itemsIndex
                    searchItems=items
                    //self.searchFor(currentSearch)
                }
            }
        }
        
        
        for subcat in audiosubs! {
            for item in ((subcat as! NSDictionary).objectForKey("media")) as! NSArray {
                
                let searchableWords=searchableString(item.objectForKey("title") as! String).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
                
                if ((unfold(subcat, instructions: ["key"]) as! String).containsString("Featured")){
                    break
                }
                
                var same=true
                if (searchIndex.count==0){
                    same=false
                }
                
                for searchItem in searchIndex {
                    if (searchItem.count == searchableWords.count){
                        for var i = 0 ; i<searchItem.count ; i++ {
                            if (searchItem[i] != searchableWords[i]){
                                same=false
                            }
                        }
                    }
                    else {
                        same=false
                    }
                }
                if (same==true){
                    break
                }
                
                itemsIndex.append(searchableWords)
                item.setObject(titleExtractor(item.objectForKey("title") as! String)["correctedTitle"], forKey: "visual-title")
                items.append(item as! NSDictionary)
                i++
                //items[(item.objectForKey("title") as! String).lowercaseString]=item as? NSDictionary //.append((item.objectForKey("title") as! String).lowercaseString)
            }
            searchIndex=itemsIndex
            searchItems=items
            //self.searchFor(currentSearch)
        }
        //subcats?.addObjectsFromArray(audiosubs! as [AnyObject])
    
    
        searchIndex=itemsIndex
        searchItems=items
        print("[Search] index finished")
        //resultsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var currentSearch=""
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.searchFor(searchController.searchBar.text!)
    }
    
    func searchFor(var search:String){
        currentSearch=search
        search=searchableString(search)
        let searchWords=searchableString(search).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
        print(search)
        var newResults:[Int]=[]
        var i=0
        
        for searchItem in searchIndex {
            for searchWord in searchWords {
                for searchKey in searchItem {
                    if (searchKey.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)>2 && ( searchKey.containsString(searchWord) || searchWord.containsString(searchKey))){
                        
                        let dict=searchItems[i]
                        let visualTitle=dict.objectForKey("visual-title")?.lowercaseString
                        if (NSString(string: visualTitle!).rangeOfString(currentSearch.lowercaseString).location == 0){
                            newResults.insert(i, atIndex: 0)
                        }
                        else {
                            newResults.append(i)
                        }
                        break
                    }
                }
            }
            i++
        }
        /*
        let searchFirstWord=searchWords.first
        if (searchFirstWord != nil){
        
        results=results.sort({ (a:Int, b:Int) in
            if (searchIndex.count>a){
                let indexWords=searchIndex[a]
                print(".")
                if (NSString(string: indexWords.first!).rangeOfString(searchFirstWord!).location == 0){
                    print("\(searchFirstWord)==\(indexWords.first!)")
                    return true
                }
            }
            return false
        })
        }*/
        
        /*results.sortInPlace(isOrderedBefore:({ (a:Int, b:Int) in
        
            return true
        })*/
        
        /*newFoundWords.sortInPlace({ (stringA:String, stringB:String) -> Bool in
            
            if (stringA.characters.count<stringB.characters.count){
                return true
            }
            
            return false
        })*/
        NSLog("time measurement ended")
        
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
        cell.imageView?.image=nil
        let dict=searchItems[results[indexPath.row]]
        let imageURL=unfold(dict, instructions: ["images",["sqr","cvr","wss","lss","wsr","pss","pns",""],["lg","md","sm",""]]) as? String
        if (imageURL != nil){
            fetchDataUsingCache(imageURL!, downloaded: {
                
                dispatch_async(dispatch_get_main_queue()) {
                    if (cell.tag==indexPath.row){
                        let image=imageUsingCache(imageURL!)
                        cell.imageView?.image=image
                        cell.layoutIfNeeded()
                        cell.layoutSubviews()
                        cell.imageView?.layoutIfNeeded()
                    }
                }
            })
        }
        
        cell.textLabel?.text=dict.objectForKey("visual-title") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        print("did update")
        if (context.nextFocusedIndexPath != nil){
            print("next focused indexpath")
        let imageURL=unfold(searchItems[results[context.nextFocusedIndexPath!.row]], instructions: ["images",["wss","cvr","lss","wsr","pss","pns",""],["lg","md","sm",""]]) as? String
            if (imageURL != nil){
                print("url real")
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
    let player=SuperMediaPlayer()
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let dict=searchItems[ results[indexPath.row] ]
        player.updatePlayerUsingDictionary(dict)
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
