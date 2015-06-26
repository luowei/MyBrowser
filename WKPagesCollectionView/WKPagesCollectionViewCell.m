//
//  WKPagesCollectionViewCell.m
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-15.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKPagesCollectionViewCell.h"
#import "WKPagesCollectionView.h"
@implementation WKPagesCollectionViewCell
@dynamic showingState;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds=NO;
        self.backgroundColor=[UIColor clearColor];
        self.contentView.tag=100;
        CGRect rect=CGRectMake(0.0f, 0.0f,
                               [UIScreen mainScreen].bounds.size.width,
                               [UIScreen mainScreen].bounds.size.height);
        if (!_scrollView){
            _scrollView=[[UIScrollView alloc]initWithFrame:rect];
            _scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            _scrollView.clipsToBounds=NO;
            _scrollView.backgroundColor=[UIColor clearColor];
            _scrollView.showsVerticalScrollIndicator=NO;
            _scrollView.showsHorizontalScrollIndicator=YES;
            _scrollView.contentSize=CGSizeMake(_scrollView.frame.size.width+1, _scrollView.frame.size.height);
            _scrollView.delegate=self;
            [self.contentView addSubview:_scrollView];
            _scrollView.tag=101;
        }
        if (!_cellContentView){
            _cellContentView=[[UIView alloc]initWithFrame:rect];
            _cellContentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [_scrollView addSubview:_cellContentView];
            _cellContentView.tag=102;
        }

        if (!_tapGesture){
            _tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapGesture:)];
            [_scrollView addGestureRecognizer:_tapGesture];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc{
//    [_tapGesture release];
//    [_cellContentView release];
//    [_scrollView release];
//    [super dealloc];
}
-(void)prepareForReuse{
    [super prepareForReuse];
    for (UIView* view in _cellContentView.subviews) {
        [view removeFromSuperview];
    }
    
}
-(IBAction)onTapGesture:(UITapGestureRecognizer*)tapGesture{
    NSIndexPath* indexPath=[self.collectionView indexPathForCell:self];
//    NSLog(@"row:%d",indexPath.row);
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
//    [(WKPagesCollectionView*)self.collectionView showCellToHighLightAtIndexPath:indexPath completion:^(BOOL finished) {
//        NSLog(@"highlight completed");
//    }];
}
#pragma mark - Properties
-(void)setShowingState:(WKPagesCollectionViewCellShowingState)showingState{
    if (_showingState==showingState)
        return;
    _showingState=showingState;
    WKPagesCollectionViewFlowLayout* collectionLayout=(WKPagesCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat pageHeight=collectionLayout.pageHeight;
    CGFloat topMargin=[(WKPagesCollectionView*)self.collectionView topOffScreenMargin];
    switch (showingState) {
        case WKPagesCollectionViewCellShowingStateHightlight:{
            self.normalTransform=self.layer.transform;///The original location of the first record
            _scrollView.scrollEnabled=NO;
            NSIndexPath* indexPath=[self.collectionView indexPathForCell:self];
            CGFloat moveY=self.collectionView.contentOffset.y-(WKPagesCollectionViewPageSpacing)*indexPath.row +topMargin;
            CATransform3D moveTransform=CATransform3DMakeTranslation(0.0f, moveY, 0.0f);
            self.layer.transform=moveTransform;
        }
            break;
        case WKPagesCollectionViewCellShowingStateBackToTop:{
            self.normalTransform=self.layer.transform;///The original location of the first record
            _scrollView.scrollEnabled=NO;
            CATransform3D moveTransform=CATransform3DMakeTranslation(0, -1*pageHeight-topMargin, 0);
            self.layer.transform=CATransform3DConcat(CATransform3DIdentity, moveTransform);
        }
            break;
        case WKPagesCollectionViewCellShowingStateBackToBottom:{
            self.normalTransform=self.layer.transform;///The original location of the first record
            _scrollView.scrollEnabled=NO;
            CATransform3D moveTransform=CATransform3DMakeTranslation(0, pageHeight+topMargin, 0);
            self.layer.transform=CATransform3DConcat(CATransform3DIdentity, moveTransform);
        }
            break;
        case WKPagesCollectionViewCellShowingStateNormal:{
            self.layer.transform=self.normalTransform;
            _scrollView.scrollEnabled=YES;
        }
            break;
        default:
            break;
    }
    
    
    
}
-(WKPagesCollectionViewCellShowingState)showingState{
    return _showingState;
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.showingState==WKPagesCollectionViewCellShowingStateNormal){
        if (scrollView.contentOffset.x>=90.0f){
            NSIndexPath* indexPath=[self.collectionView indexPathForCell:self];
            NSLog(@"delete cell at %d",indexPath.row);
            //self.alpha=0.0f;
            ///Delete data
            id<WKPagesCollectionViewDataSource> pagesDataSource=(id<WKPagesCollectionViewDataSource>)self.collectionView.dataSource;
            [pagesDataSource collectionView:(WKPagesCollectionView*)self.collectionView willRemoveCellAtIndexPath:indexPath];
            ///Animation
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath,]];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}
#pragma mark - Image
-(UIImage*)makeGradientImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.0f);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.0,0.0,0.0, 0.0,  // Start color
        0.0,0.0,0.0,1.0}; // End color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    CGContextDrawLinearGradient(context, myGradient, CGPointMake(self.bounds.size.width/2, 100.0f), CGPointMake(self.bounds.size.width/2, self.bounds.size.height-100.0f), kCGGradientDrawsAfterEndLocation);
    
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return image;
}
@end
