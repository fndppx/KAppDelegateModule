//
//  ModuleAViewController.m
//  KAppDelegateModule
//
//  Created by kyan on 2023/5/8.
//

#import "ModuleAViewController.h"
#import "CTMediator+ModuleBActions.h"
@interface ModuleAViewController ()

@end

@implementation ModuleAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"A";
    // Do any additional setup after loading the view.
    NSLog(@"self.data>>>%@",self.data);
    NSLog(@"imageView>>>%@", self.imageView);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 100, 100, 40);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonPressed {
    UIViewController *viewController = [[CTMediator sharedInstance] CTMediator_viewControllerForModuleB];
    [self.navigationController pushViewController:viewController animated:YES];
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
