//
//  HQAccount.h
//  HQAccountExample
//
//  Created by 刘欢庆 on 2017/9/1.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const HQAccountLoginNotify;
extern NSString *const HQAccountLogoutNotify;
extern NSString *const HQAccountKickoutNotify;

@protocol HQAccountProtocol<NSCoding>
- (NSString *)userno;
- (NSString *)token;
@end


@interface HQAccount : NSObject
/** 保存用户信息:在调用login前不会持久化userno,token*/
+ (BOOL)save:(id<HQAccountProtocol>)user;

/** 
 * 登录:
 * 发送HQAccountLoginNotify通知
 * 通过save中的信息持久化userno,token
 */
+ (BOOL)login;

/** 
 * 登出:
 * 发送HQAccountLogoutNotify通知
 * 退出登录,清空userno,token,不会清空用户信息 
 */
+ (void)logout;

/**
 * 异常登出:
 * 发送HQAccountLogoutNotify,HQAccountKickoutNotify通知
 * 被其他用户踢出,清空userno,token,不会清空用户信息
 */
+ (void)kickout;

/** 判断是否登录 */
+ (BOOL)isLogin;


+ (NSString *)userno;

+ (NSString *)token;

+ (id<HQAccountProtocol>)user;

@end
