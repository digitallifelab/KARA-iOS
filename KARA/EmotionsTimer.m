//
//  EmotionsTimer.m
//  KARA
//
//  Created by CloudCraft on 14.05.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "EmotionsTimer.h"
#import "Message.h"
#import "NSDate+TimeInterval.h"
@implementation EmotionsTimer

- (void) saveForegroundStartDate
{
    NSDate *currentDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:Foreground_Start_Date];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveBackgroundStartDateWithCurrentEmotionIndex:(NSInteger) emotionIndex
{
    NSDate *currentDate = [NSDate date];
    NSDictionary *infoToStore = [NSDictionary dictionaryWithObjectsAndKeys:@(emotionIndex),@"idx", currentDate,@"date", nil];
    [[NSUserDefaults standardUserDefaults] setObject:infoToStore forKey:Background_Start_Info];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *) getForegroundStartDate
{
    NSDate *fgStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:Foreground_Start_Date];
    return fgStartDate;
}

- (NSDictionary *) getBackgroundStartInfo
{
    NSDictionary *bgStartInfo = [[NSUserDefaults standardUserDefaults] objectForKey:Background_Start_Info];
    return bgStartInfo;
}

- (void) clearBackgroundStartInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Background_Start_Info];
}

- (void) clearForegroundStartDate
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Foreground_Start_Date];
}


- (NSUInteger) getCurrentEmotionIndexFromLastBackgroundState
{
    NSDictionary *savedInfo = [self getBackgroundStartInfo];
    if (!savedInfo)
    {
        return 4;
    }
    else
    {
        NSInteger emotionIndexToReturn =  ((NSNumber *)[savedInfo objectForKey:@"idx"]).integerValue;
        NSDate *currentDate = [NSDate date];
        NSDate *bgDate = [savedInfo objectForKey:@"date"];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags =
        /*NSCalendarUnitSecond |*/ NSCalendarUnitMinute | NSCalendarUnitHour  |
        NSCalendarUnitDay;// | NSCalendarUnitMonth | NSCalendarUnitYear;
        
        NSDateComponents *components = [calendar components:unitFlags fromDate:bgDate toDate:currentDate options:0];
        // NSInteger years = components.year;
        // NSInteger months = components.month;
        NSInteger days = components.day;
        NSInteger hours = components.hour;
        NSInteger minutes = components.minute;
        //NSInteger seconds = components.second;
        
        if (days > 0)
        {
            return 4;
        }
        else if (hours > 0)
        {
            emotionIndexToReturn -= hours;
        }
        else
        {
            if( minutes <= 30) //app was in foreground less than 30 minutes ago, don`t change emotion
            {
                return emotionIndexToReturn;
            }
            else
            {
                emotionIndexToReturn -= 1;
            }
        }
        
        
        //never return lowest emotion("0") or negative value
        if (emotionIndexToReturn < 1)
        {
            emotionIndexToReturn = 1;
        }
        //NSLog(@"\r - Returning emotionIndex: \"%lu\"", (unsigned long)emotionIndexToReturn);
        return emotionIndexToReturn;
    }
}

-(void) postponeNextEmotionChangeInMinutes:(NSTimeInterval)minutes currentEmotionIndex:(NSInteger) emotionIndex
{
    LocalNotificationPostponeHandler *lvNotifHandler = [[LocalNotificationPostponeHandler alloc] init];
    NSInteger validEmotionIndex = MIN(8, MAX(0, emotionIndex));
    CGFloat validMinutes = MAX(1, MIN(10, minutes));
    if (validEmotionIndex < 4)// if we happen to be in "negative emotions" state, within 5 minutes user spent in App we change emotion to "ambient"
    {
        if (validMinutes < 5)
        {
            [lvNotifHandler postponeChangeEmotionLocalNotificationInMinutes:validMinutes newEmotion:validEmotionIndex];
            
            //NSLog(@"\r - Postponing Local Notification to change emotion in %f minutes for newIndex: %ld", validMinutes, (long)validEmotionIndex);
        }
        else
        {
            [lvNotifHandler postponeChangeEmotionLocalNotificationInMinutes:5 newEmotion:4];
            //NSLog(@"\r - Postponing Local Notification to change emotion to \"Ambient\" in 5 minutes");
        }
    }
    else
    {
        if (validEmotionIndex < 8)
        {
            //double check
            NSInteger nextEmotionIndex = validEmotionIndex + 1;
            if (nextEmotionIndex > 5)
            {
                validMinutes = 10;
            }
            //production
            [lvNotifHandler postponeChangeEmotionLocalNotificationInMinutes:validMinutes newEmotion:nextEmotionIndex];
        
            //NSLog(@"\r - Postponing Local Notification to change emotion in %f minutes for newIndex: %ld", validMinutes, (long)nextEmotionIndex);
        }
        else
        {
            [lvNotifHandler postponeChangeEmotionLocalNotificationInMinutes:validEmotionIndex newEmotion:validEmotionIndex];
            //NSLog(@"\r Will not postpone next animation change: current animation is top. Postponing to trigger possible random video to play");
        }
    }
}


-(void) clearPostponedEmotionsChangeNotifications
{
    LocalNotificationPostponeHandler *lvNotifHandler = [[LocalNotificationPostponeHandler alloc] init];
    [lvNotifHandler cancelChangeEmotionNotifications];
}

-(void) postponeDecreasingEmotionsChangeNotificationsCurrentEmotion:(NSUInteger) currentEmotionIndex
{
    [self clearBackgroundEmotionNotifications];
    
    if (currentEmotionIndex > 1)
    {
        LocalNotificationPostponeHandler *lvNotifHandler = [[LocalNotificationPostponeHandler alloc] init];
        NSString *messageKara = NSLocalizedString(@"KaraChangedEmotion", nil);
        NSArray *animationKeys = Animation_Names_Array;
        //create localized emotion names
        NSMutableArray *localizedNames = [[NSMutableArray alloc] initWithCapacity:animationKeys.count];
        for (NSString *lvName in animationKeys)
        {
            [localizedNames addObject:NSLocalizedString(lvName, nil)];
        }
        
        //show notifications till 9 PM of today
        NSDate *ninePmOfToday = [self todayBorderDate];
        
        NSTimeInterval postponeTime = 31.0; //before 30 minutes Kara does not change(decrease) emotion
        for (NSInteger i = currentEmotionIndex - 1; i > 0; i--)
        {
            NSDate *wandedPostponeDate = [NSDate dateWithTimeIntervalSinceNow:postponeTime * 60];
            
            postponeTime += 60.0;
            if ([ninePmOfToday compare:wandedPostponeDate] == NSOrderedDescending)
            {
                continue;
            }
            NSString *lvNotificationMessage = [NSString stringWithFormat:@"%@ : %@", messageKara, [localizedNames objectAtIndex:i]];
            [lvNotifHandler postponeLocalNotificationWithMessage:lvNotificationMessage
                                                    postponeDate:wandedPostponeDate
                                                        userInfo:@{@"idx":@(i)}];
        }
    }
//    else
//    {
//        NSLog(@"\n - WARNING: \nCurrent emotion is preLast. Do not postpone any changes to lowest emotion.\n");
//    }
}

-(void) postponeNotificationsForKaraQuestions:(NSArray *)questions
{
    if (questions && questions.count > 0)
    {
        LocalNotificationPostponeHandler *lvPostponeHandler = [[LocalNotificationPostponeHandler alloc] init];
        NSDate *today9PM = [self todayBorderDate];
        NSDate *tomorrowMorning = [self tomorrowDateForTimeHours:11];
        NSInteger questionsCount = questions.count;
        
        NSTimeInterval postponeTime = 0;
        for (NSInteger i = 0; i < questionsCount; i++)
        {
            postponeTime += 4*60*60; //4 hours
            NSDate *targetPostponeTime = [NSDate dateWithTimeIntervalSinceNow:postponeTime];
            Message *lvMessage = [questions objectAtIndex:i];
            NSString *notificationMessage = [self makeReadableMessageFromMessageObject:lvMessage];
            if ([today9PM compare:targetPostponeTime] == NSOrderedAscending)// if later than today - just postpone 1 notification to tomorrow`s morning
            {
                targetPostponeTime = tomorrowMorning;
                [lvPostponeHandler postponeLocalNotificationWithMessage:notificationMessage postponeDate:targetPostponeTime userInfo:nil];
                return;
            }
            
            [lvPostponeHandler postponeLocalNotificationWithMessage:notificationMessage postponeDate:targetPostponeTime userInfo:nil];
        }
    }
//    else
//    {
//        NSLog(@"\n - ERROR: \rNo Questions to postpone every 4 hours and in the morning.  Probably user has logged out...");
//    }
}

-(void) clearBackgroundEmotionNotifications
{
    LocalNotificationPostponeHandler *lvLocalNotifier = [[LocalNotificationPostponeHandler alloc] init];
    [lvLocalNotifier cancelBackgroundChangeEmotionNotifications];
}


-(NSDate *)todayBorderDate
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *comps =
    [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour| NSCalendarUnitMinute)
           fromDate:currentDate];
   
    [comps setHour:21];
    [comps setMinute:0];
    [comps setSecond:0];
    
    NSDate *ninePmOfToday = [cal dateFromComponents:comps];
    
    return ninePmOfToday;
}

-(NSDate *)tomorrowDateForTimeHours:(NSInteger) hours
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *comps =
    [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour| NSCalendarUnitMinute)
           fromDate:currentDate];
    
    [comps setHour:hours];
    [comps setMinute:0];
    [comps setSecond:0];
    comps.day += 1;
    
    NSDate *tomorrowAtTime = [cal dateFromComponents:comps];
    
    return tomorrowAtTime;
}

-(NSString *)makeReadableMessageFromMessageObject:(Message *)messageObject
{
    return messageObject.textBody;
}

@end
