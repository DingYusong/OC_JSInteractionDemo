//
//  WKJSCallOCViewController.m
//  OC_JSInteractionDemo
//
//  Created by DingYusong on 16/9/4.
//  Copyright © 2016年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import "WKJSCallOCViewController.h"
#import <WebKit/WebKit.h>

@interface WKJSCallOCViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic ,strong) WKWebView *webView;

@end

@implementation WKJSCallOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20) configuration:[self webViewConfig]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://0.0.0.0:3000/ocjs/wkdemo01.html"]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
    // Do any additional setup after loading the view.
}


-(WKWebViewConfiguration *)webViewConfig
{
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    
    [wkUController addScriptMessageHandler:self name:@"JSCallOC1"];//str
    [wkUController addScriptMessageHandler:self name:@"JSCallOC2"];//str dict str,三个参数不行
    [wkUController addScriptMessageHandler:self name:@"JSCallOC3"];//dict 可以
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    return wkWebConfig;
}

#pragma mark - WKScriptMessageHandler

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"\n message.name: %@ \n message.body: %@",message.name, message.body);
    //？？JS调用OC的返回值问题
    [self dealName:message.name value:message.body];
}

-(void)dealName:(NSString *)name value:(id)body
{
    if ([name isEqualToString:@"JSCallOC1"]) {
        
    }
    if ([name isEqualToString:@"JSCallOC2"]) {
        
    }
    if ([name isEqualToString:@"JSCallOC3"]) {
        
    }
}

#pragma mark - WKUIDelegate

// 界面弹出警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(void (^)())completionHandler{
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];

}
// 界面弹出确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];

}
// 界面弹出输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.mainDocumentURL;
    NSString *host = url.host;
    NSString *scheme = url.scheme;
    NSString *query = url.query;
    
    if ([scheme isEqualToString:@"gbanker"])
    {
        NSLog(@"\n absoluteString:%@ \n scheme:%@\n host:%@\n query:%@",url.absoluteString,scheme,host,query);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
{
    [self OCCallJSWith:webView];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError * _Nullable error) {
        self.title = result;
    }];
}


#pragma mark - OCCallJS

-(void)OCCallJSWith:(WKWebView *)webView{
    
    //OC调用JS无返回值
    NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
    [callbackData setValue:@"黄金" forKey:@"category"];
    [callbackData setValue:@"Au(T+D)" forKey:@"code"];
    [callbackData setValue:@"现货延期交收交易" forKey:@"trademethod"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsStr = [NSString stringWithFormat:@"OCCallJS1(%@);",jsonStr];
    [webView evaluateJavaScript:jsStr completionHandler:nil];
    
    //OC调用JS同步返回
    NSString *jsStr2 = [NSString stringWithFormat:@"OCCallJS2(%@);",jsonStr];
    [webView evaluateJavaScript:jsStr2 completionHandler:^(id _Nullable calue, NSError * _Nullable error) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[calue dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"%@",dict);
        NSLog(@"%@",calue);
    }];
    
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
