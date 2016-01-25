//
//  SearchController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/21/15.
//  Copyright © 2015 xquared. All rights reserved.
//


/*

This View Controller primarily acts as a container for a UISearchBar and UISearchResultsUpdating class. SearchTAbleHandlerViewController does all the work as far as searching.

*/

import UIKit

class SearchController: UISearchController, UISearchControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var resultsTableView: UITableView!
    
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
    
    func supportInit(){
        self.definesPresentationContext=false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    let backgroundImageView=UIImageView(frame: UIScreen.mainScreen().bounds)
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        /*
        Every time the view goes to reappear this code runs to check if the language was changed by the Language tab. If it was then everything gets refreshed.
        */
        
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
    
}
