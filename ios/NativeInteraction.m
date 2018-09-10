//
//  NativeInteraction.m
//  RNInteractionWithiOS
//
//  Created by fanxc on 2018/9/10.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "NativeInteraction.h"

#define TestNativeJsonData @"{\"callback1\":\"123\",\"callback2\":\"asd\"}"

@implementation NativeInteraction
{
  RCTPromiseResolveBlock _resolveBlock;
  RCTPromiseRejectBlock _rejectBlock;
}
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(RNTransferIOS) {
  NSLog(@"RN调用iOS");
}

RCT_EXPORT_METHOD(RNTransferIOSWithParameter:(NSString *)logString) {
  NSLog(@"来自RN的数据：%@",logString);
}

RCT_EXPORT_METHOD(RNTransferIOSWithCallBack:(RCTResponseSenderBlock)callback) {
  callback(@[[NSString stringWithFormat:@"来自iOS Native的数据：%@",TestNativeJsonData]]);
}

RCT_REMAP_METHOD(RNTransferIOSWithParameterAndCallBack, para1:(NSString *)para1 para2:(NSString *)para2 resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"来自RN的数据：para1——%@， para2——%@",para1, para2);

  _resolveBlock=resolver;
  _rejectBlock=reject;
  NSString *jsonString = TestNativeJsonData;
  _resolveBlock(@[jsonString]);
}


@end
