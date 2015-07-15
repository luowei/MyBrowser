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
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        [self.contentView addSubview:self.backgroundImageView];

        //backgroundImageView
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *backConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundImageView]|" options:0 metrics:nil views:@{@"backgroundImageView":self.backgroundImageView}].mutableCopy;
        [backConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:0 metrics:nil views:@{@"backgroundImageView":self.backgroundImageView}]];
        [NSLayoutConstraint activateConstraints:backConstraints];

        //titleView
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        titleView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:titleView];

        titleView.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *titleViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[titleView]|" options:0 metrics:nil views:@{@"titleView":titleView}].mutableCopy;
        [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView(40)]" options:0 metrics:nil views:@{@"titleView":titleView}]];
        [NSLayoutConstraint activateConstraints:titleViewConstraints];

        //titleLabel
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, frame.size.width-40, 40.0)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [titleView addSubview:self.titleLabel];

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *titleConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-40-[titleLabel]|" options:0 metrics:nil views:@{@"titleLabel":self.titleLabel}].mutableCopy;
        [titleConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:@{@"titleLabel":self.titleLabel}]];
        [NSLayoutConstraint activateConstraints:titleConstraints];

        //closeBtn
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeBtn setTitle:@"Χ" forState:UIControlStateNormal];
        [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        self.closeBtn.frame = CGRectMake(0, 0, 40, 40);
        [titleView addSubview:self.closeBtn];

        self.closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *closeBtnConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[closeBtn(40)]" options:0 metrics:nil views:@{@"closeBtn":self.closeBtn}].mutableCopy;
        [closeBtnConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[closeBtn]|" options:0 metrics:nil views:@{@"closeBtn":self.closeBtn}]];
        [NSLayoutConstraint activateConstraints:closeBtnConstraints];

        //imageView
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];

        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *imageViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:@{@"imageView":self.imageView}].mutableCopy;
        [imageViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[imageView]|" options:0 metrics:nil views:@{@"imageView":self.imageView}]];
        [NSLayoutConstraint activateConstraints:imageViewConstraints];
    }
    return self;
}

@end
