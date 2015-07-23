//
//  AppDelegate.m
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AppDelegate.h"
#import "ServerRequester.h"
#import "DataSource.h"
#import "LocalNotificationPostponeHandler.h"
#import "EmotionsTimer.h"
#import "FileHandler.h"

@interface AppDelegate ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate>
@property (nonatomic, strong) void (^backgroundFetchBlock) (UIBackgroundFetchResult fetchResult);
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //emotions
    UIMutableUserNotificationCategory *emotionChangePostponeCategory = [[UIMutableUserNotificationCategory alloc] init];
    emotionChangePostponeCategory.identifier = @"changeEmotionCategory";
    
    // for BG fetch
    UIMutableUserNotificationAction *respondAction = [UIMutableUserNotificationAction new];
    respondAction.activationMode = UIUserNotificationActivationModeForeground;
    respondAction.title = NSLocalizedString(@"View", nil);
    respondAction.identifier = @"ViewCurrentEmotion";
    
    UIMutableUserNotificationCategory *lvRespondCategory = [[UIMutableUserNotificationCategory alloc] init];
    //[lvRespondCategory setActions:@[respondAction/*, postponeAction*/] forContext:UIUserNotificationActionContextDefault];
    //[lvRespondCategory setActions:@[respondAction/*, postponeAction*/] forContext:UIUserNotificationActionContextMinimal];
    
    lvRespondCategory.identifier = @"inactiveStateEmotionChangeCategory";
    
    
    
    UIUserNotificationSettings *lvSettings =
    [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                      categories:[NSSet setWithObjects:lvRespondCategory, emotionChangePostponeCategory, nil]];
    
    
    
    [application registerUserNotificationSettings:lvSettings];
    
    // Override point for customization after application launch.
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                           didFinishLaunchingWithOptions:launchOptions];

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
     return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    EmotionsTimer *lvTimer = [[EmotionsTimer alloc] init];
    NSNumber *savedLastAnimationIndex = [[NSUserDefaults standardUserDefaults] objectForKey:Last_Active_Animation];
    if (savedLastAnimationIndex)
    {
        [lvTimer saveBackgroundStartDateWithCurrentEmotionIndex:savedLastAnimationIndex.integerValue];
        //clear UserDefaults
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:Last_Active_Animation];
    }
    [lvTimer postponeNotificationsForKaraQuestions:[DataSource sharedInstance].pendingQuestions];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    EmotionsTimer *lvTimer = [[EmotionsTimer alloc] init];
    
    NSDictionary *currentUser = [[ServerRequester sharedRequester].currentUser toDictionary];
    if (currentUser)
    {
        [[[FileHandler alloc] init] saveCurrentUserToDisk:currentUser];
        //save
        
        [lvTimer clearForegroundStartDate];
        NSNumber *savedLastAnimationIndex = [[NSUserDefaults standardUserDefaults] objectForKey:Last_Active_Animation];
        if (savedLastAnimationIndex)
        {
            [lvTimer saveBackgroundStartDateWithCurrentEmotionIndex:savedLastAnimationIndex.integerValue];
            //clear UserDefaults
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:Last_Active_Animation];
        }
        
        //[lvTimer postponeDecreasingEmotionsChangeNotificationsCurrentEmotion:savedLastAnimationIndex.integerValue];
    }
    else //user could press logout, or something else BAD happened
    {
        //NSLog(@"\r - Clearing saved data...");
        [lvTimer clearBackgroundStartInfo];
        [lvTimer clearForegroundStartDate];
        [lvTimer clearPostponedEmotionsChangeNotifications];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //NSLog(@"\r - \"applicationWillEnterForeground\"  Called____");
    EmotionsTimer *lvTimer = [[EmotionsTimer alloc] init];
    
    //preserve state
    [lvTimer clearBackgroundStartInfo];
    [lvTimer saveForegroundStartDate];
    [lvTimer clearBackgroundEmotionNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
    //start getting languages list and countries list
    if([DataSource sharedInstance].languages.count < 1)
    {
        [[ServerRequester sharedRequester] loadLanguagesWithCompletion:nil];
    }
    
    if ([DataSource sharedInstance].countries.count < 1)
    {
        [[ServerRequester sharedRequester] loadCountriesWithCompletion:nil];
    }
    
    EmotionsTimer *lvTimer = [[EmotionsTimer alloc] init];
    
    //preserve state
    [lvTimer saveForegroundStartDate];
    
    //postpone next emotion change
    FileHandler *lvFiler = [[FileHandler alloc] init];
    if ([lvFiler getSavedUser] != nil)
    {
        NSUInteger emotionToShowOnStart = [lvTimer getCurrentEmotionIndexFromLastBackgroundState];
        [lvTimer postponeNextEmotionChangeInMinutes:5 currentEmotionIndex: emotionToShowOnStart];
    }
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[[FileHandler alloc] init] saveCurrentUserToDisk:[[ServerRequester sharedRequester].currentUser toDictionary]];
}




//UILocalNotification
-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState appState = application.applicationState;
    switch (appState)
    {
        case UIApplicationStateActive:
        {
            //NSLog(@"\r Active Recieved Local Notification:\nAlert: \" %@ \", \nInfo: %@", notification.alertBody, notification.userInfo);
            if ([notification.category isEqualToString:@"changeEmotionCategory"])
            {
                NSDictionary *info = notification.userInfo;
                NSNumber *newEmotion = [info objectForKey:@"idx"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Change_Mood" object:self userInfo:@{@"newMood":newEmotion}];
            }
            else if ([notification.category isEqualToString:@"inactiveStateEmotionChangeCategory"])
            {
                NSNumber *changedEmotion = [notification.userInfo objectForKey:@"idx"];
                if (changedEmotion != nil)
                {
                    [[[EmotionsTimer alloc] init] saveBackgroundStartDateWithCurrentEmotionIndex:changedEmotion.integerValue];// this is needed whan KavaVC checks "getCurrentEmotionIndexFromLastBackgroundState" to return changedEmotion properly;
                }
            }
        }
            break;
//        case UIApplicationStateBackground:
//        {
//            //NSLog(@"\r Background Recieved Local Notification:\nAlert: \" %@ \", \nInfo: %@", notification.alertBody, notification.userInfo);
//        }
//            break;
        case UIApplicationStateInactive:
        {
            //NSLog(@"\r Inactive Recieved Local Notification:\nAlert: \" %@ \", \nInfo: %@", notification.alertBody, notification.userInfo);
            if ([notification.category isEqualToString:@"inactiveStateEmotionChangeCategory"])
            {
                NSNumber *changedEmotion = [notification.userInfo objectForKey:@"idx"];
                if (changedEmotion != nil)
                {
                    [[[EmotionsTimer alloc] init] saveBackgroundStartDateWithCurrentEmotionIndex:changedEmotion.integerValue];// this is needed whan KavaVC checks "getCurrentEmotionIndexFromLastBackgroundState" to return changedEmotion properly;
                }
            }
        }
            break;
        default:
            break;
    }
}

-(void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"ViewCurrentEmotion"])
    {
        EmotionsTimer *lvTimer = [[EmotionsTimer alloc] init];
        NSNumber *changedEmotion = [notification.userInfo objectForKey:@"idx"];
        if (changedEmotion != nil)
        {
            [lvTimer saveBackgroundStartDateWithCurrentEmotionIndex:changedEmotion.integerValue];// this is needed whan KavaVC checks "getCurrentEmotionIndexFromLastBackgroundState" to return changedEmotion properly;
            
        }
        [lvTimer clearBackgroundEmotionNotifications];
    }
    
    completionHandler();
}

//-(void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    for (UIUserNotificationCategory *lvCategory in notificationSettings.categories.allObjects)
//    {
//        NSLog(@"Registered for \" %@ \" ", lvCategory.identifier);
//    }
//}




// // background fetch
//- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    self.backgroundFetchBlock = completionHandler;
//    
//    User *lastSavedUser = [User userFromJSON:[[[FileHandler alloc] init] getSavedUser]];
//    if (!lastSavedUser) //do not try any more, because some error occured while saving user info to disk
//    {
//        [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
//        completionHandler(UIBackgroundFetchResultFailed);
//        return;
//    }
//    
//    
//    [ServerRequester sharedRequester].currentUser = lastSavedUser;
//    
//    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
// 
//    //NSURL *url = [[NSURL alloc] initWithString:@"http://yourserver.com/data.json"];
//    //NSURLSessionDataTask *backgroundTask = [[NSURLSessionDataTask alloc] init];
//   
//    NSString *urlString = [NSString stringWithFormat:@"%@GetNewMessages?token=%@", BasicURL, lastSavedUser.token];
//    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:urlString]
//                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//    {
//        if (data)
//        {
//            NSError *lvError;
//            NSDictionary *lvResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&lvError];
//            if ([lvResponse objectForKey:@"GetNewMessagesResult"] != nil)
//            {
//                NSArray *lvNewMessagesRaw = [lvResponse objectForKey:@"GetNewMessagesResult"];
//                if (lvNewMessagesRaw.count > 0)
//                {
//                    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
//                    
//                    
//                }
//                else
//                {
//                    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
//                    completionHandler(UIBackgroundFetchResultNoData);
//                }
//            }
//        }
//                                          
//    }];
//    
//    
//    // Start the task
//    [task resume];
//}
//
//-(void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
//{
//
//}
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
//    didReceiveData:(NSData *)data
//{
//    
//}
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
//didCompleteWithError:(NSError *)error
//{
//    
//}
//
//-(void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
//{
//    
//}
@end
