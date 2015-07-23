//
//  AmbienceAnimationView.h
//  Origami
//
//  Created by CloudCraft on 13.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AnimationsCreator.h"
#import "Enumerators.h"

@class AmbienceAnimationView;
@protocol AnimationCompletionDelegate <NSObject>

@optional
-(void)animationView:(AmbienceAnimationView *)view didFinishAnimation:(CAKeyframeAnimation *)animation;
-(void)animationView:(AmbienceAnimationView *)view didStartAnimation:(CAKeyframeAnimation *)animation;

-(void) animationView:(AmbienceAnimationView *)view didStartVideoAnimationWithName:(NSString *)animationName;
-(void) animationView:(AmbienceAnimationView *)view didFinishVideoAnimation:(NSString *)animationName;

@end


@interface AmbienceAnimationView : UIImageView

@property (nonatomic, weak) id<AnimationCompletionDelegate> animationFinishDelegate;
@property (nonatomic, weak) IBOutlet UILabel *emotionNameLabel;
@property (nonatomic, strong) CALayer *keyFrameAnimatedLayer;
//@property (nonatomic, strong) CALayer *staticImageLayer;
@property (nonatomic, getter=isCurrentlyAnimating) BOOL currentlyAnimating;
@property (nonatomic, assign) BOOL didPlayStartingAnimation;

- (void) addAnimatedLayerIfNotExist;

- (void) setCurrentAnimation:(CAKeyframeAnimation *)keyFrameAnimation;
- (CAKeyframeAnimation *) currentAnimation;

-(void) setCurrentAmbientAnimation:(CAKeyframeAnimation *)keyFrameAnimation;
- (CAKeyframeAnimation *) currentAmbienceAnimation;

//-(BOOL) setCurrentAnimationFromName:(NSString *)animationName;

- (void) allowEndlessAnimation:(BOOL)allow;

- (void) stopAssignedAnimationWithCompletion:(void (^)(void))completion;
- (void) proceedAnimatingAmbience;


-(void)displayEmotionName:(BOOL)display;
// Video Animation
-(void) playAnimationNamed:(NSString *)name forMinutes:(NSInteger)minutes;
-(BOOL) playVideoItem:(AVPlayerItem *)playerItem forMinutes:(NSInteger)minutes atRate:(float)playbackRate;
-(void) stopPlayingCurrentAnimationWithCompletion:(void(^)(NSString *stoppedAnimationName))completionBlock;

-(UIImage *) pauseForTakingScreenshot;
-(void) resumeAfterPausing;
@end
