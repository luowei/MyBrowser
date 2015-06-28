//
//  ViewController.m
//  MyBrowser
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import "ViewController.h"
#import "MyWebView.h"
#import "ListWebViewController.h"
#import "AWActionSheet.h"
#import "Defines.h"
#import "FavoritesViewController.h"
#import "MyHelper.h"

@implementation NSString (Match)


- (BOOL)isMatch:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return res != nil;
}

- (BOOL)isiTunesURL {
    return [self isMatch:@"\\/\\/itunes\\.apple\\.com\\/"];
}

//是否是域名
- (BOOL)isDomain {
    return [self isMatch:@"^([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}$"]
            || [self isMatch:@"^(www.|[a-zA-Z].)[a-zA-Z0-9\\-\\.]+\\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\;\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"];
}

//是否是网址
- (BOOL)isHttpURL {
    return [self isMatch:@"(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"]
            || [self isMatch:@"^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.[a-zA-Z]{2,4})(\\:[0-9]+)?(/[^/][a-zA-Z0-9\\.\\,\\?\\'\\\\/\\+&amp;%\\$#\\=~_\\-@]*)*$"]
            || [self isMatch:@"^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"];
}

@end


@implementation Favorite

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
        self.title = dic[@"title"];
        self.URL = dic[@"URL"];
        self.createtime = dic[@"createtime"] ?: [NSDate date];
    }
    return self;
}

- (instancetype)initWithCreateAt:(NSDate *)createtime content:(NSString *)title url:(NSURL *)URL {
    if (self = [super init]) {
        self.createtime = createtime ?: [NSDate date];
        self.title = title;
        self.URL = URL;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.URL = [coder decodeObjectForKey:@"URL"];
        self.createtime = [coder decodeObjectForKey:@"createtime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeObject:_URL forKey:@"URL"];
    [coder encodeObject:_createtime forKey:@"createtime"];
}

- (BOOL)isEqualToFavorite:(Favorite *)fav {
    return [_title isEqualToString:fav.title] && [_URL.absoluteString isEqualToString:fav.URL.absoluteString];
}

@end


@interface ViewController () <UISearchBarDelegate, AWActionSheetDelegate>


//@property(nonatomic, strong) UITextField *urlField;
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

@end

@implementation ViewController

- (void)loadView {
    [super loadView];

    //进度条
    [self addProgressBar];

    //顶部地址搜索栏
    [self addTopBar];

    //底部工具栏
    [self addBottomBar];

    //添加webContainer
    [self addWebContainer];

    //向webContainer中添加webview
    [self addWebView:HOME_URL];

    //设置初始值
    self.backBtn.enabled = NO;
    self.forwardBtn.enabled = NO;

    //添加对webView的监听器
    [self.activeWindow addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.activeWindow addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.activeWindow addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

//进度条
- (void)addProgressBar {
    //进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
//    self.progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, 3);

    //progressView进度条
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[progressView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"progressView" : self.progressView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progressView(2)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"progressView" : self.progressView}]];
}

//地址栏
- (void)addTopBar {
    //地址栏
    _searchBar = [UISearchBar new];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"Keyword or Url", nil);//@"搜索或输入地址";
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    self.navigationItem.titleView = _searchBar;

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
    _webContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:_webContainer belowSubview:_progressView];
    _webContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[webContainer]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webContainer" : _webContainer}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressView]-0-[webContainer]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webContainer" : _webContainer,
                                                                                @"progressView" : _progressView}]];
}

#pragma mark - Web View Creation

- (MyWebView *)addWebView:(NSURL *)url {
    //添加webview
    _activeWindow = [[MyWebView alloc] initWithFrame:_webContainer.frame configuration:[[WKWebViewConfiguration alloc] init]];
    _activeWindow.backgroundColor = [UIColor whiteColor];
    _activeWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_webContainer addSubview:_activeWindow];
    [_webContainer bringSubviewToFront:_activeWindow];

    //加载页面
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_activeWindow loadRequest:request];

    //更新刷新进度条的block
    __weak __typeof(self) weakSelf = self;
    _activeWindow.finishNavigationProgressBlock = ^() {
        [weakSelf.progressView setProgress:0.0 animated:NO];
        weakSelf.progressView.trackTintColor = [UIColor whiteColor];
    };

    //添加新webView的block
    _activeWindow.addWebViewBlock = ^(MyWebView **wb, NSURL *aurl) {
        if (*wb) {
            *wb = [weakSelf addWebView:aurl];
        } else {
            [weakSelf addWebView:aurl];
        }
    };

    //presentViewController block
    _activeWindow.presentViewControllerBlock = ^(UIViewController *viewController) {
        [weakSelf presentViewController:viewController animated:YES completion:nil];
    };

    //关闭激活的webView的block
    _activeWindow.closeActiveWebViewBlock = ^() {
        [weakSelf closeActiveWebView];
    };

    // Add to windows array and make active window
    if (!_listWebViewController) {
        _listWebViewController = [[ListWebViewController alloc] initWithWebView:_activeWindow];

        //设置添加webView的block
        _listWebViewController.addWebViewBlock = ^(MyWebView **wb, NSURL *aurl) {
            if (*wb) {
                *wb = [weakSelf addWebView:aurl];
            } else {
                [weakSelf addWebView:aurl];
            }
        };
        //更新活跃webView的block
        _listWebViewController.updateActiveWindowBlock = ^(MyWebView *wb) {
            weakSelf.activeWindow = wb;
            [weakSelf.webContainer bringSubviewToFront:weakSelf.activeWindow];
        };

    } else {
        _listWebViewController.updateDatasourceBlock(_activeWindow);
    }

    return _activeWindow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //加上这句可以去掉毛玻璃效果
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    //隐藏backItem
    [self.navigationItem setHidesBackButton:YES];

}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.toolbarHidden = NO;

    //从userDefault中加载收藏,给_favoriteArray赋初值
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:MY_FAVORITES];
    _favoriteArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];

    [_activeWindow reload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.toolbarHidden = YES;
}


- (void)dealloc {
    [self.activeWindow removeObserver:self forKeyPath:@"loading"];
    [self.activeWindow removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.activeWindow removeObserver:self forKeyPath:@"title"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        self.backBtn.enabled = self.activeWindow.canGoBack;
        self.forwardBtn.enabled = self.activeWindow.canGoForward;
    }
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.hidden = self.activeWindow.estimatedProgress == 1;
        [self.progressView setProgress:(float) self.activeWindow.estimatedProgress animated:YES];
    }
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.activeWindow.title;
    }
}

//添加新webView窗口
- (void)presentAddWebViewVC {
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_listWebViewController];
//    [self presentViewController:_listWebViewController animated:YES completion:nil];

    [self.navigationController pushViewController:_listWebViewController animated:YES];
}

//主页
- (void)home {
    [self.activeWindow loadRequest:[NSURLRequest requestWithURL:HOME_URL]];
}

//收藏
- (void)favorite {
    Favorite *fav = [[Favorite alloc] initWithDictionary:@{@"title" : _activeWindow.title, @"URL" : _activeWindow.URL}];

/*
    //方法一
    BOOL containFav = NO;
    for(Favorite *obj in _favoriteArray){
        if([fav isEqualToFavorite:obj]){
            containFav = YES;
        }
    }

    //方法二
    __block BOOL containFav = NO;
    [_favoriteArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([fav isEqualToFavorite:obj]){
            containFav = YES;
        }
    }];
*/

    //方法三
    BOOL containFav = [_favoriteArray indexesOfObjectsWithOptions:NSEnumerationConcurrent
                                                      passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                                          return [fav isEqualToFavorite:obj];
                                                      }].count > 0;
    if (!containFav) {
        [_favoriteArray addObject:fav];
    } else {
        [MyHelper showToastAlert:NSLocalizedString(@"Has Been Favorited", nil)];
        return;
    }

    //序列化存储
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_favoriteArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:MY_FAVORITES];

    [MyHelper showToastAlert:NSLocalizedString(@"Add Favorite Success", nil)];
}

//设置菜单
- (void)menu {
    AWActionSheet *sheet = [[AWActionSheet alloc] initWithIconSheetDelegate:self ItemCount:[self numberOfItemsInActionSheet]];
    [sheet show];
}

//刷新
- (void)reload:(UIBarButtonItem *)item {
    [self.activeWindow loadRequest:[NSURLRequest requestWithURL:self.activeWindow.URL]];
}

//返回
- (void)back:(UIBarButtonItem *)item {
    [self.activeWindow goBack];
}

//前进
- (void)forward:(UIBarButtonItem *)item {
    [self.activeWindow goForward];
}


/*- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    NSString *text = _searchBar.text;
    if ([text compare:@"http://" options:NSLiteralSearch range:NSMakeRange(0, 7)] != NSOrderedSame) {
        text = [NSString stringWithFormat:@"http://%@", text];
    }
    [_activeWindow loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithString:text]]];
}*/


#pragma mark UISearchBarDelegate Implementation

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    NSString *text = _searchBar.text;
    NSString *urlStr = [NSString stringWithFormat:@"http://www.baidu.com/s?wd=%@", text];

/*
    NSString *urlRegex = @"((http|ftp|https|Http|Https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?";
    NSPredicate *urlStrPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    if ([urlStrPredicate evaluateWithObject:text]) {
        urlStr = [NSString stringWithFormat:@"%@", text];
    }
*/

    if ([text isHttpURL]) {
        urlStr = [NSString stringWithFormat:@"%@", text];
    } else if ([text isDomain]) {
        urlStr = [NSString stringWithFormat:@"http://%@", text];
    }

    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_activeWindow loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark AWActionSheetDelegate Implementation

- (int)numberOfItemsInActionSheet {
    return 4;
}

- (AWActionSheetCell *)cellForActionAtIndex:(NSInteger)index {
    AWActionSheetCell *cell = [[AWActionSheetCell alloc] init];
    cell.index = (int) index;

    switch (index) {
        case 0: {
            cell.titleLabel.text = NSLocalizedString(@"Bookmarks", nil);//@"书签管理";
            [cell.iconView setImage:[UIImage imageNamed:@"bookmark"]];

            break;
        }
        case 1: {
            cell.titleLabel.text = NSLocalizedString(@"Nighttime", nil);//@"夜间模式";
            [cell.iconView setImage:[UIImage imageNamed:@"night"]];
            if(_webmaskLayer && _webmaskLayer.superlayer == _webContainer.layer){
                cell.titleLabel.text = NSLocalizedString(@"Daytime", nil);//@"白天模式";
                [cell.iconView setImage:[UIImage imageNamed:@"day"]];
            }
            break;
        }
        case 2: {
            cell.titleLabel.text = NSLocalizedString(@"No Image", nil);//@"无图模式";
            [cell.iconView setImage:[UIImage imageNamed:@"noimage"]];

            break;
        }
        case 3: {
            cell.titleLabel.text = NSLocalizedString(@"Clear All History", nil);//@"清除痕迹";
            [cell.iconView setImage:[UIImage imageNamed:@"clearAllHistory"]];

            break;
        }
        default: {
            break;
        }
    }

    return cell;
}

- (void)DidTapOnItemAtIndex:(NSInteger)index title:(NSString *)name {
    NSLog(@"tap on %d", (int) index);

    switch (index) {
        case 0: {
            //书签管理
            FavoritesViewController *favoritesViewController = [[FavoritesViewController alloc] init];
            favoritesViewController.getCurrentWebViewBlock = ^(MyWebView **wb) {
                *wb = _activeWindow;
            };
            favoritesViewController.loadRequestBlock = ^(NSURL *url){
                [_activeWindow loadRequest:[NSURLRequest requestWithURL:url]];
            };
            [self.navigationController pushViewController:favoritesViewController animated:YES];

            break;
        }
        case 1: {
            //夜间模式
            if(!_webmaskLayer){
                _webmaskLayer = [CALayer layer];
                _webmaskLayer.frame = _activeWindow.layer.frame;
                _webmaskLayer.backgroundColor = [UIColor blackColor].CGColor;
                _webmaskLayer.opacity = 0.3;
                //移到最顶层
//                _webmaskLayer.zPosition = 1000;

                //给webContain加上一层半透明的遮罩层
                [_webContainer.layer addSublayer:_webmaskLayer];
            }else{
                //去掉遮罩层
                [_webmaskLayer removeFromSuperlayer];
                _webmaskLayer = nil;
            }

            break;
        }
        case 2: {
            //无图模式

            break;
        }
        case 3: {
            //清除痕迹
            [_webContainer.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if([obj isMemberOfClass:[MyWebView class]]){
                    MyWebView *wb = (MyWebView *)obj;
                    [wb.backForwardList performSelector:@selector(_clear)];
                }
            }];
            [MyHelper showToastAlert:NSLocalizedString(@"Successfully cleared Footprint", nil)];
            break;
        }
        default: {
            break;
        }
    }
}


//关闭当前webView
- (void)closeActiveWebView {
    // Grab and remove the top web view, remove its reference from the windows array,
    // and nil itself and its delegate. Then we re-set the activeWindow to the
    // now-top web view and refresh the toolbar.
    if (_activeWindow == _listWebViewController.windows.lastObject) {
        [_activeWindow loadRequest:[NSURLRequest requestWithURL:HOME_URL]];
        return;
    }

    [_activeWindow removeFromSuperview];
    [_listWebViewController.windows removeObject:_activeWindow];
    _activeWindow = _listWebViewController.windows.lastObject;
    [_webContainer bringSubviewToFront:_activeWindow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
