//
//  Element.h
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachFile.h"
@interface Element : NSObject


@property (nonatomic, strong) NSNumber *elementId; //*
@property (nonatomic, strong) NSNumber *rootElementId; //*
@property (nonatomic, strong) NSNumber *typeId; //*
@property (nonatomic, strong) NSNumber *finishState; //*
@property (nonatomic, strong) NSNumber *creatorId; //*
@property (nonatomic, strong) NSNumber *changerId; //*

@property (nonatomic, strong) NSNumber *isSignal; //bool //*
@property (nonatomic, strong) NSNumber *isFavourite; //bool
@property (nonatomic, strong) NSNumber *hasAttaches; //bool

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *elementDescription;

@property (nonatomic, strong) NSMutableArray *attaches; // AttachFile ids array
@property (nonatomic, strong) NSMutableArray *passWhomIds;// integers(NSNumbers) array (Contact.contactIds array)

@property (nonatomic, strong) NSString *createDate; //dates from server
@property (nonatomic, strong) NSString *changeDate;
@property (nonatomic, strong) NSString *archDate;
                                                    //dates set by User
@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, strong) NSDate *remindDate;
//@property (nonatomic, strong) NSNumber *subordinateSignalsCount;

-(instancetype) initWithInfo:(NSDictionary *)info;
-(NSDictionary *) toDictionary;
-(NSDictionary *) descriptSelf;

@end
