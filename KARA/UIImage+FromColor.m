//
//  UIImage+FromColor.m
//  Origami
//
//  Created by CloudCraft on 20.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "UIImage+FromColor.h"

@implementation UIImage (FromColor)
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
