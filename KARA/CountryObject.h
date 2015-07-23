//
//  Country.h
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryObject : NSObject

@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSNumber *countryId;

-(instancetype) initWithInfo:(NSDictionary *)info;

@end
