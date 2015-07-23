//
//  Emotion.h
//  Origami
//
//  Created by CloudCraft on 30.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmotionPreview.h"
#import <UIKit/UIKit.h>
@interface Emotion : NSObject

@property (nonatomic, strong, setter=setCurrentAnimation:) CAKeyframeAnimation *animation;
@property (nonatomic, strong, setter=setCurrentPreview:) EmotionPreview *preview;

-(void) setCurrentAnimation:(CAKeyframeAnimation *)anumation;

@end
