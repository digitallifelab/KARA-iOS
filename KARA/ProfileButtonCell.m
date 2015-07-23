//
//  ProfileButtonCell.m
//  KARA
//
//  Created by CloudCraft on 14.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ProfileButtonCell.h"

@implementation ProfileButtonCell
-(void) awakeFromNib
{
    self.button.layer.cornerRadius = 7.0;
}

-(IBAction)buttonTap:(id)sender
{
    [self.buttonCellDelegate profileButtonCell:self didPressButton:self.button];
}

@end
