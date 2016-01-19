//
//  FHYNetWork.h
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/6.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIView;
@class SVProgressHUD;
#import "AFNetworking.h"
//设置超时时间
#define kTimeOutInterval 15

typedef void(^successfulBlock)(id responseObject);
typedef void(^failureBlock)(NSError *error);
@interface FHYNetWork : NSObject





//开始监听网络状态
+ (void)startMonitoringNetworkStatus;
//返回网络状态
+ (AFNetworkReachabilityStatus)networkReachabilityStatus;


+ (void)handleGETWithUrlString:(NSString *)urlString parameters:(id)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock;

+ (void)handlePOSTWithUrlString:(NSString *)urlString parameters:(id)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock;




@end
