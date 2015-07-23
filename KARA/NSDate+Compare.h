//
//  NSDate+Compare.h
//  Origami
//
//  Created by CloudCraft on 05.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Compare)


- (NSComparisonResult)compareDateOnly:(NSDate *)otherDate;

-(BOOL) lessThanMonthAgo;

@end
