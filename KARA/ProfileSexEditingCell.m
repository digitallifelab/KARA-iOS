//
//  ProfileSexEditingCell.m
//  KARA
//
//  Created by CloudCraft on 14.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ProfileSexEditingCell.h"

@implementation ProfileSexEditingCell

-(IBAction)changeSex:(UISegmentedControl *)senderSegmentedControl
{
    [self.sexChangeDelegate sexCell:self didChangeCurrentSex:senderSegmentedControl.selectedSegmentIndex];
}

@end
