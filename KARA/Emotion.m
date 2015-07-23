//
//  Emotion.m
//  Origami
//
//  Created by CloudCraft on 30.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "Emotion.h"

@implementation Emotion


-(instancetype) initWithPreview:(EmotionPreview *)emotionPreview andAnimation:(CAKeyframeAnimation *)animation
{
    self = [super init];
    if (self != nil)
    {
        self.preview = emotionPreview;
        self.animation = animation;
    }
    return self;
}

-(void) setCurrentAnimation:(CAKeyframeAnimation *)animation
{
    self.animation = animation;
}


@end
