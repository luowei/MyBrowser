//
//  WK.h
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-25.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#ifndef WKPagesScrollView_WK_h
#define WKPagesScrollView_WK_h

#define WKPagesCollectionViewPageSpacing 160.0f

static inline CATransform3D WKFlipCATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, -300.0f);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 300.0f);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}
static inline CATransform3D WKFlipCATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, WKFlipCATransform3DMakePerspective(center, disZ));
}
static inline CATransform3D WKFlipCATransform3DPerspectSimple(CATransform3D t){
    return WKFlipCATransform3DPerspect(t, CGPointMake(0, 0), 1500.0f);
}
static inline CATransform3D WKFlipCATransform3DPerspectSimpleWithRotate(CGFloat degree){
    return WKFlipCATransform3DPerspectSimple(CATransform3DMakeRotation((M_PI*degree/180.0f), 1.0, 0.0, 0.0));
}
static inline UIImage* makeImageForView(UIView*view){
    double startTime=CFAbsoluteTimeGetCurrent();
    if(UIGraphicsBeginImageContextWithOptions != NULL){
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"makeImage duration:%f", CFAbsoluteTimeGetCurrent()-startTime);
    return image;
}
#endif
