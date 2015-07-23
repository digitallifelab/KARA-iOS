//
//  AnimationsCreator.h
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+FromColor.h"
#import "Enumerators.h"
#import "Constants.h"
@interface AnimationsCreator : NSObject

-(CAKeyframeAnimation *) animationForEmotionType:(KaraAnimationType)type emotionNamed:(NSString *)emotionName;
-(CAAnimationGroup *)getFaceAnimationGroupByStartName:(NSString *)startName animationRepeatInterval:(NSTimeInterval)repeatInterval;


- (CAAnimation *)animationForMesh;

- (CAKeyframeAnimation *)preloaderAnimation;

- (CABasicAnimation *)pulseWordBubbleAnimation;

@end
