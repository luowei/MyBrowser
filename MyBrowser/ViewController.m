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

@interface ViewController ()<UISearchBarDelegate, AWActionSheetDelegate>


//@property(nonatomic, strong) UITextField *urlField;
@property(strong, nonatomic) UISearchBar *searchBar;
@property(nonatomic, strong) UIToolbar *bottomToolbar;
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
    _searchBar.placeholder = NSLocalizedString(@"KeyWord or Url", nil);//@"搜索或输入地址";
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
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 40)];
    self.bottomToolbar.backgroundColor = [UIColor whiteColor];
    self.backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.forwardBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(forward:)];

    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    fixedSpace.width = 20;


    self.bottomToolbar.items = @[self.homeBtn, fixedSpace, self.favoriteBtn, fixedSpace, self.menuBtn, fixedSpace, self.reloadBtn, flexibleSpace, self.backBtn, fixedSpace, self.forwardBtn];
    [self.view addSubview:self.bottomToolbar];
    [self.view bringSubviewToFront:self.bottomToolbar];

    //底部工具栏
    self.bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bottomToolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"bottomToolbar" : self.bottomToolbar}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomToolbar(40)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"bottomToolbar" : self.bottomToolbar}]];
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
    _activeWindow.addWebViewBlock = ^(MyWebView **wb, NSURL *aurl){
        if(*wb){
            *wb = [weakSelf addWebView:aurl];
        }else{
            [weakSelf addWebView:aurl];
        }
    };

    //presentViewController block
    _activeWindow.presentViewControllerBlock = ^(UIViewController *viewController){
        [weakSelf presentViewController:viewController animated:YES completion:nil];
    };

    //关闭激活的webView的block
    _activeWindow.closeActiveWebViewBlock = ^(){
        [weakSelf closeActiveWebView];
    };

    // Add to windows array and make active window
    if (!_listWebViewController) {
        _listWebViewController = [[ListWebViewController alloc] initWithWebView:_activeWindow];

        //设置添加webView的block
        _listWebViewController.addWebViewBlock = ^(MyWebView **wb, NSURL *aurl) {
            if(*wb){
                *wb = [weakSelf addWebView:aurl];
            }else{
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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar.backItem setHidesBackButton:YES];

}

- (void)viewWillAppear:(BOOL)animated {

    [_activeWindow reload];
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
    [self presentViewController:_listWebViewController animated:YES completion:nil];
}

//主页
- (void)home {
    [self.activeWindow loadRequest:[NSURLRequest requestWithURL:HOME_URL]];
}

//收藏
- (void)favorite {

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
    NSString *urlRegex = @"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?";
    NSPredicate *urlStrPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];

    NSString *urlStr = [NSString stringWithFormat:@"http://www.baidu.com/s?wd=%@", text];
    if ([urlStrPredicate evaluateWithObject:text]) {
        urlStr = [NSString stringWithFormat:@"%@", text];
    }

    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_activeWindow loadRequest:[NSURLRequest requestWithURL:url]];
}


#pragma mark AWActionSheetDelegate Implementation

- (int)numberOfItemsInActionSheet {
    return 3;
}

- (AWActionSheetCell *)cellForActionAtIndex:(NSInteger)index {
    AWActionSheetCell *cell = [[AWActionSheetCell alloc] init];
    cell.index = (int) index;

    switch (index){
        case 0:{
            cell.titleLabel.text = NSLocalizedString(@"Bookmarks", nil);//@"书签管理";
            [cell.iconView setImage:[UIImage imageNamed:@"bookmark"]];

            break;
        }
        case 1:{
            cell.titleLabel.text = NSLocalizedString(@"Nighttime", nil);//@"夜间模式";
            [cell.iconView setImage:[UIImage imageNamed:@"night"]];

            break;
        }
        case 2:{
            cell.titleLabel.text = NSLocalizedString(@"No Image", nil);//@"无图模式";
            [cell.iconView setImage:[UIImage imageNamed:@"noimage"]];

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
}


//关闭当前webView
- (void)closeActiveWebView {
    // Grab and remove the top web view, remove its reference from the windows array,
    // and nil itself and its delegate. Then we re-set the activeWindow to the
    // now-top web view and refresh the toolbar.
    if(_activeWindow == _listWebViewController.windows.lastObject){
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
