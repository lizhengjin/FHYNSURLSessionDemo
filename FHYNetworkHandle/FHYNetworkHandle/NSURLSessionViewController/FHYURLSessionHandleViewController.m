//
//  FHYURLSessionHandleViewController.m
//  FHYNetworkHandle
//
//  Created by 付寒宇 on 15/11/9.
//  Copyright © 2015年 付寒宇. All rights reserved.
//

#import "FHYURLSessionHandleViewController.h"
#import "FHYURLSessionHandle.h"
@interface FHYURLSessionHandleViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation FHYURLSessionHandleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)start:(id)sender {
    
}
- (IBAction)pause:(id)sender {
    
}
- (IBAction)resume:(id)sender {
    
}
- (IBAction)get:(id)sender {
    [FHYURLSessionHandle handleGETWithUrlString:@"http://api.liwushuo.com/v2/banners?channel=iOS" parameters:nil showHuD:YES onView:self.imageView successfulBlock:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"付寒宇error%@",error);
    }];
}
- (IBAction)post:(id)sender {
    [FHYURLSessionHandle handlePOSTWithUrlString:@"http://api2.pianke.me/read/columns" parameters:@"auth=&client=1&deviceid=BA920378-52B5-43F2-BE1A-5404120EDD7A&version=3.0.6" showHuD:YES onView:self.imageView successfulBlock:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"付寒宇error%@",error);
    }];
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
