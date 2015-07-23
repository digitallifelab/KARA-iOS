//
//  TrendWordsVC.h
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface TrendWordsVC : UIViewController


@property (nonatomic, strong) NSMutableArray *trendWords;
@property (nonatomic, strong) NSMutableArray *trendSubordinates;
@property (nonatomic, weak) id<DismissDelegate>dismissDelegate;
@end
