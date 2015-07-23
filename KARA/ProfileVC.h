//
//  ProfileVC.h
//  KARA
//
//  Created by CloudCraft on 06.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class ProfileVC;
@protocol ProfileDelegate <NSObject>

-(void)profileViewController:(ProfileVC *)profileVC logoutButtonPressed:(UIBarButtonItem *)buttonItem;

@end
@interface ProfileVC : UIViewController

@property (nonatomic, weak) id<DismissDelegate> dismissDelegate;
@property (nonatomic, weak) id<ProfileDelegate> profileDelegate;

@end
