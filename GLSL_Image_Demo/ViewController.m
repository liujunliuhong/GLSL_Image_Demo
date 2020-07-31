//
//  ViewController.m
//  GLSL_Image_Demo
//
//  Created by apple on 2020/7/31.
//  Copyright © 2020 yinhe. All rights reserved.
//

#import "ViewController.h"
#import "RenderView.h"

@interface ViewController ()
@property (nonatomic, strong) RenderView *renderView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.renderView = [[RenderView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.renderView];
}

@end
