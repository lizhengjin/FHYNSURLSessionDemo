//
//  FHYURLSessionHandle.h
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/9.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIView;
//设置超时时间
#define kTimeOutInterval 15

typedef void(^successfulBlock)(id responseObject);
typedef void(^failureBlock)(NSError *error);
@interface FHYURLSessionHandle : NSObject<NSURLSessionDownloadDelegate>
//下载用Session对象
@property (nonatomic, strong) NSURLSession *session;
//下载用Task对象
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
//下载用数据存储
@property (nonatomic, strong) NSData *partialData;

//GET请求
+ (void)handleGETWithUrlString:(NSString *)urlString parameters:(id)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock;
//POST请求
+ (void)handlePOSTWithUrlString:(NSString *)urlString parameters:(NSString *)parameters showHuD:(BOOL)show onView:(UIView *)hiddenView successfulBlock:(successfulBlock)successfulBlock failureBlock:(failureBlock)failureBlock;
//下载对象初始化
- (instancetype)initADownLoadTask;
//下载对象处理任务
- (void)handleDownloadWithUrlString:(NSString *)urlString;


@end
