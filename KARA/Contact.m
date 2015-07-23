//
//  Contact.m
//  Origami
//
//  Created by CloudCraft on 06.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "Contact.h"
//#import <objc/objc-runtime.h>
#import "NSString+ServerDate.h"
#import "NSData+PhotoConverter.h"
#import "DataSource.h"

@implementation Contact

-(instancetype)initWithParameters:(NSDictionary *)params
{
    if (!self)
    {
        self = [super init];
    }
    if (self)
    {
        [self setParameters:params];
    }
    
    return self;
}

-(void) setParameters:(NSDictionary *)params
{
    //strings
    self.firstName = [params objectForKey:@"FirstName"];
    self.lastName = [params objectForKey:@"LastName"];
    self.mood = [params objectForKey:@"Mood"];
    self.phoneNumber = [params objectForKey:@"PhoneNumber"];
    self.loginName = [params objectForKey:@"LoginName"];
    self.language = [params objectForKey:@"Language"];
    self.country = [params objectForKey:@"Country"];
    
    //dates
    self.regDate = [[params objectForKey:@"RegDate"] timeDateStringFromServerDateString];
    self.birthDay = [[params objectForKey:@"BirthDay"] timeDateStringFromServerDateString];
    self.lastSync = [[params objectForKey:@"LastSync"] timeDateStringFromServerDateString];
    
    //numbers
    self.sex = [params objectForKey:@"Sex"];
    self.state = [params objectForKey:@"State"];
//    self.userId = [params objectForKey:@"UserId"];
    self.languageId = [params objectForKey:@"LanguageId"];
    self.countryId = [params objectForKey:@"CountryId"];
    self.isFavourite = [params objectForKey:@"IsFavorite"];
    self.elementId = [params objectForKey:@"ElementId"];
    self.contactId = [params objectForKey:@"ContactId"];
    
    self.isOnline = [params objectForKey:@"IsOnline"];
    
    //
    if ([params objectForKey:@"Photo"] != [NSNull null])
    {
        NSData *photoData = [NSData dataFromIntegersArray: [params objectForKey:@"Photo"]];
        //NSLog(@"\r ---  %@`s image size: %ld", self.firstName, (long)photoData.length);
        self.photo = photoData;
        [[DataSource sharedInstance].avatars setObject:[UIImage imageWithData:self.photo] forKey:self.contactId];
    }
   
}

-(NSDictionary *) toDictionary
{
    NSMutableDictionary *toReturn;
    [toReturn setObject:(self.firstName)?self.firstName:@"" forKey:@"FirstName"];
    [toReturn setObject:(self.lastName)?self.lastName:@"" forKey:@"LastName"];
    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
    [toReturn setObject:(self.phoneNumber)?self.phoneNumber:@"" forKey:@"Mood"];
    [toReturn setObject:(self.loginName)?self.loginName:@"" forKey:@"LoginName"];
    
    [toReturn setObject:(self.language)?self.language:@"" forKey:@"Language"];
    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Language"];
    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
//    [toReturn setObject:(self.mood)?self.mood:@"" forKey:@"Mood"];
    
    return toReturn;
}

//-(NSDictionary *) descriptSelf
//{
//    NSMutableDictionary *returnDescription = [@{} mutableCopy];
//    
//    unsigned int numberOfProperties = 0;
//    objc_property_t *propertyArray = class_copyPropertyList([Contact class], &numberOfProperties);
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

- (BOOL)isEqual:(Contact *)contact
{
    
    if (!contact)
    {
        return NO;
    }
    
    if (contact == self)
    {
        return YES;
    }
//    else if (![super isEqual:contact])
//    {
//        return NO;
//    }
    else if (![contact isKindOfClass:[Contact class]])
    {
        return NO;
    }
    else
    {
        BOOL toReturn = self.contactId.integerValue == contact.contactId.integerValue;
        return toReturn;
    }
}

- (NSUInteger)hash
{
    NSUInteger hashUnsignedInt = [self.loginName hash] ^ [self.contactId hash];
    return hashUnsignedInt;
}
@end
