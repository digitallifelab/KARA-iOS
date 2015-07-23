//
//  Contact.h
//  Origami
//
//  Created by CloudCraft on 06.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *mood;
@property (nonatomic, strong) NSString *loginName;

@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *country;

@property (nonatomic, strong) NSString *birthDay;
@property (nonatomic, strong) NSString *lastSync;
@property (nonatomic, strong) NSString *regDate;

@property (nonatomic, strong) NSData *photo;

//@property (nonatomic, strong) NSNumber *userId; //needed when finding contact my email
@property (nonatomic, strong) NSNumber *contactId;
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSNumber *countryId;
@property (nonatomic, strong) NSNumber *languageId;

@property (nonatomic, strong) NSNumber *isFavourite; //boolean
@property (nonatomic, strong) NSNumber *elementId;

@property (nonatomic, strong) NSNumber *isOnline;


-(instancetype) initWithParameters:(NSDictionary *)params;
-(BOOL) isEqual:(Contact *)object;
-(NSUInteger) hash;
//-(NSDictionary *) descriptSelf;

-(NSDictionary *)toDictionary;


@end

//when searching for contact
/*
 
 {
 BirthDay = "/Date(-7200000+0200)/";
 Country = "<null>";
 CountryId = "<null>";
 FirstName = ivan;
 Language = "<null>";
 LanguageId = "<null>";
 LastName = yavorin1;
 LastSync = "/Date(0)/";
 LoginName = "yavorin@mailinator.com";
 Mood = "";
 Password = "<null>";
 PhoneNumber = "";
 Photo = "<null>";
 RegDate = "/Date(1422977120910+0200)/";
 Sex = 0;
 State = 0;
 Token = "00000000-0000-0000-0000-000000000000";
 UserId = 12;
 };
 
 */


//when loading contacts
/*
BirthDay = "/Date(-7200000+0200)/";
ContactId = 12;
Country = "";
ElementId = 14;
FirstName = ivan;
IsFavorite = 0;
Language = "";
LastName = yavorin1;
LoginName = "yavorin@mailinator.com";
Mood = "";
PhoneNumber = "";
Photo = "<null>";
RegDate = "/Date(1422977120910+0200)/";
Sex = 0;
State = 1;

*/