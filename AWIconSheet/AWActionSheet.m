//
//  AWActionSheet.m
//  AWIconSheet
//
//  Created by Narcissus on 10/26/12.
//  Copyright (c) 2012 Narcissus. All rights reserved.
//

#import "AWActionSheet.h"
#import <QuartzCore/QuartzCore.h>

@interface AWActionSheet()<UIScrollViewDelegate>
@property (nonatomic, retain)UIScrollView* scrollView;
@property (nonatomic, retain)UIPageControl* pageControl;
@property (nonatomic, retain)NSMutableArray* items;
@property (nonatomic, assign)id<AWActionSheetDelegate> IconDelegate;
@property (nonatomic, assign) NSInteger itemCountforOneLine;

@property (nonatomic, strong) UIView *backgroundMask;
@property (nonatomic, strong) UIView *contentView;
@end
@implementation AWActionSheet
@synthesize scrollView;
@synthesize pageControl;
@synthesize items;
@synthesize IconDelegate;
-(void)dealloc
{
    IconDelegate= nil;
}


-(id)initWithIconSheetDelegate:(id<AWActionSheetDelegate>)delegate ItemCount:(int)count
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.backgroundMask = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundMask.backgroundColor = [UIColor blackColor];
        self.backgroundMask.alpha = 0;
        [self addSubview:self.backgroundMask];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self.backgroundMask addGestureRecognizer:tap];

        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.contentView];
        self.itemCountforOneLine = 4;

        IconDelegate = delegate;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.contentView.bounds), 105*3)];
        [scrollView setPagingEnabled:YES];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setDelegate:self];
        [scrollView setScrollEnabled:YES];
        [scrollView setBounces:NO];

        [self.contentView addSubview:scrollView];

        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.scrollView.frame), CGRectGetWidth(self.contentView.bounds), 20)];
        [pageControl setNumberOfPages:0];
        [pageControl setCurrentPage:0];
        pageControl.hidesForSinglePage = YES;
        [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:pageControl];

        self.items = [[NSMutableArray alloc] initWithCapacity:count];
        self.windowLevel = UIWindowLevelAlert;
    }

    return self;
}

static AWActionSheet *sheet = nil;

- (void)dismiss
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundMask.alpha = 0;
        [self setContentViewFrameY:CGRectGetHeight(self.bounds)];
    } completion:^(BOOL finished) {
        sheet.hidden = YES;
        sheet = nil;
    }];
}

- (void)setContentViewFrameY:(CGFloat)y
{
    CGRect frame = self.contentView.frame;
    frame.origin.y = y;
    self.contentView.frame = frame;
}

- (void)show
{
    [self reloadData];

    sheet = self;
    sheet.hidden = NO;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundMask.alpha = 0.6;
        [self setContentViewFrameY:CGRectGetHeight(self.bounds) - CGRectGetHeight(self.contentView.frame)];
    } completion:^(BOOL finished) {

    }];
}

- (void)reloadData
{
    for (AWActionSheetCell* cell in items) {
        [cell removeFromSuperview];
        [items removeObject:cell];
    }

    int count = [IconDelegate numberOfItemsInActionSheet];

    if (count <= 0) {
        return;
    }

    int rowCount = 3;

    if (count <= self.itemCountforOneLine) {
        [scrollView setFrame:CGRectMake(0, 10, CGRectGetWidth(self.contentView.bounds), 105)];
        rowCount = 1;
    } else if (count <= self.itemCountforOneLine*2) {
        [scrollView setFrame:CGRectMake(0, 10, CGRectGetWidth(self.contentView.bounds), 210)];
        rowCount = 2;
    }

    CGFloat pageControlY = CGRectGetMinY(self.scrollView.frame) + CGRectGetHeight(self.scrollView.frame);
    CGRect pageControlFrame = self.pageControl.frame;
    pageControlFrame.origin.y = pageControlY;
    self.pageControl.frame = pageControlFrame;

    NSUInteger itemPerPage = self.itemCountforOneLine*rowCount;
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.contentView.bounds)*ceilf((((float)count)/itemPerPage)), scrollView.frame.size.height)];
    [pageControl setNumberOfPages:ceilf((((float)count)/itemPerPage))];
    [pageControl setCurrentPage:0];

    CGFloat margin = 8;
    CGFloat width = self.scrollView.frame.size.width - margin*2;

    for (int i = 0; i< count; i++) {
        AWActionSheetCell* cell = [IconDelegate cellForActionAtIndex:i];
        int PageNo = i/itemPerPage;
        int index  = i%itemPerPage;

        int row = index/self.itemCountforOneLine;
        int column = index%self.itemCountforOneLine;

        float centerY = (1+row*2)*self.scrollView.frame.size.height/(2*rowCount);
        float centerX = (1+column*2)*width/(2*self.itemCountforOneLine);

        [cell setCenter:CGPointMake(margin + centerX+CGRectGetWidth(self.contentView.bounds)*PageNo, centerY)];
        [self.scrollView addSubview:cell];

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionForItem:)];
        [cell addGestureRecognizer:tap];

        [items addObject:cell];
    }

    UIView *scrollBG = [[UIView alloc] initWithFrame:CGRectMake(margin, 8, CGRectGetWidth(self.scrollView.frame) - margin * 2, CGRectGetHeight(self.scrollView.frame))];
    scrollBG.backgroundColor = [UIColor whiteColor];
    scrollBG.alpha = 0.9;
    scrollBG.clipsToBounds = YES;
    scrollBG.layer.cornerRadius = 5;
    [self.contentView insertSubview:scrollBG belowSubview:self.scrollView];

    CGFloat y = CGRectGetMinY(self.pageControl.frame) +  5 + (self.pageControl.numberOfPages == 1 ? 0 : CGRectGetHeight(self.pageControl.frame));
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(margin, y, CGRectGetWidth(self.contentView.frame) - margin * 2, 44);
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:0.22 green:0.45 blue:1 alpha:1] forState:UIControlStateNormal];
    [self setBtn:btn backgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];

    CGFloat height = CGRectGetMinY(btn.frame) + CGRectGetHeight(btn.frame) + 10;

    CGRect frame = self.contentView.frame;
    frame.size.height = height;
    self.contentView.frame = frame;
}

- (void)setBtn:(UIButton*)btn backgroundColor:(UIColor*)color
{
    [btn setBackgroundImage:[self singleColor:color size:CGSizeMake(5, 5)] forState:UIControlStateNormal];
}

- (UIImage*)singleColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

- (void)actionForItem:(UITapGestureRecognizer*)recongizer
{
    AWActionSheetCell* cell = (AWActionSheetCell*)[recongizer view];

    [self dismiss];
    [IconDelegate DidTapOnItemAtIndex:cell.index title:cell.titleLabel.text];
}

- (IBAction)changePage:(id)sender {
    int page = (int)pageControl.currentPage;
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.contentView.bounds) * page, 0)];
}
#pragma mark -
#pragma scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = scrollView.contentOffset.x /CGRectGetWidth(self.contentView.bounds);
    pageControl.currentPage = page;
}

@end

#pragma mark - AWActionSheetCell
@interface AWActionSheetCell ()
@end
@implementation AWActionSheetCell
@synthesize iconView;
@synthesize titleLabel;

-(id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 70, 70)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(6.5, 0, 57, 57)];
        [iconView setBackgroundColor:[UIColor clearColor]];
        [[iconView layer] setCornerRadius:10.5f];
        [[iconView layer] setMasksToBounds:YES];

        [self addSubview:iconView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63, 70, 13)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setShadowColor:[UIColor blackColor]];
        [titleLabel setShadowOffset:CGSizeMake(0, 0.5)];
        [titleLabel setAdjustsFontSizeToFitWidth:YES];
        [titleLabel setText:@""];
        [self addSubview:titleLabel];

        if ([self isVersionSupport:@"7.0"]) {
            titleLabel.textColor = [UIColor colorWithRed:94.0/255.0 green:94.0/255.0 blue:94.0/255.0 alpha:1];
            titleLabel.shadowColor = [UIColor clearColor];
            titleLabel.shadowOffset = CGSizeZero;
        }
    }
    return self;
}

- (BOOL)isVersionSupport:(NSString *)reqSysVer {
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return osVersionSupported;
}

@end


