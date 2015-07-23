//
//  ChangePasswordVC.h
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChangePasswordVC;
@protocol ChangePasswordDelegate <NSObject>

-(void)changePasswordViewController:(ChangePasswordVC *)changePasswordVC didChangePasswordSuscessfully:(BOOL)success;

@end

@interface ChangePasswordVC : UIViewController

@property (nonatomic, weak) id<ChangePasswordDelegate> changePasswordDelegate;
-(void) enableUI:(BOOL) enable;
@end
