//
//  JSCallOCViewController.m
//  OC_JSInteractionDemo
//
//  Created by 丁玉松 on 16/9/2.
//  Copyright © 2016年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import "JSCallOCViewController.h"

@interface JSCallOCViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *uiWebView;

@end

@implementation JSCallOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"gbanker.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.109:3000/gbanker.html"]];
    self.uiWebView.delegate = self;
    [self.uiWebView loadRequest:request];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Undocumented access to UIWebView's JSContext
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 打印异常
    self.context.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    
    // 以 JSExport 协议关联 native 的方法
    self.context[@"iOS"] = self;
    
    // 以 block 形式关联 JavaScript function
    self.context[@"log"] =
    ^(NSString *str)
    {
        NSLog(@"%@", str);
    };
    
    // 以 block 形式关联 JavaScript function
    self.context[@"alert"] =
    ^(NSString *str)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"msg from js" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    };
    
    __block typeof(self) weakSelf = self;
    self.context[@"addSubView"] =
    ^(NSString *viewname)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 500, 300, 100)];
        view.backgroundColor = [UIColor redColor];
        UISwitch *sw = [[UISwitch alloc]init];
        [view addSubview:sw];
        [weakSelf.view addSubview:view];
    };
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
