//
//  ListWKWebViewController.m
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import "ListWKWebViewController.h"
#import "MyWKWebView.h"
#import "Defines.h"
#import "MyHelper.h"
#import "NFCollectionViewTabsLayout.h"
#import "NFTabCollectionViewCell.h"

NSString *const CellReuseIdentifier = @"CellReuseIdentifier";

@interface ListWKWebViewController () <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) NFCollectionViewTabsLayout *tabsLayout;
@property(nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ListWKWebViewController

- (instancetype)initWithWKWebView:(MyWKWebView *)webView {
    self = [super init];
    if (self) {
        __weak __typeof(self) weakSelf = self;
        self.updateWKDatasourceBlock = ^(MyWKWebView *wb) {
            if (!weakSelf.windows) {
                weakSelf.windows = @[wb].mutableCopy;
            } else {
                [weakSelf.windows addObject:wb];
            }

        };
        self.updateWKDatasourceBlock(webView);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    //构建CollectionView
    _tabsLayout = [[NFCollectionViewTabsLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_tabsLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[NFTabCollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    _collectionView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:_collectionView];

    //添加约束
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|" options:0
                                                                          metrics:nil views:@{@"collectionView":_collectionView}].mutableCopy;
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-0-[collectionView]-0-[bottomLayoutGuide]" options:0 metrics:nil
                                                                               views:@{@"collectionView":_collectionView,@"topLayoutGuide":self.topLayoutGuide,@"bottomLayoutGuide":self.bottomLayoutGuide}]];
    [NSLayoutConstraint activateConstraints:constraints];

    //添加滑动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [_collectionView addGestureRecognizer:panGestureRecognizer];

    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWebView:)];
    UIBarButtonItem *closeAllItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close All", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeAll)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    toolbar.items = @[addItem, flexibleSpace, closeAllItem];
    [self.view addSubview:toolbar];

    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[toolbar]|" options:0 metrics:nil views:@{@"toolbar" : toolbar}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar(44)]|" options:0 metrics:nil views:@{@"toolbar" : toolbar}]];

}

#pragma mark -

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = nil;

    if (recognizer.state == UIGestureRecognizerStateBegan) {

        indexPath = [self.collectionView indexPathForItemAtPoint:point];
        self.tabsLayout.pannedItemIndexPath = indexPath;
        self.tabsLayout.panStartPoint = point;

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.tabsLayout.panUpdatePoint = point;

        CGPoint offset = [recognizer translationInView:self.view];
        if(offset.x < -200){
            if(_windows.count <= 1){
                return;
            }
            [_windows removeObjectAtIndex:(NSUInteger) indexPath.row];
            [_collectionView reloadData];
        }

    } else {
        self.tabsLayout.pannedItemIndexPath = nil;
    }

    [self.tabsLayout invalidateLayout];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.collectionView];
    if (fabs(velocity.x) > fabs(velocity.y)) {
        return YES;
    }

    return NO;
}

//添加一个webView
- (void)addWebView:(id)sender {
    //添加一个webView,block会回调_windows addObject
    MyWKWebView *webView;
    self.addWKWebViewBlock(&webView,HOME_URL);

    [_collectionView reloadData];
}

//关闭一个窗口
- (void)closeWebView:(UIButton *)closeBtn{
    if(_windows.count <= 1){
        return;
    }

    NFTabCollectionViewCell *cell = (NFTabCollectionViewCell *) [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:closeBtn.tag inSection:0]];
    cell.titleLabel.text = nil;
    cell.imageView.image = nil;
    [_windows removeObjectAtIndex:(NSUInteger) closeBtn.tag];

    [_collectionView reloadData];
}

//全部关闭
- (void)closeAll {

    [_windows enumerateObjectsUsingBlock:^(MyWKWebView *wb, NSUInteger idx, BOOL *stop) {
        NFTabCollectionViewCell *cell = (NFTabCollectionViewCell *) [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        cell.titleLabel.text = nil;
        cell.imageView.image = nil;
    }];

    [_windows removeAllObjects];

    //添加一个webView,block会回调_windows addObject
    MyWKWebView *webView = nil;
    self.addWKWebViewBlock(&webView,HOME_URL);

    [_collectionView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark UICollectionViewDataSource Implementation

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _windows.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NFTabCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];

    MyWKWebView *webView = _windows[(NSUInteger) indexPath.row];

    //对wkwebView截图
    if(!webView.screenImage){
        webView.screenImage = [webView screenCapture:webView.bounds.size];
    }

    BOOL transparent = [webView.screenImage getImageAlphaValue] < 0.01;
    if(transparent){
        if(!cell.imageView.image){
            //设置一张空白图片
            cell.imageView.image = [UIImage imageWithColor:[UIColor whiteColor]];
        }
    }else{
        cell.imageView.image = webView.screenImage;
    }

    cell.titleLabel.text = webView.title;
    cell.titleLabel.textColor = [UIColor blueColor];

    cell.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.contentView.layer.shadowOffset = CGSizeMake(0.0, (CGFloat) -40.0);
    cell.contentView.layer.shadowOpacity = 0.2;
    cell.contentView.layer.shadowRadius = 40.0;
    cell.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.contentView.bounds].CGPath;

    [cell.closeBtn addTarget:self action:@selector(closeWebView:) forControlEvents:UIControlEventTouchUpInside];
    cell.closeBtn.tag = indexPath.row;

    return cell;
}

#pragma mark UICollectionViewDelegate Implementation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self viewWillAppear:YES];

    MyWKWebView *webView = _windows[(NSUInteger) indexPath.row];
    self.updateWKActiveWindowBlock(webView);
    [_collectionView deselectItemAtIndexPath:indexPath animated:NO];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
