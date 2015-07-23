//
//  Country.m
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "CountryObject.h"

@implementation CountryObject

-(instancetype) initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if  (self)
    {
        self.countryId = [info objectForKey:@"Id"];
        self.countryName = [info objectForKey:@"Name"];
    }
    return self;
}

@end
