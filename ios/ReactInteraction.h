//
//  ReactInteraction.h
//  RNInteractionWithiOS
//
//  Created by fanxc on 2018/9/10.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface ReactInteraction : RCTEventEmitter <RCTBridgeModule>
+ (instancetype)shareInstance;
- (void)init:(NSString *)parameter;
- (void)login;
@end
