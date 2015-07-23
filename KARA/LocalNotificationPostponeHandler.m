//
//  LocalNotificationPostponeHandler.m
//  CallAlign
//
//  Created by Ivan on 28.11.14.
//  Copyright (c) 2014 Ivan Iavorin. All rights reserved.
//

#import "LocalNotificationPostponeHandler.h"
//#import "LocalDBWorker.h"
//#import "DBContact.h"
#import "Constants.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UILocalNotification.h>
#import <UIKit/UIUserNotificationSettings.h>
@implementation LocalNotificationPostponeHandler


-(void) postponeLocalNotificationWithMessage:(NSString *)message postponeDate:(NSDate *)targetDate userInfo:(NSDictionary *)userInfo
{
    
    NSString *lvAlertBody = message;// [NSString stringWithFormat:@"Позвонить %@ %@\n%@", lvFirstName, lvLastName, lvPhoneNumber];

    UILocalNotification *lvLocalNotif = [[UILocalNotification alloc] init];
    lvLocalNotif.category = @"inactiveStateEmotionChangeCategory";
        
    //NSDate *wandetFireDate = [NSDate dateWithTimeIntervalSinceNow:interval * 60]; // time in minutes
    
    lvLocalNotif.fireDate = targetDate;
    lvLocalNotif.alertBody = lvAlertBody;
    if (userInfo)
    {
        lvLocalNotif.userInfo = userInfo;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:lvLocalNotif];
    //NSLog(@"Postponed Local Notification: %@, \r - FireDate: %@", message, lvLocalNotif.fireDate);
}

- (void) postponeChangeEmotionLocalNotificationInMinutes:(NSTimeInterval)minutes newEmotion:(NSInteger)emotionIndex
{
    
    [self cancelChangeEmotionNotifications];
    
    //prepave values
//#ifdef DEBUG
//     minutes *= 10.0;
//#else
    minutes *= 60.0;
//#endif

    NSDictionary *infoToPostpone = [NSDictionary dictionaryWithObjectsAndKeys:@(emotionIndex),@"idx", nil];
    //prepare local notification
    UILocalNotification *lvEmotionChangeNotif = [[UILocalNotification alloc] init];
    lvEmotionChangeNotif.category = @"changeEmotionCategory";
    lvEmotionChangeNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:minutes];
    lvEmotionChangeNotif.userInfo = infoToPostpone;
    
    //postpone notification
    [[UIApplication sharedApplication] scheduleLocalNotification:lvEmotionChangeNotif];
    
}

-(void) cancelAllNotifications
{
//    NSLog(@"\r - Clearing Local Notifications______________________|");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void) cancelChangeEmotionNotifications
{
//     NSLog(@"\r - Clearing \"EmotionChange\" Notifications______....._________|");
    //cancel previously postponed notifications if any exist
    for (UILocalNotification *lvScheduledNotif in [UIApplication sharedApplication].scheduledLocalNotifications)
    {
        if ([lvScheduledNotif.category isEqualToString:@"changeEmotionCategory"])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:lvScheduledNotif];
        }
    }
}

-(void) cancelBackgroundChangeEmotionNotifications
{
//    NSLog(@"\r - Clearing \"inactiveStateEmotionChangeCategory\" Notifications______....._________|");
    //cancel previously postponed notifications if any exist
    for (UILocalNotification *lvScheduledNotif in [UIApplication sharedApplication].scheduledLocalNotifications)
    {
        if ([lvScheduledNotif.category isEqualToString:@"inactiveStateEmotionChangeCategory"])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:lvScheduledNotif];
        }
    }
}



@end
