//
//  MODSubcategoryCollectionView.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/4/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class MODSubcategoryCollectionView: SuperCollectionView {
    
    var categoryName=""
    var categoryCode=""
    let categoryLabel=UILabel()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initSupport()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSupport()
    }
    
    func initSupport(){
        categoryLabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        categoryLabel.frame=CGRectMake(0, 0, self.frame.size.width, 40)
        categoryLabel.text=categoryName
        self.addSubview(categoryLabel)
    }
    
    override func prepare() {
        super.prepare()
        categoryLabel.text=categoryName
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            self.categoryLabel.textAlignment=NSTextAlignment.Right
        }
        else {
            self.categoryLabel.textAlignment=NSTextAlignment.Left
        }
        
        self.categoryLabel.text=categoryName
        
        
    }
    
}
