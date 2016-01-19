//
//  FHYURLSessionHandle.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/9.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "FHYURLSessionHandle.h"
#import "SVProgressHUD.h"
@implementation FHYURLSessionHandle

+ (void)handleGETWithUrlString:(NSString *)urlString parameters:(id)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock{
    if (show) {
        [SVProgressHUD show];
        UIView *placeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, hiddenView.frame.size.width, hiddenView.frame.size.height)];
        [placeView setTag:54321];
        [placeView setBackgroundColor:[UIColor blackColor]];
        [hiddenView addSubview:placeView];
    }
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    [session.configuration setTimeoutIntervalForRequest:kTimeOutInterval];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                successfulBlock(responseObject);
                [SVProgressHUD dismiss];
                [[hiddenView viewWithTag:54321] removeFromSuperview];
            });
        } else{
            failureBlock(error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self badNetWork];
            });
            NSLog(@"网络错误%@",error);
        }
    }];
    [dataTask resume];
}

+ (void)handlePOSTWithUrlString:(NSString *)urlString parameters:(NSString *)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock{
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    if (show) {
        [SVProgressHUD show];
        UIView *placeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, hiddenView.frame.size.width, hiddenView.frame.size.height)];
        [placeView setTag:54321];
        [placeView setBackgroundColor:[UIColor blackColor]];
        [hiddenView addSubview:placeView];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    [session.configuration setTimeoutIntervalForRequest:kTimeOutInterval];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        if (!error) {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                successfulBlock(responseObject);
                [SVProgressHUD dismiss];
                [[hiddenView viewWithTag:54321] removeFromSuperview];
            });
        } else{
            failureBlock(error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self badNetWork];
            });
            NSLog(@"网络错误%@",error);
        }
    }];
    [dataTask resume];
}

+ (void)badNetWork{
    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

- (instancetype)initADownLoadTask{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return self;
}

//- (void)handleDownloadWithUrlString:(NSString *)urlString{
//    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    self.task = _session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//    }
//}






@end
