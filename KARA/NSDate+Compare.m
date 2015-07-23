//
//  NSDate+Compare.m
//  Origami
//
//  Created by CloudCraft on 05.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "NSDate+Compare.h"

@implementation NSDate (Compare)

- (NSComparisonResult)compareDateOnly:(NSDate *)otherDate
{
    NSUInteger dateFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *otherCompents = [gregorianCalendar components:dateFlags fromDate:otherDate];
    NSDate *otherDateOnly = [gregorianCalendar dateFromComponents:otherCompents];
    
    NSDateComponents *selfComponents = [gregorianCalendar components:dateFlags fromDate:self];
    NSDate *selfDateOnly = [gregorianCalendar dateFromComponents:selfComponents];
    
    NSComparisonResult toReturn = [selfDateOnly compare:otherDateOnly]; //NSOrderedAscending if self is earlier than otherDate
    
    return toReturn;
}

-(BOOL) lessThanMonthAgo
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    
    NSDate *today = [cal dateFromComponents:comps];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay: -31];
    
    NSDate *monthAgo = [cal dateByAddingComponents:components toDate:today options:0];
    
    NSComparisonResult comprarison = [self compareDateOnly:monthAgo];
    
    BOOL toReturn = (comprarison != NSOrderedAscending);
    return toReturn;
}

@end
