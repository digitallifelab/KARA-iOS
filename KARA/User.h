//
//  User.h
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *birthDay;

@property (nonatomic, strong) NSString *country;


@property (nonatomic, strong) NSString *language;


@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *loginName; //email

@property (nonatomic, strong) NSString *mood;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, strong) NSString *regDate;
@property (nonatomic, strong) NSString *lastSync;
@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSNumber *sex;

@property (nonatomic, strong) NSNumber *languageID;
@property (nonatomic, strong) NSNumber *countryID;

@property (nonatomic, strong) NSData *photo;

-(instancetype) initWithParameters:(NSDictionary *)params;
-(void)setParameters:(NSDictionary *)parameters;
-(NSDictionary *)toDictionary;
+(User *)userFromJSON:(NSDictionary *)jsonObject;



@end
