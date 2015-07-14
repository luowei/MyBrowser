//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import "BaseWebViewController.h"
#import "MyPopupView.h"
#import "Defines.h"

@interface BaseWebViewController () <UISearchBarDelegate, MyPopupViewDelegate>

@end

@implementation BaseWebViewController {
    BOOL menuIsShow;
}

- (void)loadView {
    [super loadView];

    //进度条
    [self addProgressBar];

    //顶部地址搜索栏
    [self addTopBar];

    //添加webContainer
    [self addWebContainer];

    //底部工具栏
    [self addBottomBar];

    //设置初始值
    self.backBtn.enabled = NO;
    self.forwardBtn.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    //加上这句可以去掉毛玻璃效果
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    //隐藏backItem
    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.progressView];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.progressView removeFromSuperview];
    self.navigationController.toolbarHidden = YES;
}

//进度条
- (void)addProgressBar {
    //进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
}

//地址栏
- (void)addTopBar {
    //地址栏
    self.searchBar = [UISearchBar new];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Keyword or Url", nil);//@"搜索或输入地址";
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeYes;

    //二维码扫描按钮
    self.searchBar.showsBookmarkButton = YES;
    [self.searchBar setImage:[UIImage imageNamed:@"RQScanNormal"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"RQScanSelected"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateSelected];

    self.navigationItem.titleView = self.searchBar;

    UIButton *btton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btton setFrame:CGRectMake(0, 0, 30, 30)];
    [btton addTarget:self action:@selector(presentAddWebViewVC) forControlEvents:UIControlEventTouchUpInside];

    UIImage *image = [UIImage imageNamed:@"mutiwindow"];
    [btton setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btton];
//    barButton.action = @selector(presentAddWebViewVC);
//    barButton.target = self;
    self.navigationItem.rightBarButtonItem = barButton;

}

//底部工具栏
- (void)addBottomBar {
    //底部工具栏
    self.homeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStylePlain target:self action:@selector(home)];
    self.favoriteBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite"] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    self.menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menu)];
    self.reloadBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(reload:)];
    self.backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.forwardBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(forward:)];

    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.toolbarItems = @[self.homeBtn, fixedSpace, self.favoriteBtn, fixedSpace, self.menuBtn, fixedSpace, self.reloadBtn, flexibleSpace, self.backBtn, fixedSpace, self.forwardBtn];
}

//webContainer作为webView的容器
- (void)addWebContainer {
    self.webContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.webContainer];
    self.webContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[webContainer]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webContainer" : self.webContainer}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webContainer]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webContainer" : self.webContainer}]];
}

//设置菜单
- (void)menu {
    if (!menuIsShow) {
        [self showMenu];
    } else {
        [self hiddenMenu];
    }
}

//显示设置菜单
- (void)showMenu {
    CGRect frame = self.view.frame;
//    NSString *timeMode = self.webmaskLayer == nil ? NSLocalizedString(@"Nighttime", nil) : NSLocalizedString(@"Daytime", nil);
    NSString *timeMode = self.maskView == nil ? NSLocalizedString(@"Nighttime", nil) : NSLocalizedString(@"Daytime", nil);
    NSArray *titleArray = @[NSLocalizedString(@"Bookmarks", nil), timeMode, NSLocalizedString(@"Clear All History", nil),NSLocalizedString(@"About Me", nil)];
    self.popupView = [[MyPopupView alloc] initWithFrame:CGRectMake(0, frame.size.height - self.bottomLayoutGuide.length - 100, frame.size.width, 100) dataSource:titleArray];
    self.popupView.delegate = self;
    
    self.popupContanierView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:self.popupContanierView];
    self.popupContanierView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *popContanierConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[popupContanierView]|" options:0 metrics:nil views:@{@"popupContanierView":self.popupContanierView}].mutableCopy;
    [popContanierConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-0-[popupContanierView]-0-[bottomLayoutGuide]" options:0 metrics:0 views:@{@"topLayoutGuide":self.topLayoutGuide,@"popupContanierView":self.popupContanierView,@"bottomLayoutGuide":self.bottomLayoutGuide}]];
    [NSLayoutConstraint activateConstraints:popContanierConstraints];
    
    [self.popupContanierView addSubview:self.popupView];
    self.popupView.translatesAutoresizingMaskIntoConstraints = NO;
    self.popupviewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[popupView]|" options:0 metrics:nil views:@{@"popupView" : self.popupView}].mutableCopy;
    [self.popupviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[popupView(100)]|" options:0 metrics:nil views:@{@"popupView" : self.popupView}]];
    [NSLayoutConstraint activateConstraints:self.popupviewConstraints];

    menuIsShow = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self hiddenMenu];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint pointInside = [touch locationInView:self.popupContanierView];
        if (!CGRectContainsPoint(self.popupView.frame, pointInside)){
            [self hiddenMenu];
            return;
        }
    }];

//    UITouch *touch = [touches anyObject];
//    CGPoint pointInside = [touch locationInView:self.popupContanierView];
//
//    if (CGRectContainsPoint(self.popupView.frame, pointInside)){
//        [self hiddenMenu];
//    }

}


//隐藏设置菜单
- (void)hiddenMenu {
    [self.popupContanierView removeFromSuperview];
    [self.popupView removeFromSuperview];
    self.popupContanierView = nil;
    self.popupView = nil;
    menuIsShow = NO;
}

#pragma mark UISearchBarDelegate Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsBookmarkButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
}


#pragma mark MyPopupViewDelegate Implementation

//当设置菜单项被选中
- (void)popupViewItemTaped:(MyCollectionViewCell *)cell {
}

#pragma mark - UIScrollViewDelegate Implementation

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    bool hide = (scrollView.contentOffset.y > self.lastOffsetY);
    [self.navigationController setNavigationBarHidden:hide animated:YES];
    [self.navigationController setToolbarHidden:hide animated:YES];

}

@end