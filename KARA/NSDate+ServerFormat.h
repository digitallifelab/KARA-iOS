//
//  NSDate+ServerFormat.h
//  Origami
//
//  Created by CloudCraft on 18.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ServerFormat)

-(NSString *) dateForServer;

-(NSString *) timeDateForDisplay;

+(NSString *) dummyDate;

+(NSString *) fileNameDate;

@end
