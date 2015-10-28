//
//  AlixpayEngine.m
//  tenant
//
//  Created by hky on 15/10/28.
//  Copyright (c) 2015年 hky. All rights reserved.
//

#import "AlixpayEngine.h"
#import "DataSigner.h"

@implementation AlixpayEngine


-(void) pay:(void (^)(NSDictionary *resultDictionary))payblock;
{
    //partner和seller获取失败,提示
    if ([AlixpayPartner length] == 0 ||
        [AlixpaySeller length] == 0 ||
        [AlixpayPrivateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    _orderModel.partner = AlixpayPartner;
    _orderModel.seller = AlixpaySeller;
    _orderModel.service = @"mobile.securitypay.pay";
    _orderModel.paymentType = @"1";
    _orderModel.inputCharset = @"utf-8";
    _orderModel.itBPay = @"30m";
    _orderModel.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"Tenant";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [_orderModel description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(AlixpayPrivateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil)
    {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString
                                  fromScheme:appScheme
                                    callback:^(NSDictionary *resultDic) {
                                        NSLog(@"reslut = %@",resultDic);
                                        payblock(resultDic);
                                    }];
    }
}
@end
