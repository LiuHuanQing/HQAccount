//
//  HQAccount.m
//  HQAccountExample
//
//  Created by 刘欢庆 on 2017/9/1.
//  Copyright © 2017年 刘欢庆. All rights reserved.
//

#import "HQAccount.h"

NSString *const HQAccountLoginNotify = @"HQAccountLoginNotify";
NSString *const HQAccountLogoutNotify = @"HQAccountLogoutNotify";
NSString *const HQAccountKickoutNotify = @"HQAccountKickoutNotify";

NSString *const HQAccountUserObjectUDKey = @"HQAccountUserObjectUDKey";
NSString *const HQAccountUserTokenUDKey = @"HQAccountUserTokenUDKey";
NSString *const HQAccountUserUsernoUDKey = @"HQAccountUserUsernoUDKey";

#define hq_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@interface HQAccount()
@property (nonatomic, strong) id<HQAccountProtocol> user;
@end

@implementation HQAccount

+ (instancetype)sharedInstance
{
    static HQAccount *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[HQAccount alloc] init];
    });
    return obj;
}
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self load];
    }
    return self;
}

- (void)load
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:HQAccountUserObjectUDKey];
    id user = nil;
    if(data)
    {
        user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    _user = user;
}


+ (BOOL)isLogin
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud objectForKey:HQAccountUserTokenUDKey];
    NSString *userno = [ud objectForKey:HQAccountUserUsernoUDKey];
    return token && token.length > 0 && userno && userno.length;
}


+ (BOOL)save:(id<HQAccountProtocol>)user
{
    if(user && [(NSObject *)user conformsToProtocol:@protocol(HQAccountProtocol)] && user.userno && user.token)
    {
        [HQAccount sharedInstance].user = user;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:HQAccountUserObjectUDKey];
        [ud synchronize];
        return YES;
    }
    return NO;
}

+ (BOOL)login
{
    id<HQAccountProtocol> user = [HQAccount sharedInstance].user;
    if(user)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:user.token forKey:HQAccountUserTokenUDKey];
        [ud setObject:user.userno forKey:HQAccountUserUsernoUDKey];
        [ud synchronize];
        hq_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:HQAccountLoginNotify object:nil];
        });

        return YES;
    }
    return NO;
}

+ (void)logout
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:HQAccountUserTokenUDKey];
    [ud removeObjectForKey:HQAccountUserUsernoUDKey];
    [HQAccount sharedInstance].user = nil;
    
    hq_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:HQAccountLogoutNotify object:nil];
    });
}


+ (void)kickout
{
    if([self isLogin])
    {
        hq_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:HQAccountKickoutNotify object:nil];
        });
    }
    [self logout];
}

+ (NSString *)userno
{
    return [HQAccount sharedInstance].user.userno;
}

+ (NSString *)token
{
    return [HQAccount sharedInstance].user.token;
}

+ (id<HQAccountProtocol>)user
{
    return [HQAccount sharedInstance].user;
}


@end
