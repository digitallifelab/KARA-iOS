//
//  WordEcho.m
//  KARA
//
//  Created by CloudCraft on 16.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "WordEcho.h"

@implementation WordEcho
/*
 public class WordEcho
 {
 public int Count { get; set; }
 public string KeyWord { get; set; }
 public string Word { get; set; }
 }
 */
-(instancetype) initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        self.ratingCount = [info objectForKey:@"Count"];
        
        NSString *capitalizedKeyWord = [[info objectForKey:@"KeyWord"] capitalizedString];
        self.keyWord = capitalizedKeyWord;
        
        NSString *capitalizedWord = [[info objectForKey:@"Word"] capitalizedString];
        self.word = capitalizedWord;
    }
    return self;
}

- (BOOL)isEqual:(WordEcho *)object
{
    if (![object isKindOfClass:[WordEcho class]])
    {
        return NO;
    }
    if (object == self)
    {
        return YES;
    }
    
    if (object.ratingCount.integerValue == self.ratingCount.integerValue && [object.keyWord isEqualToString:self.keyWord] && [object.word isEqualToString:self.word])
    {
        return YES;
    }
    
    return NO;
}

-(NSUInteger)hash
{
    return self.keyWord.hash ^ self.word.hash;
}

@end
