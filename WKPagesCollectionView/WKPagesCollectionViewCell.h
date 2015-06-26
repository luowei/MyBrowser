//
//  WKPagesCollectionViewCell.h
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-15.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum WKPagesCollectionViewCellShowingState:NSUInteger{
    WKPagesCollectionViewCellShowingStateNormal=0,
    WKPagesCollectionViewCellShowingStateHightlight=1,
    WKPagesCollectionViewCellShowingStateBackToTop=2,
    WKPagesCollectionViewCellShowingStateBackToBottom=3,
} WKPagesCollectionViewCellShowingState;
@interface WKPagesCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>{
    WKPagesCollectionViewCellShowingState _showingState;
    UITapGestureRecognizer* _tapGesture;
    UIScrollView* _scrollView;
//    UIImageView* _maskImageView;
}
///Position the normal state
@property (nonatomic,assign) CATransform3D normalTransform;
///Position the normal state
@property (nonatomic,assign) CGRect normalFrame;
///Display status
@property (nonatomic,assign) WKPagesCollectionViewCellShowingState showingState;
///Quote collectionView
@property (nonatomic,assign) UICollectionView* collectionView;
@property (nonatomic,retain) UIView* cellContentView;
-(UIImage*)makeGradientImage;
@end
