//
//  AttachFile.h
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachFile : NSObject

@property (nonatomic, strong) NSNumber *attachID;
@property (nonatomic, strong) NSNumber *elementID;
@property (nonatomic, strong) NSNumber *creatorID;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSNumber *fileSize;
@property (nonatomic, strong) NSString *createDate;

-(instancetype) initWithInfo:(NSDictionary *)info;

@end
