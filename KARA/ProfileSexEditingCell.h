//
//  ProfileSexEditingCell.h
//  KARA
//
//  Created by CloudCraft on 14.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfileSexEditingCell;
@protocol SexCellDelegate <NSObject>

-(void)sexCell:(ProfileSexEditingCell *)cell didChangeCurrentSex:(NSInteger)newValue;

@end

@interface ProfileSexEditingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UISegmentedControl *sexSegmentedControl;
@property (nonatomic, weak) id<SexCellDelegate>sexChangeDelegate;


@end
