//
//  JSCallOCViewController.m
//  OC_JSInteractionDemo
//
//  Created by 丁玉松 on 16/9/2.
//  Copyright © 2016年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import "JSCallOCViewController.h"
#import "WebViewJavascriptBridge_JS.h"

@interface JSCallOCViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *uiWebView;

@end

@implementation JSCallOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"gbanker.html"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://0.0.0.0:3000/metalInfo/metalInfo.html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://0.0.0.0:3000/ocjs/demo01.html"]];
    
    self.uiWebView.delegate = self;
    [self.uiWebView loadRequest:request];
    
    self.username = @"哈哈哈哈哈";
}

#pragma mark - 方式一： 抓链来进行通信
/*
    可以接收从wap传过来的数据（wap->app）
    同样的道理wap要接收从app传过来的数据可以使用挂参数的方式(app->wap)
 */
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.mainDocumentURL.absoluteString hasPrefix:@"gbanker://"]) {
        NSString *host = request.mainDocumentURL.host;
        NSString *scheme = request.mainDocumentURL.scheme;
        NSString *query = request.mainDocumentURL.query;
        
        NSLog(@"\n absoluteString:%@ \n scheme:%@\n host:%@\n query:%@",request.mainDocumentURL.absoluteString,scheme,host,query);
        return NO;
    }
    return YES;
}

//官方文档 https://developer.apple.com/documentation/javascriptcore/jsvalue  也可以参考sdk里jsvalue里面的注释。
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    
    //access to UIWebView's JSContext
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    
    [self addBlockFunc];
    
    //JSExport 协议关联
    self.context[@"iOS"] = self;
    
    [self OCCallJSWith:webView];
}


#pragma mark - JSCallOS:方式一：JSContext block

-(void)addBlockFunc{
    // 打印异常
    self.context.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    
    //一个参数
    self.context[@"jsCallOC1"] =
    ^(NSString *str)
    {
        NSLog(@"\n jsCallOCLog1：%@", str);
    };
    
    //两个参数
    self.context[@"jsCallOC2"] =
    ^(NSString *str1,NSString *str2)
    {
        NSLog(@"\n jsCallOC2：\n str1:%@ str2:%@", str1,str2);
    };
    
    //多个参数
    self.context[@"jsCallOC3"] =
    ^()
    {
        NSLog(@"\n jsCallOC3");
        NSArray *args = [JSContext currentArguments];
        for (NSString *jsVal in args) {
            NSLog(@"\n %@", jsVal);
        }
    };
    
    //两个参数，一个字符串，一个整形
    self.context[@"jsCallOC4"] =
    ^(NSString *str1,NSInteger intg2)
    {
        NSLog(@"\n jsCallOC4：\n str1:%@ str2:%ld", str1,(long)intg2);
    };
    
    
    
    //6个参数，null,原生类型，NSNumber，NSDictionary,NSArray,NSDate
    self.context[@"jsCallOC5"] =
    ^(JSValue *arg1,NSInteger arg2,NSNumber *arg3,NSDictionary *arg4,NSArray *arg5,NSDate *arg6)
    {
        NSLog(@"\n jsCallOC5：\n str1:%@ \n str2:%ld  \n arg3:%@ \n arg4:%@ \n arg5:%@ \n arg6:%@ ", arg1,(long)arg2,arg3,arg4,arg5,arg6);
    };
    
    
    //自定义类型 persion 参数
    /*
     self.context[@"jsCallOC6"] =
     ^(persion *persion)
     {
     NSLog(@"\n persion.name:%@ \n persion.sex:%d \n persion.age:%ld",persion.name,persion.sex,(long)persion.age);
     };
     */
    
    //自定义类型 persion 参数(有待继续研究)
    self.context[@"jsCallOC6"] =
    ^(JSValue *value)
    {
        //Persion *persion
        Persion *persion = [value toObjectOfClass:[Persion class]];
        
        NSLog(@"\n persion.name:%@ \n persion.sex:%d \n persion.age:%ld",persion.name,persion.sex,(long)persion.age);
    };
    
    
    
    //两个参数，一个字符串，一个整形(JSValue传值)
    self.context[@"jsCallOC7"] =
    ^(JSValue *str1,JSValue *intg2)
    {
        NSLog(@"\n jsCallOC7：\n str1:%@ str2:%d", str1.toString,intg2.toInt32);
    };
    
    //(JSValue传值，return string)
    self.context[@"jsCallOC8"] =
    ^(JSValue *str1,JSValue *intg2)
    {
        NSLog(@"\n jsCallOC8：\n str1:%@ str2:%d", str1.toString,intg2.toInt32);
        return @"jsCallOC8";
    };
    
    //两个参数，一个字符串，一个整形(JSValue传值，return dict)
    self.context[@"jsCallOC9"] =
    ^(JSValue *str1,JSValue *intg2)
    {
        return @{
                 @"title": @"黄金2016年会有大反弹",
                 @"url": @"https://www.g-banker.com/",
                 @"description": @"黄金看涨"
                 };
    };
    
    
    /*
     self.context[@"oclog2"] =
     ^(NSString *str, JSCallback callback)
     {
     NSLog(@"%@", str);
     NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
     [callbackData setValue:@"afasdfadsf" forKey:@"sessionID"];
     [callbackData setValue:@"123456789000" forKey:@"telephone"];
     callback(callbackData);
     };
     参数带block这种方式行不通！
     */
    
    
    //(JSValue传值，block回调)
    self.context[@"jsCallOC10"] =
    ^(JSValue *str1,JSValue *intg2,JSValue *blockTest)
    {
        [blockTest callWithArguments:@[@"block回调信息"]];
    };
    
    //(JSValue传值，block回调)
    self.context[@"jsCallOC11"] =
    ^(JSValue *str1,JSValue *intg2,JSValue *blockTest)
    {
        [blockTest callWithArguments:@[@"para1",
                                       @{@"title": @"黄金2016年会有大反弹",
                                         @"url": @"https://www.g-banker.com/",
                                         @"description": @"黄金看涨"
                                         },
                                       @"para3"]];
    };
    
}


#pragma mark - JSCallOC 方式二：JSContext JSExport


//无返回
-(void)activityTitle:(NSString *)title url:(NSString *)url desi:(NSString *)desi
{
    NSLog(@"\n title: %@ \n url: %@ \n desi:%@",title,url,desi);
}

-(void)activityName:(NSString *)name url:(NSString *)url desi:(NSString *)desi{
    NSLog(@"\n name: %@ \n url: %@ \n desi:%@",name,url,desi);
}

//同步返回
-(NSDictionary *)activityInfo{
    return @{@"title": @"黄金2016年会有大反弹",
             @"url": @"https://www.g-banker.com/",
             @"description": @"黄金看涨"
             };
}

//异步返回
-(void)gserInfo:(id)haha calla:(JSValue*)callback
{
    NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
    [callbackData setValue:@"afasdfadsf" forKey:@"sessionID"];
    [callbackData setValue:@"123456789000" forKey:@"telephone"];
    [callback callWithArguments:@[callbackData]];
}

-(void)gotUserInfo:(id)haha callaaa:(JSCallback)callback
{
    NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
    [callbackData setValue:@"afasdfadsf" forKey:@"sessionID"];
    [callbackData setValue:@"123456789000" forKey:@"telephone"];
    callback(callbackData);
}



#pragma mark - OCCallJS

-(void)OCCallJSWith:(UIWebView *)webView{
    
    //OC调用JS无返回值
    
    NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
    [callbackData setValue:@"黄金" forKey:@"category"];
    [callbackData setValue:@"Au(T+D)" forKey:@"code"];
    [callbackData setValue:@"现货延期交收交易" forKey:@"trademethod"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsStr = [NSString stringWithFormat:@"OCCallJS1(%@);",jsonStr];
    [webView stringByEvaluatingJavaScriptFromString:jsStr];
    
    //OC调用JS同步返回
    NSString *jsStr2 = [NSString stringWithFormat:@"OCCallJS2(%@);",jsonStr];
    NSString *calue = [webView stringByEvaluatingJavaScriptFromString:jsStr2];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[calue dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",dict);
    
    //OC调用JS异步返回
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



@implementation Persion


@end
