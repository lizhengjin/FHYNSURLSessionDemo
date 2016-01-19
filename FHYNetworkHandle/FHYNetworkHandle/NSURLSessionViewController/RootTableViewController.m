//
//  RootTableViewController.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/6.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "RootTableViewController.h"
#import "AFNetworking.h"
#import "NSURLSessionDataTaskShow.h"
#import "NSURLSessionDownloadTaskShow.h"
#import "NSURLSessionUploadTaskShow.h"
#import "FHYURLSessionHandleViewController.h"
@interface RootTableViewController ()
@property (nonatomic, strong)NSArray *cellTitles;
@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSURLSession网络连接DEMO";
    self.cellTitles = @[@"NSURLSessionDataTask",@"NSURLSessionDownloadTask",@"NSURLSessionNSURLSessionUploadTask",@"FHYURLSessionHandle"];
    [self startMonitoringNetStatus];
}
//检测网络状态
- (void)startMonitoringNetStatus{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch ((NSInteger)status) {
            case AFNetworkReachabilityStatusNotReachable:{
                self.title = @"网络连接中断";
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                self.title = @"当前WiFi网络";
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                self.title = @"当前3G网络";
                break;
            }
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellTitles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    [cell.textLabel setText:_cellTitles[indexPath.row]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        NSURLSessionDownloadTaskShow *downloadTaskShow = [self.storyboard instantiateViewControllerWithIdentifier:@"NSURLSessionDownloadTaskShow"];
        [self.navigationController pushViewController:downloadTaskShow animated:YES];
    } else if (indexPath.row == 0) {
        NSURLSessionDataTaskShow *dataTaskShow = [self.storyboard instantiateViewControllerWithIdentifier:@"NSURLSessionDataTaskShow"];
        [self.navigationController pushViewController:dataTaskShow animated:YES];
    } else if (indexPath.row == 2){
        NSURLSessionUploadTaskShow *uploadTaskShow = [self.storyboard instantiateViewControllerWithIdentifier:@"NSURLSessionUploadTaskShow"];
        [self.navigationController pushViewController:uploadTaskShow animated:YES];
    } else{
        FHYURLSessionHandleViewController *fhyUrlViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FHYURLSessionHandleViewController"];
        [self.navigationController pushViewController:fhyUrlViewController animated:YES];
    }
}



@end
