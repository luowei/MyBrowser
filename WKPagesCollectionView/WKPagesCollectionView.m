//
//  WKPagesScrollView.m
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-14.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKPagesCollectionView.h"

CGFloat const TOP_OFFSCREEN_MARGIN = 120;

@implementation WKPagesCollectionView
@dynamic maskShow;


- (CGFloat)topOffScreenMargin
{
    if (!_topOffScreenMargin) {
        _topOffScreenMargin = TOP_OFFSCREEN_MARGIN;
    }
    return _topOffScreenMargin;
}
-(id)initWithFrame:(CGRect)frame{
    WKPagesCollectionViewFlowLayout* flowLayout= [[WKPagesCollectionViewFlowLayout alloc] init];
    CGRect realFrame = CGRectMake(frame.origin.x, frame.origin.y-self.topOffScreenMargin,
                                  frame.size.width, frame.size.height + self.topOffScreenMargin);
    self = [super initWithFrame:realFrame collectionViewLayout:flowLayout];
    if (self){
        self.contentInset=UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
        self.highLightAnimationDuration=0.5f;
        self.dismisalAnimationDuration=0.5f;
    }
    return self;
}

-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden){
        if (_maskImageView){
            [_maskImageView removeFromSuperview];
            _maskImageView=nil;
        }
    }
    else{
        [self setMaskShow:_maskShow];
    }
}
#pragma mark - Mask
-(void)setMaskShow:(BOOL)maskShow{
    _maskShow=maskShow;
    if (maskShow){
        if (!_maskImageView){
            _maskImageView=[[UIImageView alloc]initWithImage:[self makeGradientImage]];
            [self.superview addSubview:_maskImageView];
        }
        _maskImageView.hidden=NO;
    }
    else{
        _maskImageView.hidden=YES;
    }
}
-(BOOL)maskShow{
    return _maskShow;
}
-(UIImage*)makeGradientImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.0f);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 3;
    CGFloat locations[] = { 0.0,0.6f, 1.0};
    CGFloat components[] = {
        0.0,0.0,0.0,0.0,  // Start color
        0.0,0.0,0.0,0.2,
        0.0,0.0,0.0,0.6}; // End color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    CGPoint myStartPoint={self.bounds.size.width/2,self.bounds.size.height/2};
    CGFloat myStartRadius=0, myEndRadius=self.bounds.size.width;
    CGContextDrawRadialGradient (context, myGradient, myStartPoint,
                                 myStartRadius, myStartPoint, myEndRadius,
                                 kCGGradientDrawsAfterEndLocation);
    
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - Actions
///Display status
-(void)showCellToHighLightAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL))completion{
    NSLog(@"row:%d",indexPath.row);
    if (_isHighLight){
        return;
    }
    ///如果在可视范围内就不要滚动了
    BOOL no_scroll=NO;
    NSArray* visibleIndexPaths=[self indexPathsForVisibleItems];
    for (NSIndexPath* indexPath in visibleIndexPaths) {
        if (indexPath.row==indexPath.row){
            no_scroll=YES;
        }
    }
    if (!no_scroll){
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
    double delayInSeconds = 0.3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.maskShow=NO;
        self.scrollEnabled=NO;
        [UIView animateWithDuration:self.highLightAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
                NSIndexPath* visibleIndexPath=[self indexPathForCell:cell];
                if (visibleIndexPath.row==indexPath.row){
                    cell.showingState=WKPagesCollectionViewCellShowingStateHightlight;
                }
                else if (visibleIndexPath.row<indexPath.row){
                    cell.showingState=WKPagesCollectionViewCellShowingStateBackToTop;
                }
                else if (visibleIndexPath.row>indexPath.row){
                    NSLog(@"indexPath:%d,visibleIndexPath:%d",indexPath.row,visibleIndexPath.row);
                    cell.showingState=WKPagesCollectionViewCellShowingStateBackToBottom;
                }
                else{
                    cell.showingState=WKPagesCollectionViewCellShowingStateNormal;
                }
            }];
        } completion:^(BOOL finished) {
            _isHighLight=YES;
            completion(finished);
            if ([self.delegate respondsToSelector:@selector(collectionView:didShownToHightlightAtIndexPath:)]){
                [(id<WKPagesCollectionViewDelegate>)self.delegate collectionView:self didShownToHightlightAtIndexPath:indexPath];
            }
        }];
    });
    
}
-(void)showCellToHighLightAtIndexPath:(NSIndexPath *)indexPath{
    if (_isHighLight){
        return;
    }
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    double delayInSeconds = 0.01f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.maskShow=NO;
        self.scrollEnabled=NO;
        [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            NSIndexPath* visibleIndexPath=[self indexPathForCell:cell];
            if (visibleIndexPath.row==indexPath.row){
                cell.showingState=WKPagesCollectionViewCellShowingStateHightlight;
            }
            else if (visibleIndexPath.row<indexPath.row){
                cell.showingState=WKPagesCollectionViewCellShowingStateBackToTop;
            }
            else if (visibleIndexPath.row>indexPath.row){
                cell.showingState=WKPagesCollectionViewCellShowingStateBackToBottom;
            }
            else{
                cell.showingState=WKPagesCollectionViewCellShowingStateNormal;
            }
        }];
        _isHighLight=YES;
    });
    
}
///Back to the original state
-(void)dismissFromHightLightWithCompletion:(void (^)(BOOL))completion{
    self.maskShow=YES;
    if (!_isHighLight)
        return;
    [UIView animateWithDuration:self.dismisalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            cell.showingState=WKPagesCollectionViewCellShowingStateNormal;
        }];
    } completion:^(BOOL finished) {
        self.scrollEnabled=YES;
        _isHighLight=NO;
        completion(finished);
        if ([self.delegate respondsToSelector:@selector(didDismissFromHightlightOnCollectionView:)]){
            [(id<WKPagesCollectionViewDelegate>)self.delegate didDismissFromHightlightOnCollectionView:self];
        }
    }];
}
///Append a page
-(void)appendItem{
    if (self.isHighLight){
        [self dismissFromHightLightWithCompletion:^(BOOL finished) {
            [self _addNewPage];
        }];
    }
    else{
        [self _addNewPage];
    }

}
///Adding a
-(void)_addNewPage{
    int total=[self numberOfItemsInSection:0];
    if (total > 0) {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:total-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
    
    double delayInSeconds = 0.3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ///Add Data
        [(id<WKPagesCollectionViewDataSource>)self.dataSource willAppendItemInCollectionView:self];
        int lastRow=total;
        NSIndexPath* insertIndexPath=[NSIndexPath indexPathForItem:lastRow inSection:0];
        [self performBatchUpdates:^{
            [self insertItemsAtIndexPaths:@[insertIndexPath]];
        } completion:^(BOOL finished) {
            double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [self showCellToHighLightAtIndexPath:insertIndexPath completion:^(BOOL finished) {
//
//                }];
            });
            
        }];
    });
}
#pragma mark - UIView and UICollectionView
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* view=[super hitTest:point withEvent:event];
    if (!view){
        return nil;
    }
    if (view==self){
        for (WKPagesCollectionViewCell* cell in self.visibleCells) {
            if (cell.showingState==WKPagesCollectionViewCellShowingStateHightlight){
                return cell.cellContentView;///Events should only be passed to this layer
            }
        }
    }
    return view;
//    UIView* view=[super hitTest:point withEvent:event];
//    NSLog(@"%@,%d",NSStringFromClass([view class]),view.tag);
//    return view;
}
@end
