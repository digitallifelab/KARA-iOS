//
//  User.m
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "User.h"
#import "NSData+PhotoConverter.h"
#import "DataSource.h"
#import "Constants.h"
@implementation User

/*
 LoginResult =     
 {
 BirthDay = "/Date(-62135596800000+0000)/";
 Country = "";
 CountryId = "<null>";
 FirstName = Ivan2;
 Language = "";
 LanguageId = "<null>";
 LastName = Iavorin2;
 LastSync = "/Date(-62135596800000+0000)/";
 LoginName = "Iavorin2@mailinator.com";
 Mood = "";
 Password = 3CnLus2lft8z;
 PhoneNumber = "";
 Photo = "<null>";
 RegDate = "/Date(1422098239833+0000)/";
 Sex = 0;
 State = 1;
 Token = "c9003d90-1b48-48b3-9b72-c96b9da987c5";
 UserId = 1012;
 };
 
 */

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
    if (params.allKeys.count > 0)
    {
        NSString *token = [NSString stringWithString: [params objectForKey:@"Token"] ];
        self.token    = token; // [NSString stringWithString: [params objectForKey:@"Token"] ];//params[@"Token"];
        self.firstName = [params objectForKey:@"FirstName"];//params[@"FirstName"];
        self.lastName = [params objectForKey:@"LastName"];// params[@"LastName"];
        self.loginName = [params objectForKey:@"LoginName"];
        
        self.password = (NSString *)[params objectForKey:@"Password"];
        
        NSString *regDate = (NSString *)[params objectForKey:@"RegDate"];
        self.regDate  = regDate;
        
        self.lastSync = (NSString *)[params objectForKey:@"LastSync"];
        if ([params objectForKey:@"BirthDay"] != [NSNull null])
        {
            self.birthDay = (NSString *)[params objectForKey:@"BirthDay"];
        }
        self.phoneNumber = (NSString *)[params objectForKey:@"PhoneNumber"];
        self.mood = (NSString *)[params objectForKey:@"Mood"];
        self.language = (NSString *)[params objectForKey:@"Language"];
        
        if([params objectForKey:@"LanguageId"] != nil)
            self.languageID = [params objectForKey:@"LanguageId"] ;
        
        self.country = [params objectForKey:@"Country"];
        
        if ([params objectForKey:@"CountryId"] != nil)
            self.countryID = [params objectForKey:@"CountryId"] ;
        
        self.sex = [params objectForKey:@"Sex"] ;
        
        self.userID   = [params objectForKey:@"UserId"] ;
        
        self.state = [params objectForKey:@"State"] ;
        
        if ([params objectForKey:@"Photo"] != [NSNull null])
        {
            NSData *photoData = [NSData dataFromIntegersArray: [params objectForKey:@"Photo"]];
            self.photo = photoData;
            //[[DataSource sharedInstance].avatars setObject:[UIImage imageWithData:self.photo] forKey:self.userID];
        }
    }
    
}

-(NSDictionary *)toDictionary
{
    NSMutableDictionary *toReturn = [NSMutableDictionary dictionaryWithCapacity:18];
    if(self.token)
        [toReturn setObject:self.token forKey:@"Token"];
    
    if (self.regDate)
        [toReturn setObject:self.regDate forKey:@"RegDate"];
    
    if (self.firstName)
        [toReturn setObject:self.firstName forKey:@"FirstName"];
    
    if (self.phoneNumber)
        [toReturn setObject:self.phoneNumber forKey:@"PhoneNumber"];
    
    if (self.lastName)
        [toReturn setObject:self.lastName forKey:@"LastName"];
    
    if(self.loginName)
        [toReturn setObject:self.loginName forKey:@"LoginName"];
    
    if(self.password)
        [toReturn setObject:self.password forKey:@"Password"];
    
    if(self.lastSync)
        [toReturn setObject:self.lastSync forKey:@"LastSync"];
    
    if(self.birthDay)
        [toReturn setObject:self.birthDay forKey:@"BirthDay"];
    
    //if (self.photo)
        //[toReturn setObject:self.photo forKey:@"Photo"];
    
    if(self.mood )
        [toReturn setObject:self.mood forKey:@"Mood"];
    
    if(self.language )
        [toReturn setObject:self.language forKey:@"Language"];
    
    if(self.languageID)
        [toReturn setObject:self.languageID forKey:@"LanguageId"];
    
    if(self.country )
        [toReturn setObject:self.country forKey:@"Country"];
    
    if(self.countryID != nil && ![self.countryID isKindOfClass:[NSNull class]])
        [toReturn setObject:self.countryID forKey:@"CountryId"];
    
    if (self.sex)
        [toReturn setObject:self.sex forKey:@"Sex"];
    
    if (self.userID)
        [toReturn setObject:self.userID forKey:@"UserId"];
    
    if(self.state)
        [toReturn setObject:self.state forKey:@"State"];
    
    
    
    return [toReturn copy];
}

+(User *)userFromJSON:(NSDictionary *)jsonObject
{
    return [[[self class] alloc] initWithParameters:jsonObject];
}


@end
