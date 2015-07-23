//
//  ProfilePasswordCell.m
//  KARA
//
//  Created by CloudCraft on 14.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ProfilePasswordCell.h"

@implementation ProfilePasswordCell
-(void) awakeFromNib
{
    self.passwordTextField.tintColor = [UIColor whiteColor];
//    self.passwordTextField.layer.borderWidth = 1.0;
}

-(void) setNewBackgroundColor:(UIColor *)color
{
    self.backgroundColor = color;
}
@end
