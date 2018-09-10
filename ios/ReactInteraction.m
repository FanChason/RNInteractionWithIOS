//
//  ReactInteraction.m
//  RNInteractionWithiOS
//
//  Created by fanxc on 2018/9/10.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ReactInteraction.h"

#define INIT @"EventInit"
#define LOGIN @"EventLogin"

@implementation ReactInteraction
static ReactInteraction *instance = nil;

RCT_EXPORT_MODULE();
+ (instancetype)shareInstance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[INIT,LOGIN];
}

RCT_EXPORT_METHOD(init:(NSString *)msg) {
  [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                      method:@"emit"
                        args:@[INIT, msg]
                  completion:NULL];
}

RCT_EXPORT_METHOD(login) {
  [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter"
                      method:@"emit"
                        args:@[LOGIN]
                  completion:NULL];
}

@end
