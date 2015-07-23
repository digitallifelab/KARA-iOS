//
//  AttachFile.m
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AttachFile.h"

@implementation AttachFile

-(instancetype) initWithInfo:(NSDictionary *)info
{
    if (!self)
        self = [super init];
    
    if (self)
    {
        self.creatorID = [info objectForKey:@"CreatorId"];
        self.fileName = [info objectForKey:@"FileName"];
        self.elementID = [info objectForKey:@"ElementId"];
        self.attachID = [info objectForKey:@"Id"];
        self.createDate = [info objectForKey:@"CreateDate"];
        self.fileSize = [info objectForKey:@"Size"];
    }
    
    return self;
}

@end
