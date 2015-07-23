//
//  Language.h
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageObject : NSObject

@property (nonatomic, strong) NSString *languageName;
@property (nonatomic, strong) NSNumber *languageId;

-(instancetype) initWithInfo:(NSDictionary *)info;
-(NSDictionary *)toDictionary;
@end
