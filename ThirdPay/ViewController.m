//
//  ViewController.m
//  ThirdPay
//
//  Created by hky on 15/10/28.
//  Copyright © 2015年 hky. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kPayProductId @"201510281122334455"

#import "WXApi.h"
#import "AlixPayResult.h"
#import "AlixpayEngine.h"
#import "TTWXPayApi.h"
#import "ViewController.h"

@interface ViewController ()<WXApiDelegate>
{
    UIButton *_alipayButton;
    UIButton *_wechatPayButton;
    UIButton *_yilianPayButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [WXApi registerApp:@"wxc4e9f91ab32ad957"];
    
    _alipayButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 120 )/2, (kScreenHeight - 300)/2, 120, 44)];
    [_alipayButton setTitle:@"支付宝支付" forState:UIControlStateNormal];
    _alipayButton.layer.cornerRadius = 5;
    _alipayButton.clipsToBounds = YES;
    [_alipayButton setBackgroundColor:[UIColor blueColor]];
    [_alipayButton addTarget:self action:@selector(clickAlipayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_alipayButton];
    
    _wechatPayButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 120 )/2, (kScreenHeight - 300)/2 + 100, 120, 44)];
    [_wechatPayButton setTitle:@"微信支付" forState:UIControlStateNormal];
    _wechatPayButton.layer.cornerRadius = 5;
    _wechatPayButton.clipsToBounds = YES;
    [_wechatPayButton setBackgroundColor:[UIColor blueColor]];
    [_wechatPayButton addTarget:self action:@selector(clickWechatPayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wechatPayButton];
    
    _yilianPayButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 120 )/2, (kScreenHeight - 300)/2 + 200, 120, 44)];
    [_yilianPayButton setTitle:@"易联支付" forState:UIControlStateNormal];
    _yilianPayButton.layer.cornerRadius = 5;
    _yilianPayButton.clipsToBounds = YES;
    [_yilianPayButton setBackgroundColor:[UIColor blueColor]];
    [_yilianPayButton addTarget:self action:@selector(clickYilianpayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_yilianPayButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alixpaysuccess:) name:AlixpaySuccessNotifycation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatpaysuccess:) name:WechatpaySuccessNotifycation object:nil];
}

-(void)alixpaysuccess:(NSNotification*)noty
{
    AlixPayResult *result = (AlixPayResult *)noty.object;
    if (result.statusCode == AlixpayPaySuccess)
    {
        //支付成功
    }
}

-(void)wechatpaysuccess:(NSNotification*)noty
{
    [WXApi handleOpenURL:noty.object delegate:self];
}

#pragma mark -  WXApiDelegate

-(void) onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[PayResp class]])
    {
        if (resp.errCode == WXSuccess)
        {
            NSDictionary *dict = [[TTWXPayApi shareInstance] queryPayStatus:kPayProductId];
            if ([[dict objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] && [[dict objectForKey:@"return_code"] isEqualToString:@"SUCCESS"])
            {
                if ([[dict objectForKey:@"trade_state"] isEqualToString:@"SUCCESS"]) {
                    //查询账单成功
                }
                else if([[dict objectForKey:@"trade_state"] isEqualToString:@"REFUND"])
                {
                    //@"转入退款"
                }
                else if([[dict objectForKey:@"trade_state"] isEqualToString:@"NOTPAY"])
                {
                    //未支付
                }
                else if([[dict objectForKey:@"trade_state"] isEqualToString:@"CLOSED"])
                {
                    //已关闭
                }
                else if([[dict objectForKey:@"trade_state"] isEqualToString:@"REVOKED"])
                {
                    //已撤销
                }
                else if([[dict objectForKey:@"trade_state"] isEqualToString:@"USERPAYING"])
                {
                    //用户支付中
                }
                else
                {
                    //支付失败
                }
            }
            else if([[dict objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] && [[dict objectForKey:@"result_code"] isEqualToString:@"FAIL"])
            {
                //
            }
            else
            {
                //支付失败
            }
        }
        else if (resp.errCode == WXErrCodeUserCancel)
        {
            //用户取消支付
        }
        else if (resp.errCode == WXErrCodeCommon)
        {
            //支付失败"
        }
        else if (resp.errCode == WXErrCodeSentFail)
        {
            //发送失败
        }
        else if (resp.errCode == WXErrCodeAuthDeny)
        {
            //授权失败
        }
        else if (resp.errCode == WXErrCodeUnsupport)
        {
            //微信不支持
        }
        else
        {
            //未知支付错误
        }
    }
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:AlixpaySuccessNotifycation];
    [[NSNotificationCenter defaultCenter] removeObserver:WechatpaySuccessNotifycation];
}

-(void)clickAlipayButton:(UIButton*)button
{
    AlixpayEngine *payObj = [[AlixpayEngine alloc] init];
    AlixpayModel *model = [[AlixpayModel alloc] init];
    model.amount = @"0.01";
    model.productName = @"测试支付宝支付";
    model.productDescription = @"用支付宝支付，有优惠哦";
    model.tradeNO = kPayProductId;
    model.notifyURL = @"";
    payObj.orderModel = model;
    [payObj pay:^(NSDictionary *resultDictionary) {
        if ([[resultDictionary objectForKey:@"resultStatus"]integerValue] == 9000) {
        }

    }];
}
-(void)clickWechatPayButton:(UIButton*)button
{
    TTWXPayApi *req = [TTWXPayApi shareInstance];
    //初始化支付签名对象
    req.orderid = kPayProductId;
    req.orderName = @"微信支付测试";
    req.notifyUrl = @"";
    req.orderPrice = 1;
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req getPrepayId];
    if (dict)
    {
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        [WXApi sendReq:req];
    }
}
-(void)clickYilianpayButton:(UIButton*)button
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
