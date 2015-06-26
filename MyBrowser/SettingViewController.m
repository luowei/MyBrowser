//
//  SettingViewController.m
//  Webkit-Demo
//
//  Created by luowei on 15/6/24.
//  Copyright (c) 2015 rootls. All rights reserved.
//

#import "SettingViewController.h"


@interface SettingViewController()<UITableViewDataSource,UITableViewDelegate>


@end


@implementation SettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    [self.view addSubview:self.tableView];
}

//设置
- (void)setting {
    
}

//添加一个webView
- (void)addWebView {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark UITableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
