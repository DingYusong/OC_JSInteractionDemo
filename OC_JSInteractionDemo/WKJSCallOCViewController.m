//
//  WKJSCallOCViewController.m
//  OC_JSInteractionDemo
//
//  Created by DingYusong on 16/9/4.
//  Copyright © 2016年 Beijing Yingyan Internet Co., Ltd. All rights reserved.
//

#import "WKJSCallOCViewController.h"
#import <WebKit/WebKit.h>

@interface WKJSCallOCViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic ,strong) WKWebView *webView;

@end

@implementation WKJSCallOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://0.0.0.0:3000/demo01.html"]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.webView loadRequest:request];

    
    [self.view addSubview:self.webView];
    
    // Do any additional setup after loading the view.
}


#pragma mark - WKUIDelegate




#pragma mark - WKNavigationDelegate


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
{
    
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
