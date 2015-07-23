//
//  NSDate+ServerFormat.m
//  Origami
//
//  Created by CloudCraft on 18.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "NSDate+ServerFormat.h"

@implementation NSDate (ServerFormat)

-(NSString *) dateForServer
{
    //NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    //NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:self];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:self];
    //NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    //NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:self];
    
    NSTimeInterval interval = [self timeIntervalSince1970];
    
    
    NSString *offsetString;
    if (gmtOffset >= 0 && gmtOffset <= 9)
        offsetString = [NSString stringWithFormat:@"+0%ld", (long)gmtOffset];
    else if (gmtOffset > 9)
        offsetString = [NSString stringWithFormat:@"+%ld", (long)gmtOffset];
    else if (gmtOffset < 0 && gmtOffset >= - 9)
        offsetString = [NSString stringWithFormat:@"-0%ld", (long)(gmtOffset * -1)];
    else
        offsetString = [NSString stringWithFormat:@"-%ld", (long)(gmtOffset * -1)];
        
    NSString *dateString = [NSString stringWithFormat:@"/Date(%ld000%@00)/", (long)interval, offsetString];
    
    return dateString;
}

- (NSString *) timeDateForDisplay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    NSString *dateTime = [dateFormatter stringFromDate:self];
    
    return dateTime;
}

+(NSString *) dummyDate
{
    return @"/Date(0)/";
}

+(NSString *) fileNameDate
{
    NSDate *currentDate = [self date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSMutableString *withoutExtension = [[dateFormatter stringFromDate:currentDate] mutableCopy];
    [withoutExtension replaceOccurrencesOfString:@" " withString:@"-" options:NSDiacriticInsensitiveSearch range:NSMakeRange(0, withoutExtension.length)];
    [withoutExtension replaceOccurrencesOfString:@"," withString:@"-at" options:NSDiacriticInsensitiveSearch range:NSMakeRange(0, withoutExtension.length)];
    [withoutExtension replaceOccurrencesOfString:@":" withString:@"-" options:NSDiacriticInsensitiveSearch range:NSMakeRange(0, withoutExtension.length)];
    [withoutExtension appendString:@".png"];
    
    return withoutExtension;
}
@end
