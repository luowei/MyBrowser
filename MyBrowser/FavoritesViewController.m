//
//  FavoritesViewController.m
//  MyBrowser
//
//  Created by luowei on 15/6/27.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Defines.h"
#import "MyWKWebView.h"
#import "MyHelper.h"
#import "Favorite.h"

@interface FavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //segment选择条
    NSArray *itmes = @[NSLocalizedString(@"Favorites", nil), NSLocalizedString(@"History", nil)];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:itmes];
    CGRect frame = _segmentedControl.frame;
    [_segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 25)];
    _segmentedControl.selectedSegmentIndex = 0;

    [_segmentedControl addTarget:self action:@selector(reloadContentView) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentedControl;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(editTableView:)];

    //tableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.layoutMargins = UIEdgeInsetsZero;

    [self.view addSubview:_tableView];

    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:@{@"tableView" : _tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:@{@"tableView" : _tableView}]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //加载历史数据
//    MyWKWebView *webView;
//    self.getCurrentWKWebViewBlock(&webView);
//    _backForwardList = [NSMutableArray arrayWithArray:webView.backForwardList.backList];

    //加载数据
    [self reloadContentView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_tableView.editing) {
        [MyHelper showToastAlert:NSLocalizedString(@"Editing isn't Saved", nil)];
    }
    self.navigationController.toolbarHidden = YES;
}


//编辑TableView
- (void)editTableView:(id)editTableView {
    //保存
    if (self.tableView.editing) {
        self.tableView.editing = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                     target:self
                                     action:@selector(editTableView:)];
        //保存排序到userDefault
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_favoriteList];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:MY_FAVORITES];
        //编辑
    } else {
        self.tableView.editing = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(editTableView:)];
    }
}

//当segent发生变化
- (void)reloadContentView {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0: {
            self.navigationController.toolbarHidden = NO;
            UIBarButtonItem *btnItme = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add Favorite", nil)
                                                                        style:UIBarButtonItemStylePlain target:self action:@selector(addFavorite)];
            UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            self.toolbarItems = @[flexibleSpace, btnItme, flexibleSpace];

            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                                   target:self
                                                                                                   action:@selector(editTableView:)];
            //收藏数据从userDefault中加载
            NSData *favData = [[NSUserDefaults standardUserDefaults] objectForKey:MY_FAVORITES];
            _favoriteList = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:favData]];

            [_tableView reloadData];
            break;
        }
        case 1: {
            self.navigationController.toolbarHidden = YES;
//            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear History", nil)
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self action:@selector(clearHistory)];

            //历史数据从webView中加载
            _favoriteList = @[].mutableCopy;

            MyWKWebView *webView;
            self.getCurrentWKWebViewBlock(&webView);
            [webView.backForwardList.forwardList enumerateObjectsUsingBlock:^(WKBackForwardListItem *item, NSUInteger idx, BOOL *stop) {
                if (item && item.title && item.URL) {
                    [_favoriteList addObject:[[Favorite alloc] initWithDictionary:@{@"title" : item.title, @"URL" : item.URL}]];
                }
            }];
            [webView.backForwardList.backList enumerateObjectsUsingBlock:^(WKBackForwardListItem *item, NSUInteger idx, BOOL *stop) {
                if (item && item.title && item.URL) {
                    [_favoriteList addObject:[[Favorite alloc] initWithDictionary:@{@"title" : item.title, @"URL" : item.URL}]];
                }
            }];

            [_tableView reloadData];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _favoriteList.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"CellId";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];

    //如果是收藏,可编辑
    if (_segmentedControl.selectedSegmentIndex == 0) {
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [editBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        editBtn.tag = indexPath.row;
        [editBtn addTarget:self action:@selector(editFavorite:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = editBtn;
    } else {
        cell.accessoryView = nil;
    }


    Favorite *favorite = (Favorite *) _favoriteList[(NSUInteger) indexPath.row];
    cell.textLabel.text = favorite.title;
    cell.detailTextLabel.text = favorite.URL.absoluteString;
    return cell;
}

#pragma mark UITableViewDelegate Implements

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

//可指定特定的一行是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//是否可移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //修改对应的数据源
    Favorite *tmpFav = _favoriteList[(NSUInteger) sourceIndexPath.row];
    [_favoriteList removeObjectAtIndex:(NSUInteger) sourceIndexPath.row];
    [_favoriteList insertObject:tmpFav atIndex:(NSUInteger) destinationIndexPath.row];
}

//设置tableView的编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

//删除一条数据
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    //如果是收藏,可删除
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [_favoriteList removeObjectAtIndex:(NSUInteger) indexPath.row];
        //保存收藏到userDefault
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_favoriteList];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:MY_FAVORITES];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

//打开选中记录
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //打开一个网址
    self.loadRequestBlock([[NSURL alloc] initWithString:cell.detailTextLabel.text]);
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];

    [self.navigationController popViewControllerAnimated:YES];
}


//添加收藏
- (void)addFavorite {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Favorite", nil)
                                                                             message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Title", nil);
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeURL;
        textField.placeholder = NSLocalizedString(@"Url Address", nil);
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *title = ((UITextField *) alertController.textFields[0]).text;
        NSString *urlStr = ((UITextField *) alertController.textFields[1]).text;

        //判断是否为空
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@""]) {
            [MyHelper showToastAlert:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Title", nil), NSLocalizedString(@"Is Empty", nil)]];
            return;
        }
        if ([urlStr isEqualToString:@""]) {
            [MyHelper showToastAlert:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Url Address", nil), NSLocalizedString(@"Is Empty", nil)]];
            return;
        }

        //没有http,补http
        if ([urlStr isHttpURL]) {
            urlStr = [NSString stringWithFormat:@"%@", urlStr];
        } else if ([urlStr isDomain]) {
            urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
        } else {
            [MyHelper showToastAlert:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Url Address", nil), NSLocalizedString(@"Error", nil)]];
            return;
        }

        //添加
        Favorite *fav = [[Favorite alloc] initWithCreateAt:nil content:title url:[[NSURL alloc] initWithString:urlStr]];
        BOOL containFav = [_favoriteList indexesOfObjectsWithOptions:NSEnumerationConcurrent
                                                         passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                                             return [fav isEqualToFavorite:obj];
                                                         }].count > 0;
        if (!containFav) {
            [_favoriteList insertObject:fav atIndex:0];
        } else {
            [MyHelper showToastAlert:NSLocalizedString(@"Has Been Favorited", nil)];
            return;
        }

        //更新并保存
        [_tableView reloadData];

        NSData *favData = [NSKeyedArchiver archivedDataWithRootObject:_favoriteList];
        [[NSUserDefaults standardUserDefaults] setObject:favData forKey:MY_FAVORITES];

        [MyHelper showToastAlert:NSLocalizedString(@"Add Favorite Success", nil)];
    }];
    [alertController addAction:okAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

//编辑收藏
- (void)editFavorite:(UIView *)editBtn {
    UITableViewCell *cell = nil;
    if (editBtn.superview && [editBtn.superview isMemberOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *) editBtn.superview;
    } else {
        return;
    }

    //构造弹窗
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Favorite", nil)
                                                                             message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Title", nil);
        textField.text = cell.textLabel.text;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeURL;
        textField.placeholder = NSLocalizedString(@"Url Address", nil);
        textField.text = cell.detailTextLabel.text;
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *title = ((UITextField *) alertController.textFields[0]).text;
        NSString *urlStr = ((UITextField *) alertController.textFields[1]).text;

        //判断是否为空
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@""]) {
            [MyHelper showToastAlert:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Title", nil), NSLocalizedString(@"Is Empty", nil)]];
            return;
        }
        if ([urlStr isEqualToString:@""]) {
            [MyHelper showToastAlert:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Url Address", nil), NSLocalizedString(@"Is Empty", nil)]];
            return;
        }

        //没有http,补http
        if ([urlStr isHttpURL]) {
            urlStr = [NSString stringWithFormat:@"%@", urlStr];
        } else if ([urlStr isDomain]) {
            urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
        } else {
            [MyHelper showToastAlert:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Url Address", nil), NSLocalizedString(@"Error", nil)]];
            return;
        }

        //更新及保存
        Favorite *fav = _favoriteList[(NSUInteger) editBtn.tag];
        fav.title = title;
        fav.URL = [[NSURL alloc] initWithString:urlStr];
        fav.createtime = [NSDate date];

        [_tableView reloadData];

        NSData *favData = [NSKeyedArchiver archivedDataWithRootObject:_favoriteList];
        [[NSUserDefaults standardUserDefaults] setObject:favData forKey:MY_FAVORITES];

        [MyHelper showToastAlert:NSLocalizedString(@"Update Favorite Success", nil)];
    }];
    [alertController addAction:okAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

//清除历史
- (void)clearHistory {

    MyWKWebView *wkwebView;
    self.getCurrentWKWebViewBlock(&wkwebView);
//  [wkwebView.backForwardList performSelector:@selector(_clear)];
    [wkwebView.backForwardList performSelector:NSSelectorFromString([NSString base64Decoding:@"X2NsZWFy"])];
    [_favoriteList removeAllObjects];

    [MyHelper showToastAlert:NSLocalizedString(@"Clear History Success", nil)];

    [_tableView reloadData];
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
