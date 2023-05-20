//
//  SModuleAViewController.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "SModuleAViewController.h"
#import "BModuleService.h"
@interface SModuleAViewController ()

@end

@implementation SModuleAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"服务注册 A";

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 100, 100, 40);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonPressed {
    
    // BModuleService 放到指定需要调用的模块中 
    // 业务模块可以直接调用对应接口

    id<BModuleService> service = [[PMediator sharedInstance]createService:@protocol(BModuleService)];
    NSInteger number = service.getBModuleGoodsNumber;
    UIViewController *vc = service.getBModuleVC;
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
