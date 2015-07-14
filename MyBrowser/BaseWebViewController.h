//
// Created by luowei on 15/7/5.
// Copyright (c) 2015 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyPopupView;
@class MyCollectionViewCell;


@interface BaseWebViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic, strong) NSMutableArray *favoriteArray;

@property(strong, nonatomic) UISearchBar *searchBar;
@property(nonatomic, strong) UIBarButtonItem *backBtn;
@property(nonatomic, strong) UIBarButtonItem *forwardBtn;
@property(nonatomic, strong) UIBarButtonItem *reloadBtn;
@property(nonatomic, strong) UIProgressView *progressView;

@property(nonatomic, strong) UIButton *addWebViewBtn;
@property(nonatomic, strong) UIBarButtonItem *homeBtn;
@property(nonatomic, strong) UIBarButtonItem *favoriteBtn;
@property(nonatomic, strong) UIBarButtonItem *menuBtn;

@property(nonatomic, strong) UIView *webContainer;

@property(nonatomic, strong) MyPopupView *popupView;
//@property(nonatomic, strong) CALayer *webmaskLayer;
@property(nonatomic, strong) UIView *maskView;


@property(nonatomic) CGFloat lastOffsetY;


@property(nonatomic, strong) UIView *popupContanierView;

@property(nonatomic, strong) NSMutableArray *popupviewConstraints;

//进度条
- (void)addProgressBar;

//地址栏
- (void)addTopBar;

//底部工具栏
- (void)addBottomBar;

//webContainer作为webView的容器
- (void)addWebContainer;



//设置菜单
- (void)menu;

//显示设置菜单
- (void)showMenu;

//隐藏设置菜单
- (void)hiddenMenu;

#pragma mark UISearchBarDelegate Implementation

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;


#pragma mark MyPopupViewDelegate Implementation

//当设置菜单项被选中
- (void)popupViewItemTaped:(MyCollectionViewCell *)cell;


@end