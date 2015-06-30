//
//  MyPopupView.h
//  MyBrowser
//
//  Created by luowei on 15/6/29.
//  Copyright (c) 2015 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyCollectionViewCell;

@protocol MyPopupViewDelegate<NSObject>

-(void)popupViewItemTaped:(MyCollectionViewCell *)cell;

@end;

@interface MyPopupView : UIView

@property (nonatomic, strong) id<MyPopupViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array;
@end


@interface MyCollectionView : UICollectionView

@end

@interface MyCollectionViewCell:UICollectionViewCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *imgView;

@end


@interface MyCollectionViewFlowLayout:UICollectionViewFlowLayout

@end
