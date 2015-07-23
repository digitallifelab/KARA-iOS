//
//  AnimationsCreator.m
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AnimationsCreator.h"

@implementation AnimationsCreator

/*
 
 By encapsulating a 2 seconds animation into a 5 seconds animation group, you'll end up with a 2 seconds animation followed by a 3 seconds delay:
 
 CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
 animationGroup.duration = 5;
 animationGroup.repeatCount = INFINITY;
 
 CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
 
 CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
 pulseAnimation.fromValue = @0.0;
 pulseAnimation.toValue = @1.0;
 pulseAnimation.duration = 2;
 pulseAnimation.timingFunction = easeOut;
 
 animationGroup.animations = @[pulseAnimation];
 
 [ringImageView.layer addAnimation:animationGroup forKey:@"pulse"];
 
 */


- (CAKeyframeAnimation *)animationForEmotionType:(KaraAnimationType)type emotionNamed:(NSString *)emotionName
{
    CAKeyframeAnimation *animationToReturn;
    switch (type)
    {
        case KaraAnimationTypeAmbience:
        {
            NSString *animationStartName = [self imageNameFromEmotionName:emotionName];
            animationToReturn = [self getAnimationByStartName:animationStartName animationType:type shouldAutoReverse:NO];
        }
            break;
        case KaraAnimationTypeFace:
        {
            NSString *animationStartName = [self imageNameForFaceName:emotionName];
            animationToReturn = [self getAnimationByStartName:animationStartName animationType:type shouldAutoReverse:NO];
        }
            break;
        default:
            break;
    }
    return animationToReturn;
}

-(NSString *)imageNameFromEmotionName:(NSString *)emotionName
{
    if ([emotionName isEqualToString:@"apathy"])
    {
        return @"ap";
    }
    else if ([emotionName isEqualToString:@"joy"])
    {
        return @"rd";
    }
    else if ([emotionName isEqualToString:@"confidence"])
    {
        return @"intr";
    }
    else if ([emotionName isEqualToString:@"interest"])
    {
        return @"uv";
    }
    else if ([emotionName isEqualToString:@"ambience"])
    {
        return @"amb";
    }
    else if ([emotionName isEqualToString:@"pain"])
    {
        return @"ps";
    }
    else if ([emotionName isEqualToString:@"anxiety"])
    {
        return @"tv";
    }
    else if ([emotionName isEqualToString:@"enjoyment"])
    {
        return @"ns";
    }
    else if ([emotionName isEqualToString:@"sorrow"])
    {
        return @"tr";
    }
    return nil;
}

-(NSString *)imageNameForFaceName:(NSString *)faceName
{
    if ([faceName isEqualToString:@"face"])
    {
        return faceName;
    }
    
    return nil;
}

-(CAKeyframeAnimation *) getAnimationByStartName:(NSString *)startName animationType:(KaraAnimationType)animationType shouldAutoReverse:(BOOL) shouldAutoReverse
{

    NSMutableArray *images = [NSMutableArray arrayWithCapacity:50];
    
    NSInteger counter = 0;
    NSInteger maximumCount = 500;
//    if (shouldAutoReverse && animationType == KaraAnimationTypeFace)
//    {
//        maximumCount = 30;
//    }
    for (NSInteger c = 0; c < maximumCount; c++)
    {
        NSString *countString;
        if (counter < 10)
        {
            countString = [NSString stringWithFormat:@"00%li", (long)counter];
        }
        else if (counter < 100)
        {
            countString = [NSString stringWithFormat:@"0%li", (long)counter];
        }
        else
        {
            countString = [NSString stringWithFormat:@"%li", (long)counter];
        }
        
        NSString *lvImageName = [NSString stringWithFormat:@"%@%@", startName,countString];
        UIImage *lvImage = [UIImage imageNamed:lvImageName];
        
        if (lvImage)
        {
            [images addObject:(id)lvImage.CGImage];
            counter += 1;
            continue;
        }
        else if (counter < 187 && counter < 50)
        {
            counter += 1;
            continue;
        }
        else
        {
            break;
        }
        
    }
    
    
    //prepare animation
    NSInteger imagesCount = images.count;
//    NSLog(@"\r - Found %li images for animation: \"%@\" ", (long)imagesCount, startName);
    
    if (shouldAutoReverse)
    {
        imagesCount = floor(imagesCount / 2.0);
    }
    
    NSMutableArray *animationTimes = [NSMutableArray arrayWithCapacity:imagesCount];
    
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    
    float totalDuration;
    
    CGFloat frameStartTime;
    
    if (animationType == KaraAnimationTypeFace)
    {
        float animationDuration = imagesCount/ 24.0;
        totalDuration = animationDuration + 10; // 10 seconds gap before animation repeats
        
        float scaleFactor = animationDuration / totalDuration;
        frameStartTime = scaleFactor / imagesCount;
    }
    else
    {
        totalDuration = imagesCount/ 24.0;
        frameStartTime = 1.0 / imagesCount;
    }
    

    
    animation.duration = totalDuration;
   
    
    for (NSInteger i = 0; i < imagesCount; i++)
    {
        [animationTimes addObject:[NSNumber numberWithFloat:(frameStartTime * i)]];
    }
    
    animation.keyTimes = animationTimes;
    animation.values = images;
    animation.autoreverses = shouldAutoReverse;
   
    animation.removedOnCompletion = YES;
    float lvRepeatCount = (shouldAutoReverse)? 1 : HUGE_VALF;
    animation.repeatCount = lvRepeatCount;

    return animation;
}

-(CAAnimationGroup *)getFaceAnimationGroupByStartName:(NSString *)startName animationRepeatInterval:(NSTimeInterval)repeatInterval
{
    CAKeyframeAnimation *faceAnimation = [self getAnimationByStartName:startName animationType:KaraAnimationTypeFace shouldAutoReverse:NO];
    float duration = faceAnimation.duration;
    
    CAAnimationGroup *faceAnimationGroup = [CAAnimationGroup animation];
    faceAnimationGroup.duration = duration + repeatInterval;
    faceAnimationGroup.repeatDuration = HUGE_VALF;
    faceAnimationGroup.animations = [NSArray arrayWithObject:faceAnimation];
    
    return faceAnimationGroup;
    
}

- (CAAnimation *)animationForMesh
{
    CABasicAnimation* animationRight = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animationRight.fromValue = [NSNumber numberWithFloat:degreesToRadians(40)];
    animationRight.toValue = [NSNumber numberWithFloat: degreesToRadians(-40)];
    animationRight.autoreverses = YES;
    animationRight.duration = 20.0f;
    animationRight.timeOffset = 10.0; //animation will start from degreesToRadians(0)
    
    CAAnimationGroup *withTimeGap = [[CAAnimationGroup alloc] init];
    withTimeGap.duration = 45;
    withTimeGap.repeatCount = HUGE_VALF;
    withTimeGap.animations = @[animationRight];
    
    return withTimeGap;
}


-(CAKeyframeAnimation *) preloaderAnimation
{
    NSInteger startCount = 0;
    NSInteger endCount = 66;
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:endCount];
    for (NSInteger i = startCount; i < endCount; i++)
    {
        NSString *countString;
        if (i < 10)
        {
            countString = [NSString stringWithFormat:@"0%li", (long)i];
        }
        else
        {
            countString = [NSString stringWithFormat:@"%li", (long)i];
        }
        
        NSString *lvImageName = [NSString stringWithFormat:@"%@%@", @"preloader",countString];
        UIImage *lvImage = [UIImage imageNamed:lvImageName];
        
        if (lvImage)
        {
            [images addObject:(id)lvImage.CGImage];
        }
    }
    
    NSInteger imagesCount = images.count;
    
    CFTimeInterval duration = ceilf(imagesCount / 24.0);
    float frameTime = 1.0 / imagesCount;
    
    NSMutableArray *animationKeyTmes = [[NSMutableArray alloc] initWithCapacity:imagesCount];
    for (NSInteger j = 0; j < imagesCount; j++)
    {
        [animationKeyTmes addObject:[NSNumber numberWithFloat:(frameTime * j)]];
    }
    
    
    CAKeyframeAnimation *preloaderAnimation = [[CAKeyframeAnimation alloc] init];
    preloaderAnimation.keyPath = @"contents";
    preloaderAnimation.calculationMode = kCAAnimationDiscrete;
    preloaderAnimation.duration = duration;
    preloaderAnimation.keyTimes = animationKeyTmes;
    preloaderAnimation.values = images;
    preloaderAnimation.repeatCount = 1;
    preloaderAnimation.removedOnCompletion = NO;
    
    return preloaderAnimation;
}

- (CABasicAnimation *)pulseWordBubbleAnimation
{
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pulse.duration = 1.0;
    pulse.repeatCount = 1;
    pulse.autoreverses = YES;
    pulse.fromValue = [NSNumber numberWithFloat:1.0];
    pulse.toValue = [NSNumber numberWithFloat:1.5];
    
    return pulse;
}
@end
