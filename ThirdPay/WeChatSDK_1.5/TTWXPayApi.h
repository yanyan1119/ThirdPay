

#import <Foundation/Foundation.h>
#import "TTWXUtil.h"
#import "TTWXXml.h"

// 账号帐户资料
#define WXPay_APPID                @""

//商户号，填写商户对应参数
#define WXPay_PARTNERID            @""

//商户API密钥，填写相应参数
#define WXPay_PARTNERKEY           @""

//预支付网关url地址
#define WXPay_GetprepayUrl         @"https://api.mch.weixin.qq.com/pay/unifiedorder"

#define WXPay_QueryOrderUrl        @"https://api.mch.weixin.qq.com/pay/orderquery"


@interface TTWXPayApi : NSObject

@property (nonatomic,strong)NSString *orderName;
@property (nonatomic,strong)NSString *orderid;
@property (nonatomic,strong)NSString *notifyUrl;
@property (nonatomic,assign)float orderPrice;

+ (instancetype)shareInstance;

//获取预支付订单
- (NSMutableDictionary *)getPrepayId;

//查询微信支付订单状态
-(NSDictionary*)queryPayStatus:(NSString*)billId;

@end