//
//  KaraRangeWordsAnimationView.m
//  KARA
//
//  Created by CloudCraft on 29.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "KaraRangeWordsAnimationView.h"
#import "UIView+OctagonMask.h"

@interface KaraRangeWordsAnimationView()

@property (nonatomic, strong) NSString *topWord;
@property (nonatomic, strong) NSString *bottomWord;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, weak) IBOutlet UIView *centerCircle;
@property (nonatomic, assign) CGPoint topCenter;
@property (nonatomic, assign) CGPoint bottomCenter;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;

@end


@implementation KaraRangeWordsAnimationView

-(instancetype)initWithFrame:(CGRect)frame andWords:(NSArray *)words
{
    self = [super initWithFrame:frame];
    
    self.topWord = words.firstObject;
    self.bottomWord = words.lastObject;
    
    [self setupSubviews:frame];
    
    return self;
}

-(void) setupSubviews:(CGRect)frame
{
    if (!self.topLabel)
    {
        self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.6, frame.size.height * 0.2)];
        self.topLabel.font = [UIFont fontWithName:@"Segoe UI" size:20.0];
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        self.topLabel.textColor = [UIColor whiteColor];
        self.topLabel.center = CGPointMake(CGRectGetMidX(frame), frame.size.height * 0.2);
        [self addSubview:self.topLabel];
    }
    
    if (!self.bottomLabel)
    {
        self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.6, frame.size.height * 0.2)];
        self.bottomLabel.font = [UIFont fontWithName:@"Segoe UI" size:20.0];
        self.bottomLabel.textAlignment = NSTextAlignmentCenter;
        self.bottomLabel.textColor = [UIColor whiteColor];
        self.bottomLabel.center = CGPointMake(CGRectGetMidX(frame), frame.size.height - frame.size.height * 0.2);
        [self addSubview:self.bottomLabel];
        
        self.topCenter = self.topLabel.center;
        self.bottomCenter = self.bottomLabel.center;
    }
    self.centerCircle.layer.cornerRadius = self.centerCircle.bounds.size.height / 2.0;
    self.centerCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    self.centerCircle.layer.borderWidth = 1.0;
    
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.centerCircle.layer.cornerRadius = self.centerCircle.bounds.size.height / 2.0;
    self.centerCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    self.centerCircle.layer.borderWidth = 1.0;
    
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [self setupSubviews:rect];
    [self maskToCircle];
}

-(void) assignWords:(NSArray *)words
{
    self.topLabel.text = words.firstObject;
    self.bottomLabel.text = words.lastObject;
    [self.topLabel sizeToFit];
    [self.bottomLabel sizeToFit];
}

-(void) animateLabelsRotationCompletion:(void(^)(void)) completionBlock
{
    CGPoint center = self.centerCircle.center;
    __block UILabel *toTopLabel;
    __block UILabel *toBottomLabel;

    toTopLabel = self.bottomLabel;
    toBottomLabel = self.topLabel;
    
    CGRect frame = self.bounds;
    
    self.topLabel.center = CGPointMake(CGRectGetMidX(frame), frame.size.height * 0.2);
    self.bottomLabel.center = CGPointMake(CGRectGetMidX(frame), frame.size.height - frame.size.height * 0.2);
    [self layoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^
         {
             toTopLabel.center = center;
             toBottomLabel.center = center;
             toTopLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
             toBottomLabel.transform = CGAffineTransformMakeScale(0.7, 0.7);
             toBottomLabel.layer.opacity = 0.65;
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.25
                                   delay:0.0
                                 options:UIViewAnimationOptionCurveEaseOut
                              animations:^
              {
                  toTopLabel.center = weakSelf.topCenter;
                  toBottomLabel.center = weakSelf.bottomCenter;
                  toTopLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                  toBottomLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                  toBottomLabel.layer.opacity = 1.0;
              }
                              completion:^(BOOL finished)
              {
                  weakSelf.didAnimateBottomToTop = YES;
                  
                  toTopLabel = weakSelf.topLabel;
                  toBottomLabel = weakSelf.bottomLabel;
                  [UIView animateWithDuration:0.25
                                        delay:0.5
                                      options:UIViewAnimationOptionCurveEaseIn
                                   animations:^
                   {
                       toTopLabel.center = center;
                       toBottomLabel.center = center;
                       toTopLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
                       toBottomLabel.transform = CGAffineTransformMakeScale(0.7, 0.7);
                       toBottomLabel.layer.opacity = 0.65;
                   }
                                   completion:^(BOOL finished)
                   {
                       [UIView animateWithDuration:0.25
                                             delay:0.0
                                           options:UIViewAnimationOptionCurveEaseOut
                                        animations:^
                        {
                            toTopLabel.center = weakSelf.topCenter;
                            toBottomLabel.center = weakSelf.bottomCenter;
                            toTopLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                            toBottomLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                            toBottomLabel.layer.opacity = 1.0;
                        }
                                        completion:^(BOOL finished)
                        {
                            if (completionBlock)
                                completionBlock();
                            
                        }];
                   }];
              }];
         }];
    });

    
}
@end
