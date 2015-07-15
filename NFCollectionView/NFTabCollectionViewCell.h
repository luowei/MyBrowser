//
//  NFTabCollectionViewCell.h
//  NFSafariTabs
//
//  Created by Ricardo Santos on 21/04/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFTabCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIButton *closeBtn;
@end
