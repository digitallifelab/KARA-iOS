//
//  ProfileButtonCell.h
//  KARA
//
//  Created by CloudCraft on 14.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfileButtonCell;
@protocol ButtonCellDelegate <NSObject>

-(void)profileButtonCell:(ProfileButtonCell *)cell didPressButton:(UIButton *)button;

@end

@interface ProfileButtonCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) id<ButtonCellDelegate> buttonCellDelegate;
@end
