//
//  FaceAnimationView.m
//  Origami
//
//  Created by CloudCraft on 24.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "FaceAnimationView.h"
#import "AnimationsCreator.h"

@interface FaceAnimationView ()

@property (nonatomic, assign) NSTimeInterval currentInterval;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) void (^animationCompletionBlock) (BOOL);





@end

@implementation FaceAnimationView



#pragma mark - CALayer stuff
-(void) layoutSublayersOfLayer:(CALayer *)layer
{
    CGRect bounds = self.layer.bounds;
//    printf("\r\n%f, %f\r\n", bounds.size.width, bounds.size.height);
    self.keyFrameAnimatedLayer.frame = bounds;
//    self.staticImageLayer.cornerRadius = bounds.size.height / 2;
//    self.staticImageLayer.frame = bounds;
    
}

#pragma mark - Private API
-(void)setHasToAnimateFace:(BOOL)hasToAnimateFace
{
    self.shouldAnimateFace = hasToAnimateFace;
}

-(BOOL)hasToAnimateFace
{
    return self.shouldAnimateFace;
}

#pragma mark - Public API

- (BOOL)setNewFaceAnimationFromName:(NSString *)animationName
{
    AnimationsCreator *lvCreator = [[AnimationsCreator alloc] init];
    CAKeyframeAnimation *newAnimation/*CAAnimationGroup *newAnimation*/ = /*[lvCreator getFaceAnimationGroupByStartName:animationName animationRepeatInterval:7];*/[lvCreator animationForEmotionType:KaraAnimationTypeFace emotionNamed:animationName];
    if (newAnimation)
    {
        dispatch_semaphore_t waiterSemathore = dispatch_semaphore_create(0);
        
        [self stopAnimatingFaceImmediately:YES withCompletion:^(BOOL completed)
        {
            if (completed)
            {
//                NSLog(@" _ FACE_Animation  ___ Stopped animations");
            }
            dispatch_semaphore_signal(waiterSemathore);
         
        }];
        
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC);
        dispatch_semaphore_wait(waiterSemathore, timeout);
       // dispatch_release(waiterSemathore);
        
        self.faceAnimation = newAnimation;
//        self.faceAnimationGroup = newAnimation;
        self.shouldAnimateFace = YES;
        return YES;
    }
    
    return NO;
}

- (NSTimeInterval)defaultBetweenAnimationsInterval
{
    NSTimeInterval currentInterval = self.currentInterval;
    
    return currentInterval;
}

-(void) addLayersIfNotExist
{
    if (!self.keyFrameAnimatedLayer) //prepare layer if not exist
    {
        self.keyFrameAnimatedLayer = [[CALayer alloc] init];
        self.keyFrameAnimatedLayer.frame = self.bounds;
        [self.layer addSublayer:self.keyFrameAnimatedLayer];
//        self.keyFrameAnimatedLayer.borderWidth = 1.0;
    }
    
//    if (!self.staticImageLayer) //prepare layer if not exist
//    {
//        self.staticImageLayer = [[CALayer alloc] init];
//        self.staticImageLayer.frame = self.bounds;
//        self.staticImageLayer.masksToBounds = YES;
//        self.staticImageLayer.borderWidth = 3.0;
//        self.staticImageLayer.borderColor = [UIColor yellowColor].CGColor;
//        [self.layer insertSublayer:self.staticImageLayer below:self.keyFrameAnimatedLayer];
//        
//    }
}

-(void) startAnimatingFaceWithInterval:(NSTimeInterval) betweenAnimationsInterval
{
    self.currentInterval = betweenAnimationsInterval;
    
    if (self.animationTimer && self.animationTimer.isValid)
    {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
    
    [self addLayersIfNotExist];
    
//    self.staticImageLayer.contents = self.faceAnimation.values.firstObject;
    //trigger repeating animations
    if (self.shouldAnimateFace)
    {
        [self playCurrentAnimation];
    }
}


-(void) setNewBetweenAnimationsInterval:(NSTimeInterval) newInterval
{
    self.currentInterval = newInterval;
}

-(void) stopAnimatingFaceImmediately:(BOOL)stopImmediately withCompletion:(void(^)(BOOL completed))completionBlock
{
    self.animationCompletionBlock = nil;
    
    if (self.animationTimer)
    {
        if (self.animationTimer.isValid)
        {
            //NSLog(@"- stopAnimatingFaceImmediately.  Invalidating timer");
            [self.animationTimer invalidate];
        }
        
        self.animationTimer = nil;
    }
    self.shouldAnimateFace = NO;
    
    if (stopImmediately)
    {
//        NSLog(@"- stopAnimatingFaceImmediately.  removing all animations");
        [self.keyFrameAnimatedLayer removeAllAnimations];
//        [self.staticImageLayer removeAllAnimations];
        
        //self.faceAnimation = nil;
        
        if (completionBlock)
        {
            completionBlock(YES);
        }
        
    }
    else
    {
        if (completionBlock) //store recieved completion block to local property to use when animation completes
        {
            self.animationCompletionBlock = completionBlock;
        }
    }
}


#pragma Private API

-(void) playCurrentAnimation
{
    if (self.animationTimer)
    {
        if (self.animationTimer.isValid)
        {
            [self.animationTimer invalidate];
        }
        
        self.animationTimer = nil;
    }
    
    __weak FaceAnimationView *weakSelf = self;
    if (self.shouldAnimateFace)
    {
        //start animating
        [self animateKeyFrameLayerWithCompletion:^
        {
            //NSLog(@"\r animateKeyFrameLayerWithCompletion  fired completion block");
            if (weakSelf.shouldAnimateFace) //if nothing changed during animation
            {
                //NSLog(@"\r animateKeyFrameLayerWithCompletion Scheduling next animation...");
                self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.currentInterval target:self selector:@selector(playCurrentAnimation) userInfo:nil repeats:NO];
            }
            else //if stopAnimation with immediately == NO called
            {
                //NSLog(@"\r animateKeyFrameLayerWithCompletion  - FaceAnimationView  Will not play face animation again ..  Checking if any completion Block present..");
                if (self.animationTimer)
                {
                    self.animationTimer = nil;
                }
                
//                if (self.faceAnimation)
//                {
//                    self.faceAnimation = nil;
//                }
                
                if (self.animationCompletionBlock) //if somebody waitts for our feedback
                {
                    //NSLog(@"\r animateKeyFrameLayerWithCompletion  found completion block, firing completion block");
                    self.animationCompletionBlock(YES);
                }
            }
            
        }];
    }
    else
    {
        //NSLog(@"\r playCurrentAnimation - FaceAnimationView  Will not play face animation again ..  Checking if any completion Block present");
        
        if (self.animationCompletionBlock) //if somebody waitts for our feedback
        {
            self.animationCompletionBlock(YES);
        }
        
    }
}

-(void) animateKeyFrameLayerWithCompletion:(void (^)(void))completionBlock
{

    if (self.animationCompletionBlock )
    {
        self.animationCompletionBlock = nil;
    }
    
    if (self.faceAnimation)
    {
//        CFTimeInterval duration = self.faceAnimation.duration;
        __weak FaceAnimationView *weakSelf = self;
//        [UIView animateWithDuration:0.5
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveLinear
//                         animations:^
//         {
             self.keyFrameAnimatedLayer.opacity = 1.0;
//             self.staticImageLayer.opacity = 0.0;
//             
//         }
//                         completion:^(BOOL finished)
//         {
//             
             [CATransaction begin];
             {
                 [CATransaction setCompletionBlock:^
                  {
                      //NSLog(@"CATransaction Finished animating face...");
                      if (weakSelf.shouldAnimateFace)
                      {
                          //NSLog(@" CATransaction animating fading");
//                          [UIView animateWithDuration:0.5
//                                                delay:duration
//                                              options:UIViewAnimationOptionCurveLinear
//                                           animations:^
//                           {
                               weakSelf.keyFrameAnimatedLayer.opacity = 1.0;
                           
//                               self.staticImageLayer.opacity = 1.0;
//                           }
//                                           completion:^(BOOL finished)
//                           {
                               if (completionBlock)
                                   completionBlock();
//                           }];
                      }
                      else
                      {
                          //NSLog(@" CATransaction NOT animating fading fading");
                          weakSelf.keyFrameAnimatedLayer.opacity = 1.0;
//                          self.staticImageLayer.opacity = 1.0;
                          if (completionBlock)
                              completionBlock();
                      }
                      
                      
                  }];
//                 NSLog(@"\n Playing face animation...");
                 weakSelf.image = nil;
                 [weakSelf.keyFrameAnimatedLayer addAnimation:weakSelf.faceAnimation forKey:@"repeatedKaraFaceAnimation"];
             }
             [CATransaction commit];
//         }];
    }
//    else
//    {
//        NSLog(@" \r ERROR!_  No Face Animation To play...\n");
//    }
    
  
}

@end
