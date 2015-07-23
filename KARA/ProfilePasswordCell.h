//
//  ProfilePasswordCell.h
//  KARA
//
//  Created by CloudCraft on 14.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePasswordCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

-(void) setNewBackgroundColor:(UIColor *)color;

@end
