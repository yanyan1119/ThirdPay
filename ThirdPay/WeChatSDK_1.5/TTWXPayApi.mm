
#import <Foundation/Foundation.h>
#import "TTWXPayApi.h"

static TTWXPayApi *_shareInstance;

@implementation TTWXPayApi

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[TTWXPayApi alloc] init];
    });
    return _shareInstance;
}

//创建package签名
-(NSString*)createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray)
    {
        if (![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"])
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", WXPay_PARTNERKEY];
    //得到MD5 sign签名
    NSString *md5Sign =[TTWXUtil md5:contentString];
    //输出Debug Info
    return md5Sign;
}

//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSMutableString *reqPars=[NSMutableString string];
    //生成签名
    NSString *sign = [self createMd5Sign:packageParams];
    
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys)
    {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}
//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams
{
    NSString *prepayid = nil;
    
    //获取提交支付
    NSString *send = [self genPackage:prePayParams];
    
    //发送请求post xml数据
    NSData *res = [TTWXUtil httpSend:WXPay_GetprepayUrl method:@"POST" data:send];
    XMLHelper *xml  = [[XMLHelper alloc] init];

    //开始解析
    [xml startParse:res];
    
    NSMutableDictionary *resParams = [xml getDict];
    NSLog(@"生成预订单dic :%@",resParams);
    
    if ([[resParams objectForKey:@"result_code"] isEqualToString:@"FAIL"])
    {
        return @"";
    }
    //判断返回
    NSString *return_code = [resParams objectForKey:@"return_code"];
    NSString *result_code = [resParams objectForKey:@"result_code"];
    if ( [return_code isEqualToString:@"SUCCESS"] )
    {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:resParams ];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;
        
        //验证签名正确性
        if( [sign isEqualToString:send_sign])
        {
            if( [result_code isEqualToString:@"SUCCESS"])
            {
                //验证业务处理状态
                prepayid = [resParams objectForKey:@"prepay_id"];
            }
        }
    }
    return prepayid;
}


- ( NSMutableDictionary *)getPrepayId
{
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    [packageParams setObject: WXPay_APPID forKey:@"appid"];       //开放平台appid
    [packageParams setObject: WXPay_PARTNERID forKey:@"mch_id"];      //商户号
    [packageParams setObject: @"APP-001" forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: noncestr forKey:@"nonce_str"];   //随机串
    [packageParams setObject: @"APP" forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject: _orderName forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: _notifyUrl?_notifyUrl:@"" forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: _orderid forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: @"196.168.1.1" forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: [NSString stringWithFormat:@"%.0f",_orderPrice] forKey:@"total_fee"];       //订单金额，单位为分
    
    //获取prepayId（预支付交易会话标识）
    NSString *prePayid = [self sendPrepay:packageParams];
    if ( prePayid != nil)
    {
        //获取到prepayid后进行第二次签名
        NSString    *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str = [TTWXUtil md5:time_stamp];
        
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        package = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: WXPay_APPID forKey:@"appid"];
        [signParams setObject: nonce_str forKey:@"noncestr"];
        [signParams setObject: package forKey:@"package"];
        [signParams setObject: WXPay_PARTNERID forKey:@"partnerid"];
        [signParams setObject: time_stamp forKey:@"timestamp"];
        [signParams setObject: prePayid forKey:@"prepayid"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];
        //添加签名
        [signParams setObject:sign forKey:@"sign"];
        //返回参数列表
        return signParams;
    }
    return nil;
}

-(NSDictionary*)queryPayStatus:(NSString*)billId
{
    NSString *noncestr = [NSString stringWithFormat:@"%d", rand()];
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    [packageParams setObject:WXPay_APPID forKey:@"appid"];
    [packageParams setObject: WXPay_PARTNERID forKey:@"mch_id"];
    [packageParams setObject:billId forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject:noncestr forKey:@"nonce_str"];
    
    //生成签名
    NSString *sign  = [self createMd5Sign:packageParams];
    NSMutableString *reqPars=[NSMutableString string];
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys)
    {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    NSString *str = [NSString stringWithString:reqPars];

    //发送请求post xml数据
    NSData *res = [TTWXUtil httpSend:WXPay_QueryOrderUrl method:@"POST" data:str];
    XMLHelper *xml  = [[XMLHelper alloc] init];
    [xml startParse:res];
    NSMutableDictionary *resParams = [xml getDict];
    return resParams;
}

@end