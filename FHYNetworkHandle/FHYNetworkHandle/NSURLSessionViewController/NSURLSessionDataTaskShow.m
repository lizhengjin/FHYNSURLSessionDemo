//
//  NSURLSessionDataTaskShow.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/7.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "NSURLSessionDataTaskShow.h"

@interface NSURLSessionDataTaskShow ()

@end

@implementation NSURLSessionDataTaskShow

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSURLSessionDataTask";
    // Do any additional setup after loading the view.
}
- (IBAction)get:(id)sender {
   //1.创建NSURLSession对象（可以获取单例对象）
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.liwushuo.com/v2/banners?channel=iOS"]];
    //2.根据NSURLSession对象创建一个Task
    /*
     注意：该block是在子线程中调用的，如果拿到数据之后要做一些UI刷新操作，那么需要回到主线程刷新
     第一个参数：需要发送的请求对象
     block:当请求结束拿到服务器响应的数据时调用block
     block-NSData:该请求的响应体
     block-NSURLResponse:存放本次请求的响应信息，响应头，真实类型为NSHTTPURLResponse
     block-NSErroe:请求错误信息
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //拿到响应头信息
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        
        //4.解析拿到的响应数据
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@ \n %@", dic, res.allHeaderFields);
    }];
    //3.执行Task
    //注意：刚创建出来的task默认是挂起状态的，需要调用该方法来启动任务（执行任务
    [dataTask resume];
    
}
- (IBAction)get2:(id)sender {
    //1.创建NSURLSession对象（可以获取单例对象）
    NSURLSession *session = [NSURLSession sharedSession];
    //2.创建一个Task
    //注意：该方法内部默认会把URL对象包装成一个NSURLRequest对象（默认是GET请求）
    //方法参数说明
    /*
     //第一个参数：发送请求的URL地址
     //block:当请求结束拿到服务器响应的数据时调用block
     //block-NSData:该请求的响应体
     //block-NSURLResponse:存放本次请求的响应信息，响应头，真实类型为NSHTTPURLResponse
     //block-NSErroe:请求错误信息
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://api.liwushuo.com/v2/banners?channel=iOS"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //拿到响应头信息
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        
        //4.解析拿到的响应数据
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@ \n %@", dic, res.allHeaderFields);
    }];
    
    [dataTask resume];
}
- (IBAction)post:(id)sender {
    
    //1.创建NSURLSession对象（可以获取单例对象）
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据NSURLSession对象创建一个Task
    
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/login"];
    
    //创建一个请求对象，并这是请求方法为POST，把参数放在请求体中传递
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"username=520it&pwd=520it&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        //拿到响应头信息
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        
        //解析拿到的响应数据
        NSLog(@"%@\n%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],res.allHeaderFields);
    }];
    
    //3.执行Task
    //注意：刚创建出来的task默认是挂起状态的，需要调用该方法来启动任务（执行任务）
    [dataTask resume];
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
