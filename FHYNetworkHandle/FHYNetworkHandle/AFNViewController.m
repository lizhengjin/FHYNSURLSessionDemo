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
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

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
    [FHYNetWork handleGETWithUrlString:@"http://api.liwushuo.com/v2/banners?channel=iOS" parameters:nil showHuD:YES onView:self.imageView successfulBlock:^(id responseObject) {
           NSLog(@"%@",responseObject);
       } failureBlock:^(NSError *error) {
           NSLog(@"fail");
       }];
}
- (IBAction)post:(id)sender {
//http://api2.pianke.me/read/columns?auth=&client=1&deviceid=BA920378-52B5-43F2-BE1A-5404120EDD7A&version=3.0.6
    NSDictionary *parameter = @{@"auth" : @"",@"client" : @"1",@"did" : @"5B50D703-BAB7-4C6B-A407-D9C7A73870B6",@"version" : @"3.0.6"};
//    NSString *parameters = [parameter stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [FHYNetWork handlePOSTWithUrlString:@"http://mapi.pianke.me/pub/jing" parameters:parameter showHuD:YES onView:self.view successfulBlock:^(id responseObject) {
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
    __weak typeof(self) weakSelf = self;
    [_manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        //刷新进度条的delegate方法，同样的，获取数据，调用主线程刷新UI
        double currentProgress = totalBytesWritten/(double)totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = currentProgress;
            weakSelf.progressView.hidden = NO;
        });
    }];
    NSURL *URL = [NSURL URLWithString:@"http://p1.pichost.me/i/40/1639665.png"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    self.downloadTask = [_manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSLog(@"%@",targetPath);
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:targetPath create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
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
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:targetPath create:NO error:nil];
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
