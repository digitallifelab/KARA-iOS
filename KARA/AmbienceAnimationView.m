//
//  AmbienceAnimationView.m
//  Origami
//
//  Created by CloudCraft on 13.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AmbienceAnimationView.h"

@interface AmbienceAnimationView ()

@property (nonatomic, strong) CAKeyframeAnimation *animation;
@property (nonatomic, strong) CAKeyframeAnimation *ambientAnimation;

@property (nonatomic, assign) BOOL shouldProceedStartAnimation;
@property (nonatomic, strong) NSTimer *startTimer;



@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic ,strong) NSTimer *hideEmotionNameTimer;
@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) NSInteger currentPlayingVideoDuration;
@property (nonatomic, assign) NSInteger videoLoopsCounter;
@end

@implementation AmbienceAnimationView

#pragma mark CALayer
-(void) layoutSublayersOfLayer:(CALayer *)layer
{
    if (self.keyFrameAnimatedLayer != nil)
    {
        self.keyFrameAnimatedLayer.frame = self.layer.bounds;
    }
    
    //NSLog(@"keyframeAnimatedLayer Bounds: %@", NSStringFromCGRect(self.keyframeAnimatedLayer.bounds));
}

#pragma mark -

-(void) awakeFromNib
{
    if (!self.tapRecognizer)
    {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        self.tapRecognizer.numberOfTouchesRequired = 1;
        
        [self addGestureRecognizer:self.tapRecognizer];
        
        self.emotionNameLabel.text = @" ";
    }
}


-(void) handleTap:(UITapGestureRecognizer *)tapper
{
    //remove timer
    if (self.hideEmotionNameTimer)
    {
        if (self.hideEmotionNameTimer.isValid)
        {
            [self.hideEmotionNameTimer invalidate];
        }
        self.hideEmotionNameTimer = nil;
    }
    
    BOOL toShow = NO;
    if (self.emotionNameLabel.isHidden)
    {
        toShow = YES;
        self.emotionNameLabel.hidden = NO;
        self.emotionNameLabel.alpha = 0.1;
    }
    
    __weak typeof(self) weakSelf = self;
    NSTimeInterval duration = (tapper)?0.5:0.1; //hide fast
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
    {
        weakSelf.emotionNameLabel.alpha = (toShow)?1.0:0.0;
        weakSelf.emotionNameLabel.textColor = (toShow)?[UIColor whiteColor]:[UIColor yellowColor];
    }
                     completion:^(BOOL finished)
    {
        if (!toShow)
        {
            weakSelf.emotionNameLabel.hidden = YES;
        }
        else
        {
            //setup dissapearance timer
            if (!weakSelf.hideEmotionNameTimer)
            {
                weakSelf.hideEmotionNameTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:weakSelf selector:@selector(handleTap:) userInfo:nil repeats:NO];
            }
        }
    }];
}

- (void)displayEmotionName:(BOOL)display
{
    self.emotionNameLabel.hidden = !display;
    [self.emotionNameLabel setNeedsDisplay];
}

-(void) removeStartingAnimation
{
    self.animation = nil;
}

-(void) addAnimatedLayerIfNotExist
{
    if (!self.keyFrameAnimatedLayer)
    {
        self.keyFrameAnimatedLayer = [[CALayer alloc] init];
        CGRect selfBoundsRect = self.bounds;
        
        //everywhere is recommended to use integral values for dimensions.
        CGFloat width = floor(selfBoundsRect.size.width);
        CGFloat height = floor(selfBoundsRect.size.height);
        
        self.keyFrameAnimatedLayer.frame = CGRectMake(0.0, 0.0, width, height);
        self.keyFrameAnimatedLayer.position = self.center;
        self.keyFrameAnimatedLayer.drawsAsynchronously = YES;
        [self.layer addSublayer:self.keyFrameAnimatedLayer];
        
//        self.staticImageLayer = [[CALayer alloc] init];
//        self.staticImageLayer.frame = self.keyFrameAnimatedLayer.frame;
//        [self.layer insertSublayer:self.staticImageLayer below:self.keyFrameAnimatedLayer];
    }
}

-(void) setCurrentAnimation:(CAKeyframeAnimation *)keyFrameAnimation
{
    self.ambientAnimation = keyFrameAnimation;
}

-(CAKeyframeAnimation *)currentAnimation
{
    return self.ambientAnimation;
}

-(void) setCurrentAmbientAnimation:(CAKeyframeAnimation *)keyFrameAnimation
{
    if (self.keyFrameAnimatedLayer.animationKeys.count > 0)
    {
        [self.keyFrameAnimatedLayer removeAllAnimations];
    }
    
    self.ambientAnimation = nil;
    self.ambientAnimation = keyFrameAnimation;
}

-(CAKeyframeAnimation *) currentAmbienceAnimation
{
    return self.ambientAnimation;
}


//-(BOOL) setCurrentAnimationFromName:(NSString *)animationName
//{
//    
//    AnimationsCreator *lvCreator = [[AnimationsCreator alloc] init];
//    CAKeyframeAnimation *newAnimation = [lvCreator animationForEmotionType:KaraAnimationTypeAmbience
//                                                  emotionNamed:animationName];
//    if (newAnimation)
//    {
//        self.emotionNameLabel.text = NSLocalizedString(animationName, nil);
//        [self setCurrentAmbientAnimation: newAnimation]; //removes any playing animation
//        return YES;
//    }
//    
//    return NO;
//}

-(void) allowEndlessAnimation:(BOOL)allow
{
    self.shouldProceedStartAnimation = allow;
}

-(void) beginAnimating
{
    [self startAssignedAnimationWithCompletion:nil];
}

- (void) proceedAnimatingAmbience
{
    __weak AmbienceAnimationView *weakSelf = self;
    weakSelf.currentlyAnimating = NO;
    
    if (!self.didPlayStartingAnimation)
    {
        self.didPlayStartingAnimation = YES;
    }
    
    if (weakSelf.ambientAnimation)
    {
        
        [CATransaction begin];
        {
            [CATransaction setCompletionBlock:^
            {
                [CATransaction begin];
                {
                    [CATransaction setCompletionBlock:^
                     {
                         weakSelf.currentlyAnimating = NO;
                         [weakSelf setOpacity:0.2];
                         
                         if ([weakSelf.animationFinishDelegate respondsToSelector:@selector(animationView:didFinishAnimation:)])
                         {
                            [weakSelf.animationFinishDelegate animationView:weakSelf didFinishAnimation:weakSelf.ambientAnimation];
                         }
                     }];
                }
                [CATransaction commit];
            }];
            
            [weakSelf setOpacity:1.0];
            //weakSelf.keyFrameAnimatedLayer.opacity = 1.0;
            [weakSelf.keyFrameAnimatedLayer addAnimation:weakSelf.ambientAnimation forKey:@"ambienceAnimation"];
            
            if ([self.animationFinishDelegate respondsToSelector:@selector(animationView:didStartAnimation:)])
            {
                [weakSelf.animationFinishDelegate animationView:self didStartAnimation:weakSelf.ambientAnimation];
            }
        }
        [CATransaction commit];
    }
//    else
//    {
//        NSLog(@"\r Error!  ambiencwe animation is nil ");
//    }
}

- (void)stopAssignedAnimationWithCompletion:(void (^)(void))completion
{
    //NSLog(@"Ambience animation view - Removing all animations....");
    
    [self allowEndlessAnimation:NO];
    [self setOpacity:0.0];
    if (!self.emotionNameLabel.isHidden)
    {
        [self handleTap:nil];
    }
    self.animation = nil;
    self.ambientAnimation = nil;
    if (self.startTimer && self.startTimer.isValid)
    {
        [self.startTimer invalidate];
        self.startTimer = nil;
    }
    
    __weak AmbienceAnimationView *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [weakSelf.keyFrameAnimatedLayer removeAllAnimations]; //this causes CATransaction completion block to fire, so we call it after clearing up.
        weakSelf.ambientAnimation = nil;
        weakSelf.animation = nil;
        
        
        if (completion)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                           {
                               if (!weakSelf.didPlayStartingAnimation)
                               {
                                   weakSelf.didPlayStartingAnimation = YES;
                               }
                               completion();
                           });
        }
    });
    
   
    
}

-(void)startAssignedAnimationWithCompletion:(void (^)(void))completion
{
    __weak AmbienceAnimationView *weakSelf = self;
    if (self.shouldProceedStartAnimation && !self.didPlayStartingAnimation)
    {
        [self animateLayersWithCompletion:^
        {
            weakSelf.startTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:weakSelf selector:@selector(startAssignedAnimationWithCompletion:) userInfo:nil repeats:NO];
        }];
    }
    else if (self.shouldProceedStartAnimation && self.didPlayStartingAnimation)
    {
        [self proceedAnimatingAmbience];
    }
    else if( self.startTimer && self.startTimer.isValid)
    {
        [self.startTimer invalidate];
        self.startTimer = nil;
    }
    
    
}

-(void) animateLayersWithCompletion:(void(^)(void)) completionBlock
{
    self.currentlyAnimating = YES;
    __weak AmbienceAnimationView *weakSelf = self;
    
    if (weakSelf.didPlayStartingAnimation)
    {
        [weakSelf proceedAnimatingAmbience];
    }
    [CATransaction begin];
    {
        [CATransaction setCompletionBlock:^
         {
//            NSLog(@"\r End Start Animation");
             
            //ended start animation
             weakSelf.didPlayStartingAnimation = YES;
             [weakSelf.keyFrameAnimatedLayer removeAnimationForKey:@"startAnimation"];
             [weakSelf removeStartingAnimation];
             weakSelf.shouldProceedStartAnimation = NO;

             if (weakSelf.ambientAnimation)
             {
                 [CATransaction begin];
                 {
                     [weakSelf addAnimatedLayerIfNotExist];
                     [CATransaction setCompletionBlock:^
                      {
                          //NSLog(@"End Ambience animation");
                          weakSelf.currentlyAnimating = NO;
                          
                          if (completionBlock) //from startAssignedAnimationWithCompletion:  to start next iteration of animaton.
                              completionBlock();
                      }];
                     
                     if (weakSelf.ambientAnimation)
                     {
//                         NSLog(@"animateLayersWithCompletion:  CompletionBlock Ambient Animation Frames Count: %ld Times Count: %ld ", (long) weakSelf.animation.values.count, (long)weakSelf.animation.keyTimes.count);
                         
                         [weakSelf.keyFrameAnimatedLayer addAnimation:weakSelf.ambientAnimation forKey:@"ambienceAnimation"];
                     }
                 }
                 [CATransaction commit];
             }
             else
             {
                 if (completionBlock)
                     completionBlock();
             }
         }];

        
        weakSelf.keyFrameAnimatedLayer.opacity = 0.1;
        [UIView animateWithDuration:0.5
                         animations:^
        {
            weakSelf.keyFrameAnimatedLayer.opacity = 1.0;
            if (weakSelf.animation)
            {
                [weakSelf.keyFrameAnimatedLayer addAnimation:weakSelf.animation forKey:@"startAnimation"];
            }
        }];
    }
    [CATransaction commit];
}

-(void)setOpacity:(CGFloat)opacity
{
    [self.keyFrameAnimatedLayer removeAnimationForKey:@"test"];
    float currentOpacity = 1.0;
    if (self.keyFrameAnimatedLayer.opacity < 0.5 && opacity > self.keyFrameAnimatedLayer.opacity)
    {
        currentOpacity = 0.0;
    }
    else if (self.keyFrameAnimatedLayer.opacity == opacity == 1)
    {
        currentOpacity = 0.0;
    }
    
    CATransition *alphaTransition = [CATransition animation];
    alphaTransition.startProgress = currentOpacity;//self.keyFrameAnimatedLayer.opacity;// self.keyFrameAnimatedLayer.opacity;
    alphaTransition.endProgress = opacity;
    alphaTransition.type = kCATransitionFade;
    alphaTransition.duration = 0.3;
    alphaTransition.removedOnCompletion = YES;
//    NSLog(@"\r - current opacity: %.02f, target opacity: %.02f \r", currentOpacity, opacity);
    
    [self.keyFrameAnimatedLayer addAnimation:alphaTransition forKey:@"test"];

}

#pragma mark - Video Animations
-(void) playAnimationNamed:(NSString *)name forMinutes:(NSInteger)minutes
{
    //NSLog(@"\r ____---___--_  playAnimationNamed: \"%@\" forMinutes: \"%ld\" CALLED", name, (long) minutes);
    self.emotionNameLabel.text = NSLocalizedString(name, nil);

    NSURL *videoFileUrl = [[NSBundle mainBundle] URLForResource:name withExtension:@"mov"];
    if (!videoFileUrl)
    {
        videoFileUrl = [[NSBundle mainBundle] URLForResource:@"joy" withExtension:@"mov"];
        //NSLog(@"Playing JOY debug animation");
    }
    AVAsset *videoAsset = [AVAsset assetWithURL:videoFileUrl];
    AVPlayerItem *currentPlayedItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];//initWithURL:videoFileUrl];
    float rate = 1.0;
//    if ([name isEqualToString:@"confidence"])
//    {
//        rate = 0.6;
//    }
    if([self playVideoItem:currentPlayedItem forMinutes:minutes atRate:rate])
    {
       __weak typeof(self) weakSelf = self;
       if (weakSelf.animationFinishDelegate && [weakSelf.animationFinishDelegate respondsToSelector:@selector(animationView:didStartVideoAnimationWithName:)])
       {
           [weakSelf.animationFinishDelegate animationView:self didStartVideoAnimationWithName:name];
       }
    }
}

-(BOOL) playVideoItem:(AVPlayerItem *)playerItem forMinutes:(NSInteger)minutes atRate:(float)playbackRate
{
    //NSLog(@"\r - playVideoItem:forMinutes:  CALLED, Rate: %.02f", playbackRate);
    if (playerItem != nil)
    {
        if (self.playerLayer)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
            NSMutableArray *subLayers = [@[] mutableCopy];
            for (CALayer *lvLayer in subLayers)
            {
                [subLayers addObject:lvLayer];
            }
            for (CALayer *lvLayerNutable in subLayers)
            {
                [lvLayerNutable removeFromSuperlayer];
            }
            
            self.playerLayer = nil;
            
            for (UIImageView *lvImageView in self.subviews)
            {
                [lvImageView removeFromSuperview];
            }
        }
        
        //remove header and footer, which hide edges of video frame
        [[self viewWithTag:0x2B] removeFromSuperview];
        [[self viewWithTag:0x2C] removeFromSuperview];
        
        self.currentPlayingVideoDuration = minutes;
        
        self.videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.videoPlayer.rate = playbackRate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVideoEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.videoPlayer.currentItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVideoFailure:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.videoPlayer.currentItem];
        
        self.playerLayer = [[AVPlayerLayer alloc] init];
        [self.playerLayer setPlayer:self.videoPlayer];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.name = @"VideoPlayer";
        
        [self.layer addSublayer:self.playerLayer];
        
        
        UIImageView *lvVideoHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video-header"]];
        lvVideoHeader.frame = CGRectMake(0.0, -26.0, self.bounds.size.width, 52.0);
        lvVideoHeader.tag = 0x2B;
        //lvVideoHeader.layer.borderWidth = 1.0;
        [self addSubview:lvVideoHeader];
        
        
        UIImage *footerImage = [UIImage imageNamed:@"video-footer"];
        UIImageView *lvVideoFooter = [[UIImageView alloc] initWithImage: footerImage];
        lvVideoFooter.frame = CGRectMake(0.0, self.bounds.size.height - 26.0 , self.bounds.size.width, 52.0);
        lvVideoFooter.tag = 0x2C;
        //lvVideoFooter.layer.borderWidth = 1.0;
        [self addSubview:lvVideoFooter];
        
        //hide unsmooth video appearing
        UIImageView *lvVideoRevealer = [[UIImageView alloc] initWithFrame:self.bounds];
        lvVideoRevealer.image = [UIImage imageNamed:@"video-reveal"];
        [self addSubview:lvVideoRevealer];
        //lvVideoRevealer.layer.borderWidth = 1.0;
        
        [UIView animateWithDuration:1.0
                              delay: 0.2
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             [lvVideoRevealer setAlpha:0.0];
         }
                         completion:^(BOOL finished)
         {
             [lvVideoRevealer removeFromSuperview];
         }];
        
        [self.videoPlayer play];
        
        return YES;
    }
    
    //NSLog(@"\r playVideoItem:forMinutes: - Error - Could not play video .....\r");
    return NO;
}

-(void) stopPlayingCurrentAnimationWithCompletion:(void(^)(NSString *stoppedAnimationName))completionBlock
{
    //NSLog(@"\r - Stopping playing video");
    //unsubscribe from "playeback end" notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    //remove header and footer, which hide edges of video frame
    [[self viewWithTag:0x2B] removeFromSuperview];
    [[self viewWithTag:0x2C] removeFromSuperview];
    
    [self.videoPlayer replaceCurrentItemWithPlayerItem:nil];

    [self.playerLayer removeFromSuperlayer];
    self.videoPlayer = nil;
    self.playerLayer = nil;

    self.emotionNameLabel.text = @"";
    self.currentPlayingVideoDuration = 0;
    self.videoLoopsCounter = 0;
    

    [self setNeedsDisplayInRect:self.bounds];
    
    if (completionBlock)
    {
        completionBlock(self.emotionNameLabel.text);
    }
   
    __weak typeof(self) weakSelf = self;
    
    if (weakSelf.animationFinishDelegate && [weakSelf.animationFinishDelegate respondsToSelector:@selector(animationView:didFinishVideoAnimation:)])
    {
        [weakSelf.animationFinishDelegate animationView:self didFinishVideoAnimation:self.emotionNameLabel.text];
    }
    
    
    
   
}

-(UIImage *) pauseForTakingScreenshot
{
    [self.videoPlayer pause];
    AVPlayerItem *lvCurrentPlayedItem = self.videoPlayer.currentItem;
    AVAsset *lvAsset = lvCurrentPlayedItem.asset;
    UIImage *videoFrame = [self loadScreenshotImageForAsset:lvAsset];
    
    return videoFrame;
}
-(void) resumeAfterPausing
{
    [self.videoPlayer play];
}

- (UIImage*)loadScreenshotImageForAsset:(AVAsset *)asset
{
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
//    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    UIImage *toReturnImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return toReturnImage;
    
}

#pragma mark AVPlayerItem notifications
-(void)handleVideoEnd:(NSNotification *)playerItemNotification
{
    self.videoLoopsCounter += 1;
    
    //this code plays video once again
    AVPlayerItem *playedVideo = playerItemNotification.object;
    if ( self.videoLoopsCounter < floor((self.currentPlayingVideoDuration * 60 / CMTimeGetSeconds(playedVideo.duration))) ) //if played video for less than 1 minute, repeat it
    {
        //rewind and repeat
        //NSLog(@"\\ RewindingVideo : %ld time", (unsigned long)self.videoLoopsCounter);
        [playedVideo seekToTime:kCMTimeZero];
        
        //alternative with completion handler
        //[playedVideo seekToTime:kCMTimeZero completionHandler:^(BOOL finished){}];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self stopPlayingCurrentAnimationWithCompletion:^(NSString *stoppedAnimationName)
    {
        if (weakSelf.animationFinishDelegate && [weakSelf.animationFinishDelegate respondsToSelector:@selector(animationView:didFinishVideoAnimation:)])
        {
            [weakSelf.animationFinishDelegate animationView:weakSelf didFinishVideoAnimation:stoppedAnimationName];
        }
    }];
}

-(void)handleVideoFailure:(NSNotification *)playerItemNotification
{
    //NSLog(@"\r -__-  VideoPlaybackFailed...\r");
    [self stopPlayingCurrentAnimationWithCompletion:^(NSString *stoppedAnimationName)
    {
        __weak typeof(self) weakSelf = self;
        if (weakSelf.animationFinishDelegate && [weakSelf.animationFinishDelegate respondsToSelector:@selector(animationView:didFinishVideoAnimation:)])
        {
            [weakSelf.animationFinishDelegate animationView:self didFinishVideoAnimation:stoppedAnimationName];
        }
    }];
}
@end
