//
//  MyPopupView.m
//  MyBrowser
//
//  Created by luowei on 15/6/29.
//  Copyright (c) 2015 wodedata. All rights reserved.
//

#import "MyPopupView.h"

@interface MyPopupView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *dataList;
@property(nonatomic, strong) NSDictionary *imgDic;

@end

@implementation MyCollectionView

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize])) {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize {
    CGSize intrinsicContentSize = self.contentSize;

    return intrinsicContentSize;
}


@end

@implementation MyCollectionViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 20, self.frame.size.width - 20, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:_titleLabel];

        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
        _imgView.center = CGPointMake(self.center.x, (self.frame.size.height - 20) / 2);
        [self.contentView addSubview:_imgView];
    }

    return self;
}


@end


@implementation MyCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup {
    self.itemSize = CGSizeMake(80.0f, 80.0f);
    self.minimumLineSpacing = 10;
    self.sectionInset = UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 7.5f);
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
}

- (CGSize)collectionViewContentSize {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = (NSInteger) ceil(itemCount / 80.0);

    return CGSizeMake(self.collectionView.frame.size.width * pages, self.collectionView.frame.size.height);

//    return CGSizeMake(CGRectGetWidth(self.collectionView.frame) *
//                    [self.collectionView numberOfSections],
//            CGRectGetHeight(self.collectionView.frame));
}


@end


@implementation MyPopupView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];

        _dataList = array;
        _imgDic = @{NSLocalizedString(@"Bookmarks", nil) : @"bookmark", NSLocalizedString(@"Nighttime", nil) : @"night", NSLocalizedString(@"Daytime", nil) : @"day",
                NSLocalizedString(@"No Image", nil) : @"noimage", NSLocalizedString(@"Clear All History", nil) : @"clearAllHistory"};

        MyCollectionViewFlowLayout *flowLayout = [[MyCollectionViewFlowLayout alloc] init];
        _collectionView = [[MyCollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];

        _collectionView.backgroundColor = [UIColor blueColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];

        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[collectionView]-10-|" options:0 metrics:nil views:@{@"collectionView" : _collectionView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[collectionView]-5-|" options:0 metrics:nil views:@{@"collectionView" : _collectionView}]];

    }

    return self;
}

#pragma mark UICollectionViewDataSource Implementation

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //dequeue cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *title = _dataList[(NSUInteger) indexPath.row];


//    cell.titleLabel.text = title;
//    [cell.titleLabel sizeToFit];
//    CGSize labelSize = cell.titleLabel.frame.size;
//    cell.titleLabel.frame = CGRectMake(cell.contentView.frame.size.height - labelSize.height - 2, (cell.contentView.frame.size.width - labelSize.width) / 2,
//            labelSize.width, labelSize.height);
//
//    cell.imgView.image = _imgDic[_dataList[(NSUInteger) indexPath.row]];
//    [cell.contentView addSubview:cell.imgView];

    [self invalidateIntrinsicContentSize];
    cell.backgroundColor = [UIColor redColor];
    return cell;
}


#pragma mark UICollectionViewDelegate Implementation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath; {
    if ([self.delegate respondsToSelector:@selector(itemTaped:)]) {
        MyCollectionViewCell *cell = (MyCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self.delegate itemTaped:cell];
    }
}


#pragma mark UICollectionViewDelegateFlowLayout Implementation

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
