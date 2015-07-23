//
//  Language.m
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "LanguageObject.h"

@implementation LanguageObject

-(instancetype) initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if  (self)
    {
        self.languageId = [info objectForKey:@"Id"];
        self.languageName = [info objectForKey:@"Name"];
    }
    return self;
}

-(NSDictionary *)toDictionary
{
    return [NSDictionary dictionaryWithObjects:@[self.languageName, self.languageId] forKeys:@[@"Name",@"Id"]];
}
@end
