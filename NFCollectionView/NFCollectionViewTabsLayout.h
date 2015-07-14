//
//  NFCollectionViewTabsLayout.h
//  NFSafariTabs
//
//  Created by Ricardo Santos on 21/04/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFCollectionViewTabsLayout : UICollectionViewLayout

@property (nonatomic, strong) NSIndexPath *pannedItemIndexPath;
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) CGPoint panUpdatePoint;

@end
