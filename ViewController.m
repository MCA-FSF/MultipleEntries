//
//  ViewController.m
//  BuckDemo
//
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.center = self.view.center;
    btn.backgroundColor =[UIColor redColor];
    [btn setTitle:@"Button" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

@end
