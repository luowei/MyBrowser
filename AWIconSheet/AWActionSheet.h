//
//  AWActionSheet.h
//  AWIconSheet
//
//  Created by Narcissus on 10/26/12.
//  Copyright (c) 2012 Narcissus. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AWActionSheetCell;
@class AWActionSheet;

@protocol AWActionSheetDelegate <UIActionSheetDelegate>

- (int)numberOfItemsInActionSheet;
- (AWActionSheetCell*)cellForActionAtIndex:(NSInteger)index;
- (void)DidTapOnItemAtIndex:(NSInteger)index title:(NSString*)name;

@end

static AWActionSheet *awActionSheet = nil;

@interface AWActionSheet : UIWindow
-(id)initWithIconSheetDelegate:(id<AWActionSheetDelegate>)delegate ItemCount:(int)cout;

- (void)show;
- (void)dismiss;

@end


@interface AWActionSheetCell : UIView
@property (nonatomic,retain)UIImageView* iconView;
@property (nonatomic,retain)UILabel*     titleLabel;
@property (nonatomic,assign)int          index;
@end