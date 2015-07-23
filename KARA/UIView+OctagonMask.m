//
//  UIView+OctagonMask.m
//  TestChatApp
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "UIView+OctagonMask.h"

@implementation UIView (OctagonMask)
-(void)maskToOctagon
{
    
    //prepare values to operate
    CGRect maskFrame = self.bounds;
    CGFloat height = maskFrame.size.height;
    CGFloat width = maskFrame.size.width;
    
    CGFloat cornerHipotenuze = floorf(self.bounds.size.width / 2.5);
    CGFloat cornerKatet = floor(sqrtf((cornerHipotenuze * cornerHipotenuze) / 2));
    
    
    
   
    //CGFloat fraction = 3.5; //higher value means smaller corners cut
    
    //create layer
    CAShapeLayer *octaMask = [CAShapeLayer layer];
    octaMask.frame = maskFrame;
    
    //configure path
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(cornerKatet, 0.0)]; //start at top and 1/3 to right from top left corner
    [maskPath addLineToPoint:CGPointMake(width - cornerKatet, 0.0)]; // line to 2/3 from top left corner
    [maskPath addLineToPoint:CGPointMake(width, cornerKatet)]; // down to 1/3 of height
    [maskPath addLineToPoint:CGPointMake(width, height - cornerKatet)]; //down to 2/3 of height
    [maskPath addLineToPoint:CGPointMake(width - cornerKatet, height)]; // left from right side down to 2/3 of bottom width
    [maskPath addLineToPoint:CGPointMake(cornerKatet, height)]; // to left again on 1/3
    [maskPath addLineToPoint:CGPointMake(0.0, height - cornerKatet)]; // to right edge 1/3 from bottom
    [maskPath addLineToPoint:CGPointMake(0.0, cornerKatet)]; // up towards top 1/3 from top
    [maskPath closePath]; //final line to first point at
    
    //set path to layer
    octaMask.path = maskPath.CGPath;
    
    //set layer to be mask
    
    self.layer.mask = octaMask;
}

-(void) maskToCircle
{
    CGRect maskFrame = self.bounds;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:maskFrame];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = maskFrame;
    shapeLayer.path = circlePath.CGPath;
    
    self.layer.mask = shapeLayer;
}

@end
