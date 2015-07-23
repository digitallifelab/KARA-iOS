//
//  EmotionsTimer.h
//  KARA
//
//  Created by CloudCraft on 14.05.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LocalNotificationPostponeHandler.h"
@interface EmotionsTimer : NSObject

- (void) saveForegroundStartDate;
- (void) saveBackgroundStartDateWithCurrentEmotionIndex:(NSInteger) emotionIndex;

- (NSDate *) getForegroundStartDate;
- (NSDictionary *) getBackgroundStartInfo;

- (void) clearBackgroundStartInfo;
- (void) clearForegroundStartDate;

- (void) postponeNextEmotionChangeInMinutes:(NSTimeInterval)minutes currentEmotionIndex:(NSInteger) emotionIndex;

- (void) postponeNotificationsForKaraQuestions:(NSArray *)questions;

- (NSUInteger) getCurrentEmotionIndexFromLastBackgroundState;
- (void) clearPostponedEmotionsChangeNotifications;

- (void) postponeDecreasingEmotionsChangeNotificationsCurrentEmotion:(NSUInteger) currentEmotionIndex;
- (void) clearBackgroundEmotionNotifications;
@end
