//
//  ChatMessage.h
//  Origami
//
//  Created by CloudCraft on 09.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, strong) NSNumber *messageId;
@property (nonatomic, strong) NSNumber *elementId;   // id of chat
@property (nonatomic, strong) NSNumber *creatorId;   // my id or contact id
@property (nonatomic, strong) NSNumber *typeId;

/*
 0 - chat message (user`s answer), 
 1 - invitation, 
 4 - On(Off)line,
 7 - assotiation QUESTION,
 8 - connection between words QUESTION,
 9 - range words QUESTION,
 10 - user`s opinion, 
 11 - change mood animation, 
 12 - changed user info, 
 13 - changed user photo, 
 14 - definition QUESTION
 */
@property (nonatomic, strong) NSNumber *isNew;       // boolean
@property (nonatomic, strong) NSString *textBody;    // the message itself
@property (nonatomic, strong) NSString *firstName;   // first name of message author
@property (nonatomic, strong) NSDate *dateCreated; // date, message was sent to server


-(instancetype) initWithParams:(NSDictionary *)params;

-(NSDictionary *)toStoredDictionary;

//-(NSDictionary *) descriptSelf;
-(BOOL) isEqual:(Message *)object;
-(NSUInteger) hash;

@end

/*
 
 4 НАСЛАЖДЕНИЕ - Enjoyment
 3 РАДОСТЬ - Joy
 2 УВЕРЕННОСТЬ - confidence
 1 ИНТЕРЕС - interest
 0 СПОКОЙСТВИЕ - ambience
 -1 АПАТИЯ - apathy
 -2 ТРЕВОГА - anxiety
 -3 ГРУСТЬ - sorrow
 -4 БОЛЬ - pain
 
*/