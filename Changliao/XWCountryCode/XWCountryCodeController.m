//
//  XWCountryCodeController.m
//  XWCountryCodeDemo
//
//  Created by 邱学伟 on 16/4/19.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

#import "XWCountryCodeController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "Public.h"

//判断系统语言
#define CURR_LANG ([[NSLocale preferredLanguages] objectAtIndex:0])
#define LanguageIsEnglish ([CURR_LANG isEqualToString:@"en-US"] || [CURR_LANG isEqualToString:@"en-CA"] || [CURR_LANG isEqualToString:@"en-GB"] || [CURR_LANG isEqualToString:@"en-CN"] || [CURR_LANG isEqualToString:@"en"])

@interface XWCountryCodeController () <UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate> {
    UITableView *_tableView;
    UISearchController *_searchController;
    NSDictionary *_sortedNameDict;
    NSArray *_indexArray;
    NSMutableArray *_results;
}
@end

@implementation XWCountryCodeController

#pragma mark - system
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = @"国家代码";
    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    
    navTitleLabel.backgroundColor = [UIColor clearColor];
    
    navTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    navTitleLabel.textColor = kColorFromRGBHex(0x171717);
    
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    navTitleLabel.text = @"国家代码";
    
    self.navigationItem.titleView = navTitleLabel;
    self.navigationController.navigationBar.tintColor =kColorFromRGBHex(0x171717);
    if (self.navigationController) {
        [self.navigationController.navigationBar setHidden:NO];
    }
    [self creatSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - private
 //创建子视图
- (void)creatSubviews{
    _results = [NSMutableArray arrayWithCapacity:1];
    
    _tableView = [[UITableView alloc] initWithFrame:/*CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)*/self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44.0;
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _tableView.contentInsetAdjustmentBehavior = NO;
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.delegate = self;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.barTintColor = self.navigationController.navigationBar.tintColor;
//    _searchController.fd_interactivePopDisabled = YES;
    if (@available(iOS 11, *)){
        
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
            self.navigationItem.searchController = _searchController;
        }else {
            _tableView.tableHeaderView = _searchController.searchBar;
    }
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, _searchController.searchBar.bounds.size.height)];
//    [headerView addSubview:_searchController.searchBar];
//    _tableView.tableHeaderView = headerView;
    
    //判断当前系统语言
    if (LanguageIsEnglish) {
        NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedNameEN" ofType:@"plist"];
        _sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathEN];
    } else {
        NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
        _sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
    }
    
    _indexArray = [[NSArray alloc] initWithArray:[[_sortedNameDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }]];
}

- (NSString *)showCodeStringIndex:(NSIndexPath *)indexPath {
    NSString *showCodeSting;
    if (_searchController.isActive) {
        if (_results.count > indexPath.row) {
            showCodeSting = [_results objectAtIndex:indexPath.row];
        }
    } else {
        if (_indexArray.count > indexPath.section) {
            NSArray *sectionArray = [_sortedNameDict valueForKey:[_indexArray objectAtIndex:indexPath.section]];
            if (sectionArray.count > indexPath.row) {
                showCodeSting = [sectionArray objectAtIndex:indexPath.row];
            }
        }
    }
    return showCodeSting;
}

- (void)selectCodeIndex:(NSIndexPath *)indexPath {
    
    NSString * originText = [self showCodeStringIndex:indexPath];
    NSArray  * array = [originText componentsSeparatedByString:@"+"];
    NSString * countryName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * code = array.lastObject;
    
    if (self.deleagete && [self.deleagete respondsToSelector:@selector(returnCountryName:code:)]) {
        [self.deleagete returnCountryName:countryName code:code];
    }
    
    if (self.returnCountryCodeBlock != nil) {
        self.returnCountryCodeBlock(countryName,code);
    }
    
    
    if (self.navigationController) {
        if (_searchController.active) {
            _searchController.active = NO;
            [_searchController.searchBar resignFirstResponder];
            [_searchController dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
//            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    NSLog(@"选择国家: %@   代码: %@",countryName,code);
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (_results.count > 0) {
        [_results removeAllObjects];
    }
    NSString *inputText = searchController.searchBar.text;
    __weak __typeof(self)weakSelf = self;
    [_sortedNameDict.allValues enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:inputText]) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf->_results addObject:obj];
            }
        }];
    }];
    [_tableView reloadData];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
//    searchController.fd_interactivePopDisabled = YES;
//    self.navigationItem.searchController = _searchController;
//    _tableView.frame = self.view.bounds;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
//    self.navigationItem.searchController = nil;
//    _tableView.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20);
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, _searchController.searchBar.bounds.size.height)];
//    [headerView addSubview:_searchController.searchBar];
//    _tableView.tableHeaderView = headerView;
    self.navigationController.navigationBar.tintColor = searchController.searchBar.barTintColor;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchController.isActive) {
        return 1;
    } else {
        return [_sortedNameDict allKeys].count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.isActive) {
         return [_results count];
    } else {
        if (_indexArray.count > section) {
            NSArray *array = [_sortedNameDict objectForKey:[_indexArray objectAtIndex:section]];
            return array.count;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self showCodeStringIndex:indexPath];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        return _indexArray;
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == _tableView) {
        return index;
    } else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        if (section == 0) {
            return 0;
        }
        return 30;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_indexArray.count && _indexArray.count > section) {
        return [_indexArray objectAtIndex:section];
    }
    return nil;
}

#pragma mark - 选择国际获取代码
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCodeIndex:indexPath];
}

@end
