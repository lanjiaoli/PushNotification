//
//  BasicUserNotification.h
//  CustomKVO
//
//  Created by L on 2019/2/14.
//  Copyright © 2019 L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <UserNotifications/UserNotifications.h>
NS_ASSUME_NONNULL_BEGIN



@interface BasicUserNotification : NSObject<UNUserNotificationCenterDelegate>
/**
 推送通知Token
 */
@property (nonatomic, copy) NSString * deviceTokenString;
+ (instancetype)shareNotification;
/**
 注册通知
 */
- (void)registeUserNotificationConfig;
/**
 获取deviceToken

 @param deviceToken 设备ID
 */
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
/**错误信息*/
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
#pragma mark - iOS 10 以前收到通知
/**iOS10以前 收到远程通知代理*/
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;
/**本地通知*/
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

@end

NS_ASSUME_NONNULL_END

@interface BasicUserNotification(LocalNotification)

/**
 创建本地时间推送

 @param timeInterval 时间
 @param repeats 是否循环推送（YES:需要设置60s以上）
 @param title 标题
 @param boby 信息
 */
- (void)createLocalNotificationWithTimeInterval:(NSTimeInterval)timeInterval
                                        repeats:(BOOL)repeats
                                          title:(NSString *)title
                                           boby:(NSString *)boby
                                       userInfo:(NSDictionary *)userInfo;
@end
