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
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSData *partialData;



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
