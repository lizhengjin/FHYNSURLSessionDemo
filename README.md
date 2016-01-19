# FHYNSURLSessionDemo
About how to use NSURLSession to replace NSURLConnection.

在苹果彻底弃用NSURLConnection之后自己总结的一个网上的内容，加上自己写的小Demo，很多都是借鉴网络上的资源，有需要的朋友可以看看。
排版之前也是乱弄的（因为之前就自己看么囧）
可以看Demo下的pdf

一.引言:

由于Xcode 7中，NSURLConnection的API已经正式被苹果弃用。虽然该API将继续运行，但将没有新功能将被添加，并且苹果已经通知所有基于网络的功能，以充分使NSURLSession向前发展。

二.快速了解与改变AFNetworking篇:

AFNetworking是一款在OS X和iOS下都令人喜爱的网络库,为了迎合iOS新版本的升级, AFNetworking在3.0版本中删除了基于 NSURLConnection API的所有支持。如果你的项目以前使用过这些API，建议您立即升级到基于 NSURLSession 的API的AFNetworking的版本。

AFNetworking 1.0建立在NSURLConnection的基础API之上 ，AFNetworking 2.0开始使用NSURLConnection的基础API ，以及较新基于NSURLSession的API的选项。 AFNetworking 3.0现已完全基于NSURLSession的API，这降低了维护的负担，同时支持苹果增强关于NSURLSession提供的任何额外功能。

1.弃用的类

下面的类已从AFNetworking 3.0中废弃：

- AFURLConnectionOperation
- AFHTTPRequestOperation
- AFHTTPRequestOperationManager

2.让我们看一下原来封装的简单网络处理类

//创建一个HTTP请求操作管理对象
AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//通过设置responseSerializer，自动完成返回数据的解析，直接获取json格式的responseObject。
manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];

//允许无效的 SSL 证书:
//NSURLConnection已经封装了https连接的建立、数据的加密解密功能，我们直接使用NSURLConnection是可以访问https网站的，但NSURLConnection并没有验证证书是否合法，无法避免中间人攻击。要做到真正安全通讯，需要我们手动去验证服务端返回的证书，AFSecurityPolicy封装了证书验证的过程，让用户可以轻易使用，除了去系统信任CA机构列表验证，还支持SSL Pinning方式的验证。
manager.securityPolicy.allowInvalidCertificates = YES;//生产环境不建议使用

[manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
NSLog(@"%@",responseObject);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
NSLog(@"%@",error);
}];

3.AFHTTPRequestOperationManager 核心代码

如果你以前使用 AFHTTPRequestOperationManager ， 你将需要迁移去使用AFHTTPSessionManager。 以下的类在两者过渡间并没有变化：

- securityPolicy        安全政策
- requestSerializer   请求串行器
- responseSerializer 响应串行器

AFNetworking 2.x

AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
[manager GET:@"请求的url" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
NSLog(@"成功");
} failure:^(AFHTTPRequestOperation *operation, NSError*error) {
NSLog(@"失败");
}];

AFNetworking 3.0
AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
[session GET:@"请求的url" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
NSLog(@"成功");
} failure:^(NSURLSessionDataTask *task, NSError *error) {
NSLog(@"失败");
}];

三.基本了解NSURLSession

- 1.了解Apple 的网络连接API

- NSURLConnection 作为 Core Foundation / CFNetwork 框架的 API 之上的一个抽象，在 2003 年，随着第一版的 Safari 的发布就发布了。NSURLConnection 这个名字，实际上是指代的 Foundation 框架的 URL 加载系统中一系列有关联的组件：NSURLRequest、NSURLResponse、NSURLProtocol、 NSURLCache、NSHTTPCookieStorage、NSURLCredentialStorage 以及同名类 NSURLConnection。

- NSURLRequest 被传递给 NSURLConnection。被委托对象（遵守以前的非正式协议 <NSURLConnectionDelegate> 和<NSURLConnectionDataDelegate>）异步地返回一个 NSURLResponse 以及包含服务器返回信息的 NSData。

- NSURLConnection 作为网络基础架构，已经服务了成千上万的 iOS 和 Mac OS 程序，并且做的还算相当不错。但是这些年，一些用例——尤其是在 iPhone 和 iPad 上面——已经对 NSURLConnection 的几个核心概念提出了挑战，让苹果有理由对它进行重构。

- 在 2013 的 WWDC 上，苹果推出了 NSURLConnection 的继任者：NSURLSession。

- 和 NSURLConnection 一样，NSURLSession 指的也不仅是同名类 NSURLSession，还包括一系列相互关联的类。NSURLSession 包括了与之前相同的组件，NSURLRequest 与 NSURLCache，但是把 NSURLConnection 替换成了NSURLSession、NSURLSessionConfiguration 以及 NSURLSessionTask 的 3 个子类：NSURLSessionDataTask，NSURLSessionUploadTask，NSURLSessionDownloadTask。

- 与 NSURLConnection 相比，NSURLsession 最直接的改进就是可以配置每个 session 的缓存，协议，cookie，以及证书策略（credential policy），甚至跨程序共享这些信息。这将允许程序和网络基础框架之间相互独立，不会发生干扰。每个NSURLSession 对象都由一个 NSURLSessionConfiguration 对象来进行初始化，后者指定了刚才提到的那些策略以及一些用来增强移动设备上性能的新选项。

- NSURLSession 中另一大块就是 session task。它负责处理数据的加载以及文件和数据在客户端与服务端之间的上传和下载。NSURLSessionTask 与 NSURLConnection 最大的相似之处在于它也负责数据的加载，最大的不同之处在于所有的 task 共享其创造者 NSURLSession 这一公共委托者（common delegate）。

NSURLSessionTask

NSURLsessionTask 是一个抽象类，其下有 3 个实体子类可以直接使用：NSURLSessionDataTask、NSURLSessionUploadTask、NSURLSessionDownloadTask。这 3 个子类封装了现代程序三个最基本的网络任务：获取数据，比如 JSON 或者 XML，上传文件和下载文件。

当一个 NSURLSessionDataTask 完成时，它会带有相关联的数据，而一个 NSURLSessionDownloadTask 任务结束时，它会带回已下载文件的一个临时的文件路径。因为一般来说，服务端对于一个上传任务的响应也会有相关数据返回，所以NSURLSessionUploadTask 继承自 NSURLSessionDataTask。

所有的 task 都是可以取消，暂停或者恢复的。当一个 download task 取消时，可以通过选项来创建一个恢复数据（resume data），然后可以传递给下一次新创建的 download task，以便继续之前的下载。

1⃣️NSURLSessionDataTask

2.GET请求

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

3.第二种GET请求

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

4.POST请求

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

2⃣️NSURLSessionDownloadTask

1.使用NSURLSession和NSURLSessionDownload可以很方便的实现文件下载操作

//
//  NSURLSessionNetWork.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/7.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "NSURLSessionDownloadTaskShow.h"

@interface NSURLSessionDownloadTaskShow ()<NSURLSessionDownloadDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *start;
@property (strong, nonatomic) IBOutlet UIButton *pause;
@property (strong, nonatomic) IBOutlet UIButton *resume;
@property (atomic, strong) NSURLSessionDownloadTask *task;
@property (atomic, strong) NSData *partialData;

@end

@implementation NSURLSessionDownloadTaskShow

- (void)viewDidLoad {
[super viewDidLoad];
self.title = @"NSURLSessionDownloadTask";
}

//创建Session对象
- (NSURLSession *)createASession{
//创建NSURLSession配置对象Configuration
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//创建NSURLSession,并设置代理
/*
第一个参数：session对象的全局配置设置，一般使用默认配置就可以
第二个参数：谁成为session对象的代理
第三个参数：代理方法在哪个队列中执行（在哪个线程中调用）,如果是主队列那么在主线程中执行，如果是非主队列，那么在子线程中执行
*/
NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
return session;
}
//创建Session请求
- (NSURLRequest *)createARequest{
//注意：如果要发送POST请求，那么请设置一些请求头信息
NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://p1.pichost.me/i/40/1639665.png"]];
return request;
}
//开始下载
- (IBAction)start:(id)sender {
//用NSURLSession和NSURLRequest创建网络任务

self.task = [[self createASession] downloadTaskWithRequest:[self createARequest]];
[self.task resume];
}
//暂停下载
- (IBAction)pause:(id)sender {
NSLog(@"Pause download task");
if (self.task) {
//取消下载任务，把已下载数据存起来
//如果采取这种方式来取消任务，那么该方法会通过resumeData保存当前文件的下载信息
//只要有了这份信息，以后就可以通过这些信息来恢复下载
[self.task cancelByProducingResumeData:^(NSData *resumeData) {
self.partialData = resumeData;
self.task = nil;
}];
}
}
//继续开始
- (IBAction)resume:(id)sender {
NSLog(@"resume download task");
if (!self.task) {
//判断是否又已下载数据，有的话就断点续传，没有就完全重新下载
if (self.partialData) {
//继续下载
//首先通过之前保存的resumeData信息，创建一个下载任务
self.task = [[self createASession] downloadTaskWithResumeData:self.partialData];
}else{
self.task = [[self createASession] downloadTaskWithRequest:[self createARequest]];
}
}
[self.task resume];

}
#pragma mark NSURLSessionDownloadDelegate

//完成下载任务  保存
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
//下载成功后，文件是保存在一个临时目录的，需要开发者自己考到放置该文件的目录
NSLog(@"Download success for URL: %@",location.description);
NSURL *destination = [self createDirectoryForDownloadItemFromURL:location];
BOOL success = [self copyTempFileAtURL:location toDestination:destination];

if(success){
//        文件保存成功后，使用GCD调用主线程把图片文件显示在UIImageView中
dispatch_async(dispatch_get_main_queue(), ^{
UIImage *image = [UIImage imageWithContentsOfFile:[destination path]];
self.imageView.image = image;
self.imageView.contentMode = UIViewContentModeScaleAspectFit;
self.imageView.hidden = NO;
});
}else{
NSLog(@"Meet error when copy file");
}
self.task = nil;
}

//返回下载进度代理方法
/*
当接收到下载数据的时候调用,可以在该方法中监听文件下载的进度
该方法会被调用多次
totalBytesWritten:已经写入到文件中的数据大小
totalBytesExpectedToWrite:目前文件的总大小
bytesWritten:本次下载的文件数据大小
*/
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//刷新进度条的delegate方法，同样的，获取数据，调用主线程刷新UI
double currentProgress = totalBytesWritten/(double)totalBytesExpectedToWrite;
dispatch_async(dispatch_get_main_queue(), ^{
self.progressBar.progress = currentProgress;
self.progressBar.hidden = NO;
});
}

//创建文件本地保存目录
-(NSURL *)createDirectoryForDownloadItemFromURL:(NSURL *)location
{
NSFileManager *fileManager = [NSFileManager defaultManager];
NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
NSURL *documentsDirectory = urls[0];
return [documentsDirectory URLByAppendingPathComponent:[location lastPathComponent]];
}
//把文件拷贝到指定路径
-(BOOL) copyTempFileAtURL:(NSURL *)location toDestination:(NSURL *)destination
{

NSError *error;
NSFileManager *fileManager = [NSFileManager defaultManager];
[fileManager removeItemAtURL:destination error:NULL];
[fileManager copyItemAtURL:location toURL:destination error:&error];
if (error == nil) {
return true;
}else{
NSLog(@"%@",error);
return false;
}
}
- (void)didReceiveMemoryWarning {
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}

@end

2.downloadTaskWithURL内部默认已经实现了变下载边写入操作，所以不用开发人员担心内存问题
3.文件下载后默认保存在tmp文件目录，需要开发人员手动的剪切到合适的沙盒目录

3⃣️NSURLSessionDownloadTask实现大文件离线断点下载（完整）

- 1.关于NSOutputStream的使用


//1. 创建一个输入流,数据追加到文件的屁股上
//把数据写入到指定的文件地址，如果当前文件不存在，则会自动创建
NSOutputStream *stream = [[NSOutputStream alloc]initWithURL:[NSURL fileURLWithPath:[self fullPath]] append:YES];

//2. 打开流
[stream open];

//3. 写入流数据
[stream write:data.bytes maxLength:data.length];

//4.当不需要的时候应该关闭流
[stream close];





2.关于网络请求请求头的设置（可以设置请求下载文件的某一部分）

//1. 设置请求对象
//1.1 创建请求路径
NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];

//1.2 创建可变请求对象
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

//1.3 拿到当前文件的残留数据大小
self.currentContentLength = [self FileSize];

//1.4 告诉服务器从哪个地方开始下载文件数据
NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentContentLength];
NSLog(@"%@",range);

//1.5 设置请求
[request setValue:range forHTTPHeaderField:@"Range"];

3.NSURLSession对象的释放


-(void)dealloc
{
//在最后的时候应该把session释放，以免造成内存泄露
//    NSURLSession设置过代理后，需要在最后（比如控制器销毁的时候）调用session的invalidateAndCancel或者resetWithCompletionHandler，才不会有内存泄露
//    [self.session invalidateAndCancel];
[self.session resetWithCompletionHandler:^{

NSLog(@"释放---");
}];
}





4⃣️NSURLSession实现文件上传

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

关于NSURLSessionConfiguration相关


01 作用：可以统一配置NSURLSession,如请求超时等
02 创建的方式和使用





//创建配置的三种方式
+ (NSURLSessionConfiguration *)defaultSessionConfiguration;
+ (NSURLSessionConfiguration *)ephemeralSessionConfiguration;
+ (NSURLSessionConfiguration *)backgroundSessionConfigurationWithIdentifier:(NSString *)identifier NS_AVAILABLE(10_10, 8_0);

//统一配置NSURLSession
-(NSURLSession *)session
{
if (_session == nil) {

//创建NSURLSessionConfiguration
NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

//设置请求超时为10秒钟
config.timeoutIntervalForRequest = 10;

//在蜂窝网络情况下是否继续请求（上传或下载）
config.allowsCellularAccess = NO;

_session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}
return _session;
}

四.使用AFNetworking来实现NSURLSession网络连接

//
//  AFNViewController.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/7.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "AFNViewController.h"
#import "FHYNetWork.h"
@interface AFNViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) AFURLSessionManager *manager;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *partialData;
@end

@implementation AFNViewController

- (void)viewDidLoad {
[super viewDidLoad];
[FHYNetWork startMonitoringNetworkStatus];
self.title = [NSString stringWithFormat:@"%ld",[FHYNetWork networkReachabilityStatus]];
// Do any additional setup after loading the view.
}
- (IBAction)get:(id)sender {
[FHYNetWork handleGETWithUrlString:@"http://api.liwushuo.com/v2/banners?channel=iOS" parameters:nil
showHuD:YES onView:self.imageView successfulBlock:^(id responseObject) {
NSLog(@"%@",responseObject);
} failureBlock:^(NSError *error) {
NSLog(@"fail");
}];
}
- (IBAction)post:(id)sender {
//http://api2.pianke.me/read/columns?auth=&client=1&deviceid=BA920378-52B5-43F2-BE1A-5404120EDD7A&version=3.0.6
NSDictionary *parameter = @{@"app_installtime":@"1444803219.182004", @"app_versions":@"4.2.2", @"channel_name":@"appStore", @"client_id":@"bt_app_ios", @"client_secret":@"9c1e6634ce1c5098e056628cd66a17a5", @"device_token":@"e7463e1072e3457122562effbab389502ce45dafccc1b05423429470873200ba", @"oauth_token":@"b5718c6bca162f4160ddf992e4a34436", @"os_versions":@"8.3", @"page":@"0", @"pagesize":@"20", @"screensize":@"640", @"show_product":@"1", @"tag_ids":@"5701,6126,757,3153", @"track_device_info":@"iPad4%2C4", @"track_deviceid":@"643DBAC3-6A76-4A19-BFC6-0BCABEE81955", @"track_user_id":@"1394370", @"type_id":@"0", @"v":@"7"};
[FHYNetWork handlePOSTWithUrlString:@"http://open3.bantangapp.com/community/post/listByTags" parameters:parameter showHuD:YES onView:self.view successfulBlock:^(id responseObject) {
NSLog(@"%@",responseObject);
} failureBlock:^(NSError *error) {
NSLog(@"failure");
}];
}
- (IBAction)upload:(id)sender {
NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
[formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
} error:nil];

AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
NSProgress *progress = nil;

NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
if (error) {
NSLog(@"Error: %@", error);
} else {
NSLog(@"%@ %@", response, responseObject);
}
}];
[uploadTask resume];
}
- (IBAction)start:(id)sender {
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
[_manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//刷新进度条的delegate方法，同样的，获取数据，调用主线程刷新UI
double currentProgress = totalBytesWritten/(double)totalBytesExpectedToWrite;
dispatch_async(dispatch_get_main_queue(), ^{
self.progressView.progress = currentProgress;
self.progressView.hidden = NO;
});
}];
NSURL *URL = [NSURL URLWithString:@"http://p1.pichost.me/i/40/1639665.png"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];

self.downloadTask = [_manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {        NSLog(@"File downloaded to: %@", filePath);
UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
[self.imageView setImage:image];

}];

[_downloadTask resume];
}
- (IBAction)pause:(id)sender {
if (_downloadTask) {
[self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
self.partialData = resumeData;
self.downloadTask = nil;
}];
}
}
- (IBAction)resume:(id)sender {
if (!self.downloadTask) {
//判断是否又已下载数据，有的话就断点续传，没有就完全重新下载
if (self.partialData) {

self.downloadTask = [_manager downloadTaskWithResumeData:_partialData progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
NSLog(@"File downloaded to: %@", filePath);
UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
[self.imageView setImage:image];

}];
}else{
[self start:nil];
}
}
[self.downloadTask resume];

}

五.封装NSURLSession网络连接

ps:参考连接以及推荐阅读

原文:From NSURLConnection to NSURLSession  https://www.objc.io/issues/5-ios7/from-nsurlconnection-to-nsurlsession/
译文:从 NSURLConnection 到 NSURLSession      http://objccn.io/issue-5-4/

原文:AFNetworking 3.0 Migration Guide                https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-3.0-Migration-Guide
译文:AFNetworking 3.0迁移指南                            http://www.jianshu.com/p/047463a7ce9b

end