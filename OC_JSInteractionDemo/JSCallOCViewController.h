//
//  JSCallOCViewController.h
//  OC_JSInteractionDemo
//
//  Created by 丁玉松 on 16/9/2.
//  Copyright © 2016年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport <JSExport>

JSExportAs(setValue,
           -(void)receivedMessage:(id)value
           );
@end


@interface JSCallOCViewController : UIViewController<UIWebViewDelegate,TestJSExport>

@property (nonatomic, strong) JSContext *context;

@end
