# RNInteractionWithIOS
ReactNative与IOS各种交互汇总

#前言
最近用RN开发SDK，涉及RN与iOS各种交互。

有些交互比如用iOS原生切换多个RN页面，以及iOS调用RN的方法，按照网上的方法调不通，一度不知如何是好，网上资料比较少。

于是自己看RN源码分析得出一些方法。
如有问题欢迎指正，有更好的思路方法欢迎分享。

#目录
```
一、 iOS 调用ReactNative
1，打开一个ReactNative页面
2，多个ReactNative页面切换（尽量在RN内实现）
3，iOS调用RN(分是否传参数)
二、ReactNative调用iOS
1，无参数无回调
2，有多个参数
3，有回调
4，有多个参数多个回调
```
##说明：
###1,Demo: **[RNInteractionWithIOS](https://github.com/xianChaoFan/RNInteractionWithIOS)**

- demo截图：
![Simulator Screen Shot - iPhone X - 2018-09-10 at 18.20.26.png](https://upload-images.jianshu.io/upload_images/1432381-eb2b738a78e3dd01.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###2,ReactNative版本：
    "react": "16.4.1",
    "react-native": "0.56.0"


#一、 iOS 调用ReactNative
## 1,打开一个ReactNative页面

比如react-native init RNInteractionWithiOS 创建一个应用之后就会自动在 `RNInteractionWithiOS->ios->RNInteractionWithiOS->AppDelegate.m`中生成打开一个ReactNative页面的代码。核心代码如下：
 ```
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"RNInteractionWithiOS"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
```

## 2,多个ReactNative页面切换（尽量在RN内实现）
*这个有点难度，当时还研究了半天，几乎没有资料可参考*
- RN核心代码：
在index.js中
```
AppRegistry.registerComponent("App", () => App);
AppRegistry.registerComponent("App2", () => App2);
```

- iOS中OC核心代码：
  - 设置`RCTBridge`的代理
  - 实现代理方法`- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge;`
  - 最关键的：通常情况下我们会使用`initWithBundleURL`创建一个RCTRootView，此处`必须`使用`initWithBridge`创建RCTRootView
```
#import "ViewController.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

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

#define RNBounds CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width-50, UIScreen.mainScreen.bounds.size.height/2.f)

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
  RCTRootView *rnView2 = [[RCTRootView alloc] initWithBridge:_bridge
                                                  moduleName:moduleName
                                           initialProperties:nil];
  rnView2.bounds = RNBounds;
  rnView2.center = self.view.center;
  [self.view addSubview:rnView2];
}
```
## 3，iOS调用RN(分是否传参数)
- RN核心代码
```
  componentWillMount() {
      DeviceEventEmitter.addListener('EventInit', (msg) => {
          let receive = "EventInit: " + msg;
          console.log(receive);
          this.setState({notice: receive});
      });

      DeviceEventEmitter.addListener('EventLogin', (msg) => {
          let receive = "EventLogin: " + msg;
          console.log(receive);
          this.setState({notice: receive});
      });
  }
```

- iOS核心代码：
  - 创建的iOS交互类要引用`#import<React/RCTBridgeModule.h>` 和`#import <React/RCTEventEmitter.h>`,继承`RCTEventEmitter`，并遵守`RCTBridgeModule`
  - 很关键的：交互类要设置`bridge`为`当前RCTRootView的bridge`，`[[ReactInteraction shareInstance] setValue:rnView.bridge forKey:@"bridge"];`

ReactInteraction.h文件
```
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface ReactInteraction : RCTEventEmitter <RCTBridgeModule>
+ (instancetype)shareInstance;
- (void)init:(NSString *)parameter;
- (void)login;
@end

```

ReactInteraction.m文件
```

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
```

# 二、ReactNative调用iOS
- RN核心代码：
```
import {NativeModules} from 'react-native';
const NativeInteraction = NativeModules.NativeInteraction;
```
- iOS核心代码：
  - 注意点1：`RCT_EXPORT_METHOD`与`RCT_REMAP_METHOD`宏定义的使用区别（个人总结，有不对请指正）
    - `RCT_EXPORT_METHOD`：用于仅有一个参数或回调
    - `RCT_REMAP_METHOD`：用于有多个参数或（和）多个回调
     （了解更多可以看RN宏定义`源码1`，下面👇贴出关键两句)
  - 注意点2：iOS回调方式有两种
    - `callback(@[jsonString]); ((RCTPromiseResolveBlock)resolver)`
    - Promise方式：`_resolveBlock(@[jsonString]);  ((RCTResponseSenderBlock)callback)` （了解更多看RN`源码2`）

源码1：
```
#define RCT_REMAP_METHOD(js_name, method) \
  _RCT_EXTERN_REMAP_METHOD(js_name, method, NO) \
  - (void)method RCT_DYNAMIC;

#define RCT_EXPORT_METHOD(method) \
  RCT_REMAP_METHOD(, method) 
```

源码2：
```
typedef void (^RCTResponseSenderBlock)(NSArray *response);
typedef void (^RCTResponseErrorBlock)(NSError *error);
typedef void (^RCTPromiseResolveBlock)(id result);
typedef void (^RCTPromiseRejectBlock)(NSString *code, NSString *message, NSError *error);
```

## 1,无参数回调
- RN核心代码：
```
    NativeInteraction.RNTransferIOS();
```
- iOS核心代码：
```
RCT_EXPORT_METHOD(RNTransferIOS) {
  NSLog(@"RN调用iOS");
}
```
## 2,有多个参数
- RN核心代码：
```
 NativeInteraction.RNTransferIOSWithParameter('{\'para1\':\'rndata1\',\'para2\':\'rndata2\'}');
```
- iOS核心代码：
```
RCT_EXPORT_METHOD(RNTransferIOSWithParameter:(NSString *)logString) {
  NSLog(@"来自RN的数据：%@",logString);
}
```
## 3,有回调
- RN核心代码：
```
    NativeInteraction.RNTransferIOSWithCallBack((data) => {
      this.setState({notice: data});
    });
```
- iOS核心代码：
```
RCT_EXPORT_METHOD(RNTransferIOSWithCallBack:(RCTResponseSenderBlock)callback) {
  callback(@[[NSString stringWithFormat:@"来自iOS Native的数据：%@",TestNativeJsonData]]);
}
```
## 4,有多个参数多个回调
- RN核心代码：
```
 NativeInteraction.RNTransferIOSWithParameterAndCallBack('rndata1','rndata2').then(result =>{
      let jsonString = JSON.stringify(result);
      this.setState({notice: jsonString});
    }).catch(error=>{
    });
```
- iOS核心代码：
```
{
  RCTPromiseResolveBlock _resolveBlock;
  RCTPromiseRejectBlock _rejectBlock;
}
RCT_REMAP_METHOD(RNTransferIOSWithParameterAndCallBack, para1:(NSString *)para1 para2:(NSString *)para2 resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"来自RN的数据：para1——%@， para2——%@",para1, para2);

  _resolveBlock=resolver;
  _rejectBlock=reject;
  NSString *jsonString = TestNativeJsonData;
  _resolveBlock(@[jsonString]);
}
```

如上有问题欢迎各路大神留言指正，写博客不容易，大家相互学习。
