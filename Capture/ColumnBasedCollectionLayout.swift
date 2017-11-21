//
//  ColumnBasedCollectionLayout.swift
//  Capture
//
//  Created by Jin Budelmann on 10/10/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit

class ColumnBasedCollectionLayout: UICollectionViewFlowLayout {
    var columns: Int = 2 {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override var sectionInset: UIEdgeInsets {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override var minimumInteritemSpacing: CGFloat {
        didSet {
            self.invalidateLayout()
        }
    }

    override func prepare() {
        super.prepare()
        
        let width = self.collectionView!.frame.size.width
        
        // Take total width
        var itemWidth = width
        
        // Minus of section insets
        itemWidth -= self.sectionInset.left + self.sectionInset.right
        
        // Minus off spacing inbetween cells
        itemWidth -= self.minimumInteritemSpacing * CGFloat(self.columns - 1)
        
        // Divide by the number of columns
        itemWidth /= CGFloat(self.columns)
        
        self.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
