//
//  ViewController.m
//  WebService
//
//  Created by aJia on 12/12/12.
//  Copyright (c) 2012年 rang. All rights reserved.
//

#import "ViewController.h"
#import "SoapHelper.h"
#import "ASIHTTPRequest.h"
#import "SoapXmlParseHelper.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    helper=[[ServiceHelper alloc] initWithQueueDelegate:self];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//开始加载动画
-(void)startLoadAnimation:(NSString*)strTitle{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	//[self.navigationController.view addSubview:HUD];
    [self.view addSubview:HUD];
	
	HUD.dimBackground = YES;
    //HUD.color=[UIColor redColor];
	HUD.labelText = strTitle;
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	//HUD.delegate = self;
	
    [HUD show:YES];
}
#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}
// 以下是测试校园网学科平台ws接口 http://192.168.2.71:9999/Speaking.asmx" //

//同步请求
- (IBAction)buttonSyncClick:(id)sender {
    [self startLoadAnimation:@"loading"];
    NSLog(@"=======同步请求开始======\n");
    NSMutableArray *arr=[NSMutableArray array];
    
     //[arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"3",@"type", nil]];
    //[arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"curPage", nil]];
    //[arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"pageSize", nil]];
     [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ZRY",@"studentid",nil]];
     [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"levelid",nil]];
     [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"skilltype",nil]];
     [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"A",@"trainmode",nil]];
    //NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetWebNewsByType"];
    NSString *soapMsg =[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"WS_Speaking_GetInfoByLevelIDSkillTypeTrainMode"];
    //    WS_IsStudent
    //执行同步并取得结果
    NSString *xml=[helper syncServiceMethod:@"WS_Speaking_GetInfoByLevelIDSkillTypeTrainMode"
                                SoapMessage:soapMsg];
  //  NSString *xml=[helper sync];
    //将xml使用SoapXmlParseHelper类转换成想要的结果
// NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 //NSLog(@"data string %@", string);
    NSLog(@"同步请求返回的xml:\n%@\n",xml);
    NSLog(@"=======同步请求结束======\n");
    [HUD hide:YES];
}
/*
//同步请求
- (IBAction)buttonSyncClick:(id)sender {
    [self startLoadAnimation:@"loading"];
    NSLog(@"=======同步请求开始======\n");
    NSMutableArray *arr=[NSMutableArray array];
    
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"3",@"type", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"curPage", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"pageSize", nil]];
    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetWebNewsByType"];
    //执行同步并取得结果
     NSString *xml=[helper syncServiceMethod:@"GetWebNewsByType" SoapMessage:soapMsg];    
    //将xml使用SoapXmlParseHelper类转换成想要的结果
    
    NSLog(@"同步请求返回的xml:\n%@\n",xml);
    NSLog(@"=======同步请求结束======\n");
    [HUD hide:YES];
}*/

//异步请求
- (IBAction)buttonAsycClick:(id)sender {
    [self startLoadAnimation:@"loading"];
    NSLog(@"=======异步请求开始======\n");
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"3",@"type", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"curPage", nil]];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"pageSize", nil]];
    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetWebNewsByType"];
    [helper asynServiceMethod:@"GetWebNewsByType" SoapMessage:soapMsg];
}
//队列请求
- (IBAction)buttonQueueClick:(id)sender {
    [self startLoadAnimation:@"loading"];
    NSLog(@"=======队列请求开始======\n");
    [helper resetQueue];//取消之前的请求
    for (int i=1; i<4; i++) {
        NSString *name=[NSString stringWithFormat:@"request%d",i];
        //获取soap
        NSMutableArray *arr=[NSMutableArray array];
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",i],@"type", nil]];
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"curPage", nil]];
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"pageSize", nil]];
        NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetWebNewsByType"];
        
        //获取ASIHTTPRequest
        ASIHTTPRequest *request=[ServiceHelper commonSharedRequestMethod:@"GetWebNewsByType" SoapMessage:soapMsg];
        //设置UserInfo用于区分不同的请求
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name", nil]];
        //添加到队列中
        [helper addRequestQueue:request];
    }
    [helper startQueue];//开始队列
}
#pragma mark -
#pragma mark 异步请求结果
-(void)finishSuccessRequest:(NSString*)xml{
    
    //将xml使用SoapXmlParseHelper类转换成想要的结果
    
    NSLog(@"异步请求返回的xml:\n%@\n",xml);
    NSLog(@"=======异步请求结束======\n");
     [HUD hide:YES];
}
-(void)finishFailRequest:(NSError*)error{
    NSLog(@"异步请发生失败:%@\n",[error description]);
     [HUD hide:YES];
}
- (void)dealloc {
    [helper release];
    [super dealloc];
}
#pragma mark -
#pragma mark 队列请求处理
-(void)finishQueueComplete{
    NSLog(@"＝＝＝所有队列请求完成=====\n");
     [HUD hide:YES];
}
-(void)finishSingleRequestSuccess:(NSString*)xml userInfo:(NSDictionary*)dic{
    
    //将xml使用SoapXmlParseHelper类转换成想要的结果
    
    NSString *name=[dic objectForKey:@"name"];
    NSLog(@"队列%@,请求完成\n",name);
    NSLog(@"队列%@,返回的xml为\n%@\n",name,xml);
}
-(void)finishSingleRequestFailed:(NSError*)error userInfo:(NSDictionary*)dic{
    NSString *name=[dic objectForKey:@"name"];
    NSLog(@"队列%@,请求失败\n",name);
    NSLog(@"队列%@,请求失败原因为\n%@\n",name,[error description]);

}
@end
