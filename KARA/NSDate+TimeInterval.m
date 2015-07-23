
/*
 NSDate+TimeInterval.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "NSDate+TimeInterval.h"

@implementation NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval
{
//    NSString *localDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [[NSDate alloc] init];
    
    
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    
    NSUInteger unitFlags =
    NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour |
    NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    return [calendar components:unitFlags
                       fromDate:date1
                         toDate:date2
                        options:0];
}

+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSDateComponents *components = [self.class componetsWithTimeInterval:timeInterval];
    
    if (components.year < 0)
    {
//        if (components.month != 0)
//        {
//            NSString *toReturn = [NSString stringWithFormat:@"%ld y, %ld m", (long)components.year,(long)components.month];
//            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
//        else
//        {
        NSMutableString *yearString = [@"years" mutableCopy];
        if (components.year == -1)
        {
            yearString = [@"year" mutableCopy];
        }
            NSString *toReturn = [NSString stringWithFormat:@"%ld %@",(long)components.year, [NSString stringWithString:yearString]];
            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
    }
    else if (components.month < 0)
    {
//        if (components.day != 0)
//        {
//            NSString *toReturn = [NSString stringWithFormat:@"%ld m, %ld d", (long)components.month, (long)components.day];
//            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
//        else
//        {
        NSMutableString *monthString = [@"months" mutableCopy];
        if (components.month == -1)
        {
            monthString = [@"month" mutableCopy];
        }
            NSString *toReturn = [NSString stringWithFormat:@"%ld %@", (long)components.month, [NSString stringWithString:monthString]];
            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
    }
    else if (components.day < 0)
    {
//        if (components.hour != 0)
//        {
//            NSString *toReturn = [NSString stringWithFormat:@"%ld d, %ld h", (long)components.day, (long)components.hour];
//            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
//        else
//        {
        NSMutableString *dayString = [@"days" mutableCopy];
        if (components.day == -1)
        {
            dayString = [@"day" mutableCopy];
        }
            NSString *toReturn = [NSString stringWithFormat:@"%ld %@", (long)components.day, [NSString stringWithString:dayString]];
            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
        
    }
    else if (components.hour < 0)
    {
//        if (components.minute != 0)
//        {
//            NSString *toReturn = [NSString stringWithFormat:@"%ld h %02ld m", (long)components.hour, (long)components.minute];
//            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
//        else
//        {
        NSMutableString *hourString = [@"hours" mutableCopy];
        if (components.hour == -1)
        {
            hourString = [@"hour" mutableCopy];
        }
            NSString *toReturn = [NSString stringWithFormat:@"%ld %@", (long)components.hour, [NSString stringWithString:hourString]];
            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        }
        
    }
    else
    {
        if (components.minute != 0)
        {
            NSString *toReturn = [NSString stringWithFormat:@"%ld min "/*%02ld s"*/, (long)components.minute/*, (long)components.second*/];
            return [toReturn stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
        else
            return @"just now";
    }    
}


@end
