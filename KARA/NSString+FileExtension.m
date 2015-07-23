//
//  NSString+FileExtension.m
//  Origami
//
//  Created by CloudCraft on 25.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "NSString+FileExtension.h"

@implementation NSString (FileExtension)

- (NSString *)fileExtensionFromFileName
{
    NSRange rangeToSearch = NSMakeRange(0, self.length);
    NSRange dotRange = [self rangeOfString:@"." options:NSBackwardsSearch range:rangeToSearch];
    NSRange rangeToDot = NSMakeRange(0, dotRange.location);
    NSString *extension = [self stringByReplacingCharactersInRange:rangeToDot withString:@""];
    NSString *withoutDot = [extension stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (withoutDot && withoutDot.length > 0)
    {
        return withoutDot;
    }
    else
        return @"unknown";
}

@end
