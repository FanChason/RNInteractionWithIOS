//
//  ViewController.m
//  RNInteractionWithiOS
//
//  Created by fanxc on 2018/9/10.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ViewController.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "ReactInteraction.h"

@interface ViewController ()<RCTBridgeDelegate>
@property (nonatomic, strong) RCTBridge *bridge;

@end

@implementation ViewController

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return [NSURL URLWithString:@"http://127.0.0.1:8081/index.bundle?platform=ios"];// 模拟器
}

- (void)viewDidLoad {
    [super viewDidLoad];
  _bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:nil];
}

#define RNBounds CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width-50, UIScreen.mainScreen.bounds.size.height/3.f)

/*************************  iOS调用RN  ***********************/
- (IBAction)openRNOne {
  [self removeRNPage];
  [self loadRNView:@"App"];
}

- (IBAction)openRNTwo {
  [self removeRNPage];
  [self loadRNView:@"App2"];
}

- (IBAction)removeRNPage {
  [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isKindOfClass:[RCTRootView class]]) {
      [obj removeFromSuperview];
      return;
    }
  }];
}

- (void)loadRNView:(NSString *)moduleName {
  RCTRootView *rnView = [[RCTRootView alloc] initWithBridge:_bridge
                                                  moduleName:moduleName
                                           initialProperties:nil];
  // 设置ReactInteraction的桥接文件，不设置iOS将不能调起来RN的事件（重要）！！！！！！！
  [[ReactInteraction shareInstance] setValue:rnView.bridge forKey:@"bridge"];

  rnView.bounds = RNBounds;
  rnView.center = self.view.center;
  [self.view addSubview:rnView];
}

- (IBAction)iOSTransferRNWithNoparameter {
  [self openRNOne];
  [[ReactInteraction shareInstance] login];
}

- (IBAction)iOSTransferRNWithPatameter {
  [self openRNOne];
  NSString *parameter = @"@{@\"appid\":@\"123456\",@\"appKey\":@\"aaaaaa\"}";
  [[ReactInteraction shareInstance] init:parameter];
}

@end
