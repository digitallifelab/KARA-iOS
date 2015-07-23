//
//  KaraRangeWordsAnimationView.h
//  KARA
//
//  Created by CloudCraft on 29.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KaraRangeWordsAnimationView : UIView

-(instancetype) initWithCoder:(NSCoder *)aDecoder;

-(void) assignWords:(NSArray *)words;
-(void) animateLabelsRotationCompletion:(void(^)(void)) completionBlock;

@property (nonatomic, assign) BOOL didAnimateBottomToTop;

@end
