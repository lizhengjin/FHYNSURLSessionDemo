//
//  NSURLSessionUploadTaskShow.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/7.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "NSURLSessionUploadTaskShow.h"

@interface NSURLSessionUploadTaskShow ()<NSURLSessionTaskDelegate>

@end

@implementation NSURLSessionUploadTaskShow

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSURLSessionUploadTask";
    // Do any additional setup after loading the view.
}
- (IBAction)upload:(id)sender {
    NSURLSession *session = [NSURLSession sharedSession];
    
    /*
     第一个参数：请求对象
     第二个参数：请求体（要上传的文件数据）
     block回调：
     NSData:响应体
     NSURLResponse：响应头
     NSError：请求的错误信息
     */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"我没有一个上传的网址TAT"]];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:[NSData data] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    
    [uploadTask resume];

}

/*
 调用该方法上传文件数据
 如果文件数据很大，那么该方法会被调用多次
 参数说明：
 totalBytesSent：已经上传的文件数据的大小
 totalBytesExpectedToSend：文件的总大小
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
       NSLog(@"%.2f",1.0 * totalBytesSent/totalBytesExpectedToSend);
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
