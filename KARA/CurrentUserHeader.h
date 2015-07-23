//
//  CurrentUserHeader.h
//  Origami
//
//  Created by CloudCraft on 04.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
@interface CurrentUserHeader : UIView<ContactProfileHeaderDelegate>

@property (nonatomic, strong) UIImageView *userPhoto;
@property (nonatomic, weak) id<ContactProfileHeaderDelegate> delegate;
@property (nonatomic, strong) UILabel *userEmailLabel;

-(void) maskAvatarToOctagon;

@end
