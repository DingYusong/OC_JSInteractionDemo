//
//  WKJSOCDemo2ViewController.m
//  OC_JSInteractionDemo
//
//  Created by 丁玉松 on 2017/6/8.
//  Copyright © 2017年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import "WKJSOCDemo2ViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge_JS.h"


typedef void (^JSCallback)(NSDictionary *callbackData);

typedef void(^actionBlock)(id, JSCallback);

@interface WKJSOCDemo2ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic ,strong) WKWebView *webView;
@property (nonatomic, strong) NSMutableDictionary *actionTable;


@end

@implementation WKJSOCDemo2ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20) configuration:[self webViewConfig]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://0.0.0.0:3000/ocjs/wkdemo02.html"]];
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
    
    [wkUController addScriptMessageHandler:self name:@"ios_smh"];//dict 可以

    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    return wkWebConfig;
}

#pragma mark - WKScriptMessageHandler

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"\n message.name: %@ \n message.body: %@",message.name, message.body);
    //？？JS调用OC的返回值问题
    [self dealName:message.name value:message.body];
    
    NSString *method = [message.body valueForKey:@"methodName"];
    NSString *data = [message.body valueForKey:@"data"];
    NSString *callbackId = [message.body valueForKey:@"callbackId"];
    
    JSCallback callback = ^void(NSDictionary *callbackData) {
        if(callbackData) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackData options:0 error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSMutableDictionary *wrappedData = [NSMutableDictionary dictionary];
            [wrappedData setValue:callbackId forKey:@"responseId"];
            [wrappedData setValue:jsonString forKey:@"responseData"];
            [self sendMessageDataToJavascript:wrappedData];
        }
    };

    actionBlock ab = self.actionTable[method];
    ab(data,callback);
}

- (void)sendMessageDataToJavascript:(id)messageData {
    NSData *data = [NSJSONSerialization dataWithJSONObject:messageData options:0 error:nil];
    if(data) {
        NSString *messageJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
        messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
        
        NSString* javascriptCommand = [NSString stringWithFormat:@"ios._handleMessageFromObjC('%@');", messageJSON];
        if ([[NSThread currentThread] isMainThread]) {
            [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
            });
        }
    }
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

- (void)injectJavascriptBridge {
    NSString *source = WebViewJavascriptBridge_js();
    [self.webView evaluateJavaScript:source completionHandler:nil];
}



#pragma mark - WKUIDelegate
// 界面弹出警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 界面弹出确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 界面弹出输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
//    [self OCCallJSWith:webView];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError * _Nullable error) {
        self.title = result;
    }];
    
    
    
    [self injectJavascriptBridge];
    
    self.actionTable = [NSMutableDictionary new];
    
    
    
    
    actionBlock loginab = ^void(id dataReceived,  JSCallback callback){
        
        NSLog(@"进行登录操作");
        
        NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
        [callbackData setValue:@"1" forKey:@"loginStatus"];
        if(callback) {
            callback(callbackData);
        }
    };
    
    [self.actionTable setValue:loginab forKey:@"login"];

    
    
    
    actionBlock commentab = ^void(id dataReceived,  JSCallback callback){
        
        NSLog(@"使用dataReceived 进行评论操作");
        
        NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
        [callbackData setValue:@"1" forKey:@"commentStatus"];
        if(callback) {
            callback(callbackData);
        }
    };
    
    [self.actionTable setValue:commentab forKey:@"comment"];

    
    actionBlock callServicePhoneab = ^void(id dataReceived,  JSCallback callback){
        
        NSLog(@"使用dataReceived callServicePhone");
        
        if(callback) {
            NSMutableDictionary *callbackData = [NSMutableDictionary dictionary];
            [callbackData setValue:@"1" forKey:@"commentStatus"];
            callback(callbackData);
        }
    };
    
    [self.actionTable setValue:callServicePhoneab forKey:@"callServicePhone"];

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
