//
//  WordEcho.h
//  KARA
//
//  Created by CloudCraft on 16.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordEcho : NSObject


@property (nonatomic, strong) NSNumber *ratingCount;
@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, strong) NSString *word;

-(instancetype) initWithInfo:(NSDictionary *)info;
-(BOOL) isEqual:(WordEcho *)object;
-(NSUInteger)hash;

@end
