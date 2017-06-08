//
//  JSCallOCViewController.h
//  OC_JSInteractionDemo
//
//  Created by 丁玉松 on 16/9/2.
//  Copyright © 2016年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void (^JSCallback)(NSDictionary *callbackData);

@protocol TestJSExport <JSExport>

-(NSDictionary *)activityInfo;

-(void)activityTitle:(NSString *)title url:(NSString *)url desi:(NSString *)desi;

JSExportAs(exportInfo,
           -(void)activityName:(NSString *)name url:(NSString *)url desi:(NSString *)desi
           );

JSExportAs(gserInfo,
           -(void)gserInfo:(id)haha calla:(JSValue*)callback
           );

JSExportAs(userInfo,
           -(void)gotUserInfo:(id)haha callaaa:(JSCallback)callback
           );
/*
 带block回报错！！！！
 JSExportAs(setValue,
 -(void *)receivedMessage:(id)value call:(JSCallback)callback
 );
 */

@end


@interface JSCallOCViewController : UIViewController<UIWebViewDelegate,TestJSExport>

@property (nonatomic, strong) JSContext *context;

@property (nonatomic, copy) NSString *username;

@end


@protocol PerJSExport <JSExport>

@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,assign) BOOL sex;
@property (nonatomic ,assign) NSInteger age;

@end

@interface Persion : NSObject<PerJSExport>


@end

