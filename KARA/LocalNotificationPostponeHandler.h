//
//  LocalNotificationPostponeHandler.h
//  CallAlign
//
//  Created by Ivan on 28.11.14.
//  Copyright (c) 2014 Ivan Iavorin. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "UIWindow+VisibleViewController.h"
@interface LocalNotificationPostponeHandler : NSObject//<UIAlertViewDelegate> //for iOS prior to 8

@property (nonatomic, strong) NSString *callNumber;
@property (nonatomic, strong) NSNumber *postponeInterval;

-(void) postponeLocalNotificationWithMessage:(NSString *)message postponeDate:(NSDate *)targetDate userInfo:(NSDictionary *)userInfo;

-(void) cancelAllNotifications;

-(void) postponeChangeEmotionLocalNotificationInMinutes:(NSTimeInterval) minutes newEmotion:(NSInteger) emotionIndex;

-(void) cancelChangeEmotionNotifications;

-(void) cancelBackgroundChangeEmotionNotifications;
@end
