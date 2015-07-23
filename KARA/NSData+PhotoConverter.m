//
//  NSData+PhotoConverter.m
//  Origami
//
//  Created by CloudCraft on 24.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "NSData+PhotoConverter.h"

@implementation NSData (PhotoConverter)
+(NSData *)dataFromIntegersArray:(NSArray *)integersArray
{
    if (integersArray != nil)
    {
        NSMutableData *mutableSelf = [NSMutableData dataWithCapacity:integersArray.count];
        for (NSNumber *digit in integersArray)
        {
            NSInteger currentDigit = [digit integerValue];
            NSData *lvDigitData = [[NSData alloc] initWithBytes:&currentDigit length:1];
            
            [mutableSelf appendData:lvDigitData];
        }
        
        return mutableSelf;
    }
    else
        return nil;
    
}
@end
