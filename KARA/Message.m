//
//  ChatMessage.m
//  Origami
//
//  Created by CloudCraft on 09.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "Message.h"
//#import <objc/objc-runtime.h>
#import "NSString+ServerDate.h"
#import "NSDate+ServerFormat.h"

@implementation Message

-(instancetype) initWithParams:(NSDictionary *)params
{
    if (!self)
    {
        self = [super init];
    }
    if (self)
    {
        [self setInfo:params];
        
    }
    
    
    return self;
}

-(void) setInfo:(NSDictionary *) params
{
    self.messageId = [params objectForKey:@"MessageId"];
    self.typeId = [params objectForKey:@"TypeId"];
    NSString *text = [params objectForKey:@"Msg"];
//    if (self.typeId.integerValue == 7 || self.typeId.integerValue == 8)
//    {
//        text = [NSString stringWithFormat:@"%@", text];
//    }
    self.textBody = text;
    NSString *dateString = [params objectForKey:@"CreateDate"];
    self.dateCreated =  [dateString dateFromServerDateString];
    self.elementId = [params objectForKey:@"ElementId"];
    self.firstName = [params objectForKey:@"FirstName"];
    self.creatorId = [params objectForKey:@"CreatorId"];
    
    self.isNew = [params objectForKey:@"IsNew"];
}

-(NSDictionary *)toStoredDictionary
{
    NSMutableDictionary *toReturn = [NSMutableDictionary dictionaryWithCapacity:7];
    if (_textBody)
        [toReturn setObject:_textBody forKey:@"Msg"];
    
    if (_dateCreated)
        [toReturn setObject:[_dateCreated dateForServer] forKey:@"CreateDate"];
    
    if (_elementId)
        [toReturn setObject:_elementId forKey:@"ElementId"];
    
    if (_firstName)
        [toReturn setObject:_firstName forKey:@"FirstName"];
    
    if (_creatorId)
        [toReturn setObject:_creatorId forKey:@"CreatorId"];
    
    if (_typeId)
        [toReturn setObject:_typeId forKey:@"TypeId"];
    
    if (_isNew) //means "isNew != nil"
        [toReturn setObject:_isNew forKey:@"IsNew"];
    
    if (_messageId)
        [toReturn setObject:_messageId forKey:@"MessageId"];
    
    return toReturn;
}


- (BOOL)isEqual:(Message *)object
{
    if (!object)
    {
        return NO;
    }
    
    if (![object isKindOfClass:[Message class]])
    {
        return NO;
    }
    
    if (object == self)
    {
        return YES;
    }
    if ([object.textBody isEqualToString:self.textBody] && object.creatorId.integerValue == self.creatorId.integerValue && object.typeId.integerValue == self.typeId.integerValue)
    {
        return YES;
    }
    else
        return NO;
    
    
    
}

-(NSUInteger)hash
{
    return (self.textBody.hash ^ self.creatorId.hash);
}

//-(NSDictionary *) descriptSelf
//{
//    NSMutableDictionary *returnDescription = [@{} mutableCopy];
//    
//    unsigned int numberOfProperties = 0;
//    objc_property_t *propertyArray = class_copyPropertyList([Message class], &numberOfProperties);
//    
//    for (NSUInteger i = 0; i < numberOfProperties; i++)
//    {
//        objc_property_t property = propertyArray[i];
//        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
//        //NSString *attributesString = [[NSString alloc] initWithUTF8String:property_getAttributes(property)];
//        //NSLog(@"Property %@ attributes: %@", name, attributesString);
//        if ([self valueForKey:name] != nil)
//        {
//            [returnDescription setObject:[self valueForKey:name] forKey:name];
//        }
//        
//    }
//    free(propertyArray);
//    return returnDescription;
//}


@end
