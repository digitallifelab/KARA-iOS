//
//  IntroPageView.m
//  KARA
//
//  Created by CloudCraft on 28.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "IntroPageView.h"

@implementation IntroPageView

-(instancetype) initWithFrame:(CGRect)frame andInfo:(NSDictionary *)info
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    [self setupSubviews];
    [self setInfo:info];
    
    return self;
}

-(void) setupSubviews
{
    //views
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.topLabel.numberOfLines = 0;
    self.topLabel.font = [UIFont fontWithName:@"Segoe UI" size:21];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.topLabel];
    
    self.bottomLabel = [[UILabel alloc] init];
    self.bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomLabel.numberOfLines = 0;
    self.bottomLabel.font = [UIFont fontWithName:@"Segoe UI" size:17];
    self.bottomLabel.textAlignment = NSTextAlignmentJustified;
    self.bottomLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.bottomLabel];
    
    self.introImage = [[UIImageView alloc] init];
    self.introImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.introImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.introImage];
    
    //constraints
    NSDictionary *subViews = NSDictionaryOfVariableBindings(_topLabel, _bottomLabel, _introImage);
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat imageSizeFloat = screenSize.width / 1.5;
    NSNumber *imageToTop = @(30.0);
    NSNumber *imageToBottom = @(10.0);
    NSNumber *bottomLabelToBotton = @(70.0);
    if (screenSize.height < 500) //iPhone 4s
    {
        imageSizeFloat = screenSize.width / 2.0;
        bottomLabelToBotton = @(30);
    }
    
    NSNumber *imageSize = @(imageSizeFloat);
    
    NSDictionary *metrics = NSDictionaryOfVariableBindings(imageSize, imageToTop, imageToBottom, bottomLabelToBotton);
    //bottom label
    NSArray *bottomLabelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(24)-[_bottomLabel]-(24)-|" options:0 metrics:nil views:subViews];
    NSArray *bottomLabelVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomLabel]-(bottomLabelToBotton)-|" options:0 metrics:metrics views:subViews];
    [self addConstraints:bottomLabelHorizontalConstraints];
    [self addConstraints:bottomLabelVerticalConstraints];
    
    //top label
    
    NSArray *topLabelHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[_topLabel]-(8)-|" options:0 metrics:nil views:subViews];
    NSArray *topLabelVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(24)-[_topLabel]" options:0 metrics:nil views:subViews];
    [self addConstraints:topLabelVertical];
    [self addConstraints:topLabelHorizontal];
    
    
    //image view
    
    NSArray *imageViewVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_topLabel]-(imageToTop)-[_introImage(imageSize)]-(>=imageToBottom)-[_bottomLabel]"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:subViews];
    NSArray *imageViewHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"[_introImage(imageSize)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:subViews];
    
    NSLayoutConstraint *centerImage = [NSLayoutConstraint constraintWithItem:self.introImage
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0];
    
    [self addConstraints:imageViewVertical];
    [self addConstraints:imageViewHorizontal];
    [self addConstraint:centerImage];
    
}

-(void)setInfo:(NSDictionary *)info
{
    self.topLabel.text = [info objectForKey:@"header"];
    self.bottomLabel.text = [info objectForKey:@"footer"];
    self.introImage.image = [info objectForKey:@"image"];
}

-(void) drawRect:(CGRect)rect
{
    [self.introImage maskToCircle];
}


@end
