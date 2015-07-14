//
//  NFTabCollectionViewCell.m
//  NFSafariTabs
//
//  Created by Ricardo Santos on 21/04/2015.
//  Copyright (c) 2015 NextFaze. All rights reserved.
//

#import "NFTabCollectionViewCell.h"

@implementation NFTabCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_center_button"]];
        [self.contentView addSubview:self.backgroundImageView];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (frame.size.height - 50.0)/2.0, frame.size.width, 50.0)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
