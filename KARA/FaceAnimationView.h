//
//  FaceAnimationView.h
//  Origami
//
//  Created by CloudCraft on 24.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FaceAnimationView : UIImageView

@property (nonatomic, strong) CAKeyframeAnimation *faceAnimation;
//@property (nonatomic, strong) CAAnimationGroup *faceAnimationGroup;
@property (nonatomic, strong) CALayer *keyFrameAnimatedLayer;
//@property (nonatomic, strong) CALayer *staticImageLayer;
@property (nonatomic, assign) BOOL shouldAnimateFace;
-(BOOL) setNewFaceAnimationFromName:(NSString *)animationName;

-(NSTimeInterval) defaultBetweenAnimationsInterval;

-(void) setNewBetweenAnimationsInterval:(NSTimeInterval) newInterval;

-(void) startAnimatingFaceWithInterval:(NSTimeInterval) betweenAnimationsInterval;

-(void) stopAnimatingFaceImmediately:(BOOL)stopImmediately withCompletion:(void(^)(BOOL completed))completionBlock;

-(void) addLayersIfNotExist;



@end
