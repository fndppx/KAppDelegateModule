//
//  URLModuleBViewController.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/9.
//

#import "URLModuleBViewController.h"
#import "MGJRouter.h"
@interface URLModuleBViewController ()

@end

@implementation URLModuleBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"URL B";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 100, 100, 40);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonPressed {
    UIViewController *vc = [MGJRouter objectForURL:@"mgj://app/getModuleA" withUserInfo:@{}];
    [self.navigationController pushViewController:vc animated:YES];

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
