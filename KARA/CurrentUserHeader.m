//
//  CurrentUserHeader.m
//  Origami
//
//  Created by CloudCraft on 04.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "CurrentUserHeader.h"
#import "UIView+OctagonMask.h"
#import "Constants.h"
#import "UIView+OctagonMask.h"

@implementation CurrentUserHeader

-(instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self addSubviews];
    return self;
}

-(void)addSubviews
{
    UITapGestureRecognizer *tapOnPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTaped:)];
    tapOnPhoto.cancelsTouchesInView = YES;
    
    _userPhoto = [[UIImageView alloc] init];
    _userPhoto.translatesAutoresizingMaskIntoConstraints = NO;
    _userPhoto.backgroundColor = Global_Tint_Color;
    
    //next two lines add white plus image.
    _userPhoto.image = [[UIImage imageNamed:@"button-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _userPhoto.tintColor = [UIColor whiteColor];
    _userPhoto.contentMode = UIViewContentModeCenter;
    [_userPhoto addGestureRecognizer:tapOnPhoto];
    _userPhoto.userInteractionEnabled = NO;
    [self addSubview:_userPhoto];
    
    _userEmailLabel = [[UILabel alloc] init];
    _userEmailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _userEmailLabel.font = [UIFont systemFontOfSize:17.0];
    _userEmailLabel.textColor = Global_Border_Color;//[UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
    _userEmailLabel.numberOfLines = 1;
    [self addSubview:_userEmailLabel];
    
    
    [self addConstraintsToSubviews];
}

-(void)addConstraintsToSubviews
{
    NSDictionary *subViews = NSDictionaryOfVariableBindings(_userPhoto, /*_userNameLabel,*/ _userEmailLabel);
    
    //avatar
    NSArray *photoWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_userPhoto(80)]" options:0 metrics:nil views:subViews];
    NSArray *photoHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userPhoto(80)]" options:0 metrics:nil views:subViews];
    NSLayoutConstraint *verticalCenterPhoto = [NSLayoutConstraint constraintWithItem:_userPhoto
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0];
    NSLayoutConstraint *photoTop = [NSLayoutConstraint constraintWithItem:_userPhoto
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:5.0];
    [self addConstraints:photoWidth];
    [self addConstraints:photoHeight];
    [self addConstraints:@[verticalCenterPhoto,photoTop]];
    
    //name label
    NSLayoutConstraint *nameCenter = [NSLayoutConstraint constraintWithItem:_userEmailLabel
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    NSLayoutConstraint *nameTop = [NSLayoutConstraint constraintWithItem:_userEmailLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_userPhoto
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:8.0];
    [self addConstraints:@[nameCenter, nameTop]];
    
}

-(void) maskAvatarToOctagon
{
//#ifdef Messenger
    [self.userPhoto maskToCircle];
//#else
//    [self.userPhoto maskToOctagon];
//#endif
}


-(void) photoTaped:(UITapGestureRecognizer *)tap
{
    [self.delegate headerChangeImagePressed:self];
}



@end
