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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 100, 100, 40);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonPressed {
    id<BModuleService> service = [[BeeHive shareInstance]createService:@protocol(BModuleService)];
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
