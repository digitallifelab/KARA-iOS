//
//  LoginVC.h
//  Origami
//
//  Created by CloudCraft on 17.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginVC;
@protocol LoginScreenDelegate <NSObject>

-(void) loginScreen:(LoginVC *)loginViewController loginWithParameters:(NSDictionary *)userLoginParams;

-(void) loginScreenLoginWithTwitterPressed:(LoginVC *)loginViewController;

-(void) loginScreenLoginWithFacebookPressed:(LoginVC *)loginViewController;

@end

extern NSString *loginNameStringKey;
extern NSString *loginPasswordStringKey;




@interface LoginVC : UIViewController

@property (nonatomic, weak) id<LoginScreenDelegate> loginDelegate;
-(void) disableUI:(BOOL)disable;

@end
