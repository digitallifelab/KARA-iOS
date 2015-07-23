//
//  AnimatorFromSides.h
//  KARA
//
//  Created by CloudCraft on 06.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    TransitionTypeFromLeftShow = 1,
    TransitionTypeToLeftHide,
    TransitionTypeFromRightShow,
    TransitionTypeToRightHide,
    TransitionTypeFromBottomShow,
    TransitionTypeToBottomHide,
    TransitionTypeFromTopShow,
    TransitionTypeToTopHide
}
TransitionType;

@interface AnimatorFromSides : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) TransitionType transitionDirection;
@property (nonatomic, assign) NSTimeInterval transitionTime;

@end
