//
//  NSString+ServerDate.m
//  Origami
//
//  Created by CloudCraft on 04.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "NSString+ServerDate.h"

@implementation NSString (ServerDate)

-(NSString*)dateStringFromServerDateString
{
    NSCharacterSet *badCharacters = [NSCharacterSet characterSetWithCharactersInString:@"1234567890-+"].invertedSet;
    NSString *withUTC = [self stringByTrimmingCharactersInSet:badCharacters];
    if (withUTC.length < 5)
    {
        return nil;
    }
    //NSString *correctionGMT = [withUTC substringFromIndex:withUTC.length - 5];
    
    //TODO: detect and handle GMT properly
    //NSTimeInterval gmtInterval = [correctionGMT integerValue];
    
    NSString *cleanString = [withUTC substringToIndex:withUTC.length - 5]; //nanoseconds
    
    if (cleanString.length < 3)
    {
        return nil;
    }
    //remove 3 last characters
    cleanString = [cleanString substringWithRange:NSMakeRange(0, cleanString.length - 3)];
    
    
    NSTimeInterval currentTimeInterval = cleanString.integerValue;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:currentTimeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *string = [dateFormatter stringFromDate:date];
    
    return string;
}

-(NSString *)timeDateStringFromServerDateString
{
    NSCharacterSet *badCharacters = [NSCharacterSet characterSetWithCharactersInString:@"1234567890-+"].invertedSet;
    NSString *cleanString = [self stringByTrimmingCharactersInSet:badCharacters];
    if (cleanString.length < 5)
    {
        return nil;
    }
    cleanString = [cleanString substringToIndex:cleanString.length - 5];
    //remove 3 last characters - they are nanoseconds
    if (cleanString.length < 3)
    {
        return nil;
    }
    cleanString = [cleanString substringWithRange:NSMakeRange(0, cleanString.length - 3)];
    NSTimeInterval currentTimeInterval = cleanString.integerValue;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:currentTimeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSString *dateTime = [dateFormatter stringFromDate:date];

    return dateTime;
}

-(NSDate *) dateFromServerDateString
{
    //@"/(Date)-455663455+0200/"
//    NSLog(@"Date To convert from Server Format: %@", self);
    NSCharacterSet *badCharacters = [NSCharacterSet characterSetWithCharactersInString:@"1234567890-+"].invertedSet;
    NSString *dateUTCString = [self stringByTrimmingCharactersInSet:badCharacters];
    
    if (dateUTCString.length < 5)
    {
        return nil;
    }
    NSString *dateValueString = [dateUTCString substringToIndex:dateUTCString.length - 5];
    if (dateValueString.length < 3)
    {
        return nil;
    }
    dateValueString = [dateValueString substringToIndex:dateValueString.length - 3];
//    NSString *utcValueString = [dateUTCString stringByReplacingOccurrencesOfString:dateValueString withString:@""];
    
    NSTimeInterval timeInterval = [dateValueString integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return date;
}

@end
