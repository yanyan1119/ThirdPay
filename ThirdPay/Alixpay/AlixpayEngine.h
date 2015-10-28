//
//  AlixpayEngine.h
//  tenant
//
//  Created by hky on 15/10/28.
//  Copyright (c) 2015年 hky. All rights reserved.
//


#define AlixpayPartner @""
#define AlixpaySeller @""
#define AlixpayPrivateKey @""


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AlixpayModel.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AlixpayEngine : NSObject

@property (nonatomic, retain) AlixpayModel *orderModel;

- (void)pay:(void (^)(NSDictionary *resultDictionary))payblock;

@end
