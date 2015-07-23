//
//  AnimatorFromSides.m
//  KARA
//
//  Created by CloudCraft on 06.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AnimatorFromSides.h"

@implementation AnimatorFromSides

-(instancetype) init
{
    self = [super init];
    if (self != nil)
    {
        self.transitionTime = 1.0;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionTime;
}

-(void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *transitionView = [transitionContext containerView];
    CGRect visibleBounds = transitionView.bounds;
    CGRect originalFrame;
    
    switch (self.transitionDirection)
    {
        case TransitionTypeFromLeftShow:
        case TransitionTypeToLeftHide:
        {
            originalFrame = CGRectOffset(visibleBounds, -visibleBounds.size.width, 0);
        }
            break;
        case TransitionTypeToRightHide:
        case TransitionTypeFromRightShow:
        {
            originalFrame = CGRectOffset(visibleBounds, visibleBounds.size.width, 0);
        }
            break;
        case TransitionTypeFromBottomShow:
        case TransitionTypeToBottomHide:
        {
            originalFrame = CGRectOffset(visibleBounds, 0, visibleBounds.size.height); // show from bottom
        }
            break;
        case TransitionTypeFromTopShow:
        case TransitionTypeToTopHide:
        {
            originalFrame = CGRectOffset(visibleBounds, 0, -visibleBounds.size.height);
        }
            break;
        default:
            originalFrame = CGRectZero; //default -> fall from top and hide to top
            break;
    }
    
    if (self.transitionDirection == TransitionTypeFromLeftShow ||
        self.transitionDirection == TransitionTypeFromRightShow ||
        self.transitionDirection == TransitionTypeFromBottomShow ||
        self.transitionDirection == TransitionTypeFromTopShow)
    {
        // show from left
        toVC.view.frame = originalFrame;
        [transitionView insertSubview:toVC.view aboveSubview:fromVC.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
        {
            toVC.view.frame = visibleBounds;
        }
                         completion:^(BOOL finished)
        {
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
        }];
    }
    else if (self.transitionDirection == TransitionTypeToLeftHide ||
             self.transitionDirection == TransitionTypeToRightHide ||
             self.transitionDirection == TransitionTypeToBottomHide ||
             self.transitionDirection == TransitionTypeToTopHide)
    {
        // dismiss to left
        [transitionView insertSubview:fromVC.view aboveSubview:toVC.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
        {
            fromVC.view.frame = originalFrame;
        }
                         completion:^(BOOL finished)
        {
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
        }];
    }
  
    
    
}

@end
