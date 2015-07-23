//
//  Element.m
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "Element.h"
#import <objc/runtime.h> //for description output
#import "Constants.h"
#import "NSString+ServerDate.h"
#import "NSDate+ServerFormat.h"

@implementation Element

-(instancetype) initWithInfo:(NSDictionary *)info
{
    if (!self)
        self = [super init];
    
    if (self)
    {
        //// -- set default values, needed when filtering results -- ////
        self.isFavourite = @(0);
        self.isSignal = @(0);
        self.hasAttaches = @(0);
        ////---////
        
        self.elementDescription = [info objectForKey:@"Description"];
        self.title = [info objectForKey:@"Title"];
        
        self.creatorId = [info objectForKey:@"CreatorId"];
        self.createDate = [info objectForKey:@"CreateDate"];
        
        self.changerId = [info objectForKey:@"ChangerId"];
        self.changeDate = [info objectForKey:@"ChangeDate"] ;
        
        self.finishState = [info objectForKey:@"FinishState"];
        self.finishDate = [[info objectForKey:@"FinishDate"] dateFromServerDateString];
        
        self.typeId = [info objectForKey:@"TypeId"];
        self.elementId = [info objectForKey:@"ElementId"];
        self.rootElementId = [info objectForKey:@"RootElementId"];
        self.remindDate = [[info objectForKey:@"RemindDate"] dateFromServerDateString];
        self.archDate = [info objectForKey:@"ArchDate"];
        
        self.isFavourite = [info objectForKey:@"IsFavorite"];
        self.hasAttaches = [info objectForKey:@"HasAttaches"];
        self.isSignal = [info objectForKey:@"IsSignal"];
        
        if ([info objectForKey:@"Attaches"] != [NSNull null])
        {
            self.attaches = [[info objectForKey:@"Attaches"] mutableCopy];
        }
        
        if ([info objectForKey:@"PassWhomIds"] != [NSNull null])
        {
            self.passWhomIds = [[ info objectForKey:@"PassWhomIds"] mutableCopy];
        }
        else
            self.passWhomIds = [@[] mutableCopy];
    }
    return self;
}

//-(void) setUpInfo:(NSDictionary *)info
//{
//    self.elementDescription = [info objectForKey:@"Description"];
//}


-(NSDictionary *) toDictionary
{
    NSMutableDictionary *returning = [@{} mutableCopy];
    
    returning[@"ElementId"] = _elementId?_elementId:dictNULL;
    
    returning[@"RootElementId"] = _rootElementId?_rootElementId:dictNULL;
    
    returning[@"TypeID"] = _typeId?_typeId:dictNULL;
    
    returning[@"FinishState"] = _finishState?_finishState:dictNULL;
    
    returning[@"CreatorId"] = _creatorId?_creatorId:dictNULL;
    
    returning[@"ChangerId"] = _changerId?_changerId:dictNULL;
    
    returning[@"IsSignal"] = _isSignal?_isSignal:dictNULL;
    
    returning[@"IsFavorite"] = _isFavourite?_isFavourite:dictNULL;
    
    returning[@"HasAttaches"] = _hasAttaches?_hasAttaches:dictNULL;
    
    
    
    returning[@"Title"] = _title?_title:@"";
    
    returning[@"Description"] = _elementDescription?_elementDescription:@"";
    
    
    
    returning[@"Attaches"] = _attaches?_attaches:dictNULL;
    
    returning[@"PassWhomIds"] = _passWhomIds?_passWhomIds:dictNULL;
    
    
    
    returning[@"CreateDate"] = _createDate ? _createDate  : dictNULL;

    returning[@"ChangeDate"] = _changeDate ? _changeDate : dictNULL;
    
    returning[@"FinishDate"] = _finishDate?[_finishDate dateForServer] : [NSDate dummyDate];
    
    returning[@"ArchDate"] = _archDate ? _archDate :dictNULL;
    
    returning[@"RemindDate"] = _remindDate ?[_remindDate dateForServer] : [NSDate dummyDate];
    
    return returning;
}


-(NSDictionary *) descriptSelf
{
    NSMutableDictionary *returnDescription = [@{} mutableCopy];
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([Element class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        //NSString *attributesString = [[NSString alloc] initWithUTF8String:property_getAttributes(property)];
       // NSLog(@"Property %@ attributes: %@", name, attributesString);
        if ([self valueForKey:name] != nil)
        {
            [returnDescription setObject:[self valueForKey:name] forKey:name];
        }
        else
        {
            [returnDescription setObject:[NSNull null] forKey:name];
        }
        
    }
    free(propertyArray);
    return returnDescription;
}

@end
