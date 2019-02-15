//
//  BasicUserNotification.m
//  CustomKVO
//
//  Created by L on 2019/2/14.
//  Copyright © 2019 L. All rights reserved.
//

#import "BasicUserNotification.h"
#import <CoreLocation/CoreLocation.h>


@implementation BasicUserNotification
+ (instancetype)shareNotification{
    static BasicUserNotification *notification = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notification = [[BasicUserNotification alloc]init];
    });
    return notification;
}
#pragma mark - Registe Notification Configuration
- (void)registeUserNotificationConfig{
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter]requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"设置成功");
            }
        }];
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"获取用户的推送通知设置");
        }];
    }

    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){//iOS8-iOS9
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    } else {//iOS8以下
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
#pragma clang diagnostic pop
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];


}

#pragma mark - UNUserNotificationCenterDelegate
/**iOS10 App处于前台接收通知时*/
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)){
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    //分组显示的标识 iOS12 支持分组显示推送通知
    NSString *threadIdentifier = content.threadIdentifier;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
    } else {
        // 判断为本地通知
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10前台接收通知时本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n\\\\threadIdentifier：%@\\\\n}",
              body,
              title,
              subtitle,
              badge,
              sound,
              userInfo,
              threadIdentifier);
        
        
    }
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
}

//App通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    //收到推送的内容
    UNNotificationContent *content = request.content;
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    NSLog(@"%@",userInfo);
    if([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]){
        NSLog(@"收到的远程通知");
    }else if ([request.trigger isKindOfClass:[UNTimeIntervalNotificationTrigger class]]){
        NSLog(@"收到的是定时器本地通知");
    }else if ([request.trigger isKindOfClass:[UNCalendarNotificationTrigger class]]){
        NSLog(@"收到的是日期本地通知");
    }else if ([request.trigger isKindOfClass:[UNLocationNotificationTrigger class]]){
        NSLog(@"收到的是地址本地通知");
    }

}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification  API_AVAILABLE(ios(10.0)){
}
#pragma mark - AppDelegate
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceTokenString = deviceTokenString;
}
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@",error);
}
#pragma mark - iOS 10之前 Notification Deleaget
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}
- (void)didReceiveLocalNotification:(UILocalNotification *)notification{
    
}
@end

@implementation BasicUserNotification(LocalNotification)


- (void)createLocalNotificationWithTimeInterval:(NSTimeInterval)timeInterval
                                        repeats:(BOOL)repeats
                                          title:(NSString *)title
                                       boby:(NSString *)boby
                                       userInfo:(NSDictionary *)userInfo
{
    if (@available(iOS 10.0, *)) {
        UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval repeats:repeats];
//        //每周一早上 8：00 提醒我给老婆做早饭
//        NSDateComponents *components = [[NSDateComponents alloc] init];
//        components.weekday = 2;
//        components.hour = 8;
//        UNCalendarNotificationTrigger *trigger3 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
//
//        //一到麦当劳就喊我下车
//        CLRegion *region = [[CLRegion alloc] init];
//        UNLocationNotificationTrigger *trigger4 = [UNLocationNotificationTrigger triggerWithRegion:region repeats:NO];
        UNMutableNotificationContent *centent = [[UNMutableNotificationContent alloc]init];
        centent.title = title;
        centent.body = boby;
        centent.threadIdentifier = @"本地推送";
        centent.userInfo = userInfo;
        NSString *requestIdentifier = @"sampleRequest";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                              content:centent
                                                                              trigger:timeTrigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
        
    } else {
        // Fallback on earlier versions
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        // 发出推送的日期
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
        // 推送的内容
        notif.alertBody = boby;
        // 可以添加特定信息
        notif.alertTitle = title;
        // 角标
        // 提示音
        notif.soundName = UILocalNotificationDefaultSoundName;
        notif.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        
    }
}
@end
