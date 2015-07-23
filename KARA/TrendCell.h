//
//  TrendCell.h
//  KARA
//
//  Created by CloudCraft on 08.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
@interface TrendCell : UITableViewCell

@property (nonatomic, weak) id<TrendWordTapDelegate>wordTapDelegate;

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;
@property (nonatomic, weak) IBOutlet UIImageView *connectionImageView;

@end
