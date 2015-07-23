//
//  Constants.h
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#ifndef Origami_Constants_h

#define Origami_Constants_h

#endif


#define AUTH_TYPE_FACEBOOK @"Auth_Type_Facebook"
#define AUTH_TYPE_TWITTER @"Auth_Type_Twitter"
#define AUTH_TYPE_EMAIL @"Auth_Type_Email"

#define CURRENT_USER_NAME @"CurrentLogin"
#define CURRENT_USER_PASSWORD @"CurrentPassword"
#define CURRENT_USER_AUTH_TYPE @"Current_Auth_Type"
#define CURRENT_USER_TOKEN @"Current_User_Token"

#define SOUNDS_ENABLED @"SoundsEnabled"

//#define LICENSE_ACCEPTED @"License_Agreement_Accepted"

#define Global_Tint_Color [UIColor colorWithRed:215.0/255.0 green:100.0/255.0 blue:96.0/255.0 alpha:1.0]
#define Global_Tint_Color_Semitramsparent [UIColor colorWithRed:215.0/255.0 green:100.0/255.0 blue:96.0/255.0 alpha:0.85]
//#define Global_Tint_Color [UIColor colorWithRed:115.0/255.0 green:9.0/255.0 blue:7.0/255.0 alpha:1.0]
#define Global_Border_Color [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0]
#define dictNULL [NSNull null]

#define LAST_UNRATED_EMOTIONS_PAIR @"Last_Unrated_Emotions_Pair"
#define LAST_WORD_ASSOTIATION @"Last_Word_Assotiation"
#define LAST_WORDS_CCONNECTION @"Last_Words_Connection"

#define Animation_Names_Array @[@"pain", @"sorrow", @"anxiety", @"apathy", @"ambience",  @"interest", @"confidence", @"joy", @"enjoyment"]

#define degreesToRadians(x) (M_PI * x / 180.0)

#define Background_Start_Info @"BackgroundStartInfo"
#define Foreground_Start_Date @"ForegroundStartDate"
#define Last_Active_Animation @"LastActiveAnimation"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)