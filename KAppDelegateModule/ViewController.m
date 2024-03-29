//
//  ViewController.m
//  KAppDelegateModule
//
//  Created by DXM on 2023/4/19.
//

#import "ViewController.h"
#import "CTMediator+ModuleAActions.h"
@interface ViewController ()

@end

@implementation ViewController

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
    UIViewController *viewController = [[CTMediator sharedInstance] CTMediator_viewControllerForModuleA];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
