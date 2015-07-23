//
//  NSString+ServerDate.h
//  Origami
//
//  Created by CloudCraft on 04.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ServerDate)

-(NSString *) dateStringFromServerDateString;

-(NSString *) timeDateStringFromServerDateString;

-(NSDate *)  dateFromServerDateString;


@end
