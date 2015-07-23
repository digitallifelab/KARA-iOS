//
//  IntroPageView.h
//  KARA
//
//  Created by CloudCraft on 28.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+OctagonMask.h"
@interface IntroPageView : UIView

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIImageView *introImage;
-(instancetype) initWithFrame:(CGRect)frame andInfo:(NSDictionary *)info;
@end
