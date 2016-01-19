//
//  FHYNetWork.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/6.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "FHYNetWork.h"
#import "SVProgressHUD.h"

@implementation FHYNetWork

+ (void)handleGETWithUrlString:(NSString *)urlString parameters:(id)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock{
    NSURL *url = [NSURL URLWithString:urlString];
    if (show) {
        [SVProgressHUD show];
        UIView *placeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, hiddenView.frame.size.width, hiddenView.frame.size.height)];
        [placeView setTag:54321];
        [placeView setBackgroundColor:[UIColor blackColor]];
        [hiddenView addSubview:placeView];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:kTimeOutInterval];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager GET:url.absoluteString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        successfulBlock(responseObject);
        [SVProgressHUD dismiss];
        [[hiddenView viewWithTag:54321] removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
        [self badNetWork];
        NSLog(@"网络错误%@",error);
    }];
}

+ (void)handlePOSTWithUrlString:(NSString *)urlString parameters:(id)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock{
    NSURL *url = [NSURL URLWithString:urlString];
    if (show) {
        [SVProgressHUD show];
        UIView *placeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, hiddenView.frame.size.width, hiddenView.frame.size.height)];
        [placeView setTag:54321];
        [placeView setBackgroundColor:[UIColor blackColor]];
        [hiddenView addSubview:placeView];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:kTimeOutInterval];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST:url.absoluteString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        successfulBlock(responseObject);
        [SVProgressHUD dismiss];
        [[hiddenView viewWithTag:54321] removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
        [self badNetWork];
        NSLog(@"网络错误%@",error);
    }];
}

+ (void)badNetWork{
    if ([[self class] networkReachabilityStatus] != -1) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
    }
}
+ (void)startMonitoringNetworkStatus{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch ((NSInteger)status) {
            case AFNetworkReachabilityStatusNotReachable:{
                NSLog(@"网络连接中断");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                NSLog(@"当前WiFi网络");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                NSLog(@"当前3G网络");
                break;
            }
        }
    }];
}
//返回网络状态
+ (AFNetworkReachabilityStatus)networkReachabilityStatus{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}
@end
