//
//  WordsRangingVC.m
//  Origami
//
//  Created by CloudCraft on 02.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "WordsRangingSwitchVC.h"
#import "Constants.h"
#import "AnimationsCreator.h"


@interface WordsRangingSwitchVC ()//<UIScrollViewDelegate>

//@property (nonatomic, strong) NSMutableArray *animationPaths;

//@property (nonatomic, weak) IBOutlet UIScrollView *leftHiddenScrollView;
//@property (nonatomic, weak) IBOutlet UIScrollView *rightHiddenScrolLView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *centerRoundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *rotatingImageView;
@property (weak, nonatomic) IBOutlet UIView *tapContainerView;
@property (weak, nonatomic) IBOutlet UILabel *higlerLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;

@property (nonatomic) CGFloat currentContentOffset;

@property (nonatomic) CGPoint topCenter;
@property (nonatomic) CGPoint bottomCenter;

@property (strong, nonatomic) UITapGestureRecognizer *tapToChange;
- (void)changeRangingByTap:(UITapGestureRecognizer *)sender;

@end


@implementation WordsRangingSwitchVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.wordsToRange)
    {
        
    }
//    self.wordsToRange = @[@"Bravery", @"Cowardiсe"];
    self.centerRoundImageView.layer.borderColor = self.centerRoundImageView.tintColor.CGColor;
    self.centerRoundImageView.layer.borderWidth = 1.0;
    self.centerRoundImageView.layer.cornerRadius = self.centerRoundImageView.bounds.size.height / 2.0;
    
    self.tapToChange = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeRangingByTap:)];
    [self.tapContainerView addGestureRecognizer:self.tapToChange];
    //self.tapContainerView.userInteractionEnabled = YES;
    self.higlerLabel.text = NSLocalizedString(@"higher", nil);
    self.lowerLabel.text = NSLocalizedString(@"lower", nil);
    self.titleLabel.text = NSLocalizedString(@"RateEmotionsTitle", nil);
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //set content size to enable scrolling and assign self as delegate to handle scrolling
//    self.leftHiddenScrollView.contentSize = CGSizeMake(self.leftHiddenScrollView.bounds.size.width, 2 * self.leftHiddenScrollView.bounds.size.height);
//    self.leftHiddenScrollView.delegate = self;
//    self.rightHiddenScrolLView.contentSize = self.leftHiddenScrollView.contentSize;
//    self.rightHiddenScrolLView.delegate = self;
    
    //add labels and position them

    if (self.wordsToRange)
    {
        [self setUpRangingViews];
    }
    
    //after we assigned top and bottom centers(position animation targets)
    //we can prepare the needed animations
//    self.animationPaths = [NSMutableArray arrayWithCapacity:4];
    [self startRotatingMesh];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRotatingMesh];
}

#pragma mark -

-(void) setUpRangingViews
{
    CGFloat viewHeight = self.tapContainerView.bounds.size.height;
    CGFloat fromCenterHeight = self.tapContainerView.bounds.size.height / 5;
    CGFloat thirdPart = floorf( viewHeight / 3.0);
    //left label
    self.leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, thirdPart, 50, 40)];
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.leftLabel.font = [UIFont fontWithName:@"Segoe UI" size:25];
    self.leftLabel.textColor = [UIColor whiteColor];
    
    self.leftLabel.text = [self.wordsToRange firstObject];

    CGPoint leftCenter = self.leftLabel.center;
    leftCenter.x = CGRectGetMidX(self.tapContainerView.bounds);
    leftCenter.y = CGRectGetMidY(self.tapContainerView.bounds) - fromCenterHeight;
    [self.leftLabel sizeToFit];
    
    self.leftLabel.center = leftCenter;

    [self.tapContainerView addSubview:self.leftLabel];
    //right label
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, viewHeight - thirdPart , 50, 40)];
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.font = [UIFont fontWithName:@"Segoe UI" size:25];
    self.rightLabel.textColor = [UIColor whiteColor];
    
    self.rightLabel.text = [self.wordsToRange lastObject];

    CGPoint rightCenter = self.rightLabel.center;
    rightCenter.x = CGRectGetMidX(self.tapContainerView.bounds);
    rightCenter.y = CGRectGetMidY(self.tapContainerView.bounds) + fromCenterHeight;
    [self.rightLabel sizeToFit];
    
    self.rightLabel.center = rightCenter;
    
    //[self.tapContainerView insertSubview:self.rightLabel aboveSubview:self.rightHiddenScrolLView];
    [self.tapContainerView addSubview:self.rightLabel];
    self.leftLabel.layer.zPosition = 10;
    self.rightLabel.layer.zPosition = 11;
    
    self.topCenter = self.leftLabel.center;
    self.bottomCenter = self.rightLabel.center;
    
}

//-(void) createAnimatedPathsForViews//labels
//{
//    
//    //create animation for left item
//    //CGPoint leftUnconvertedPoint = self.leftHiddenScrollView.center;
//    CGPoint leftControlPoint = [self.view convertPoint:self.leftHiddenScrollView.center toView:self.tapContainerView];
//    
//    CGPoint rightControlPoint = [self.view convertPoint:self.rightHiddenScrolLView.center toView: self.tapContainerView];
//    
//    UIBezierPath *leftToBottomPath = [UIBezierPath bezierPath];
//    [leftToBottomPath moveToPoint:self.topCenter];
//    [leftToBottomPath addQuadCurveToPoint:self.bottomCenter controlPoint:leftControlPoint];
//    
//    [self.animationPaths addObject:leftToBottomPath];
//    
//    UIBezierPath *leftToTopPath = [UIBezierPath bezierPath];
//    [leftToTopPath moveToPoint:self.bottomCenter];
//    [leftToTopPath addQuadCurveToPoint:self.topCenter controlPoint:leftControlPoint] ;
//    
//    [self.animationPaths addObject:leftToTopPath];
//    
//    
//    UIBezierPath *rightToTopPath = [UIBezierPath bezierPath];
//    [rightToTopPath moveToPoint:self.bottomCenter];
//    [rightToTopPath addQuadCurveToPoint:self.topCenter controlPoint:rightControlPoint] ;
//    
//    [self.animationPaths addObject:rightToTopPath];
//    
//    UIBezierPath *rightToBottom = [UIBezierPath bezierPath];
//    [rightToBottom moveToPoint:self.topCenter];
//    [rightToBottom addQuadCurveToPoint:self.bottomCenter controlPoint:rightControlPoint] ;
//    
//    [self.animationPaths addObject:rightToBottom];
//}


-(void) animateViewToTop:(UIView *)toTopView andToBottom:(UIView *)toBottomView completion:(void(^)(void))completionBlock
{
    BOOL shouldAnimate = NO;
//    BOOL shouldReverseAnimationDirection = NO;
    
    if (toTopView == self.leftLabel && self.leftLabel.center.y != self.topCenter.y) //left should be at the top
    {
        shouldAnimate = YES;
//        shouldReverseAnimationDirection = YES;
    }
    else if (toTopView == self.rightLabel && self.rightLabel.center.y != self.topCenter.y) //right should be at the top
    {
        shouldAnimate = YES;
    }
    
    if (!shouldAnimate) //simply return
    {
        if (completionBlock)
            completionBlock();
    }
    else
    {
        CGPoint center = self.centerRoundImageView.center;
        UILabel *toTopLabel = (UILabel *)toTopView;
        UILabel *toBottomLabel = (UILabel *)toBottomView;
        __weak typeof(self) weakSelf = self;
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
                if (completionBlock)
                {
                    completionBlock();
                }
            }];
        }];
       
    }
    
    
    //old code
    //        //prepare animations
    //        UIBezierPath *leftPath;
    //        UIBezierPath *rightPath;
    //        if (!shouldReverseAnimationDirection)
    //        {
    //            leftPath = [self.animationPaths objectAtIndex:0];
    //            rightPath = [self.animationPaths objectAtIndex:2];
    //        }
    //        else
    //        {
    //            leftPath = [self.animationPaths objectAtIndex:1];
    //            rightPath = [self.animationPaths objectAtIndex:3];
    //        }
    //
    //        CAKeyframeAnimation *leftLabelAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //        leftLabelAnimation.path = leftPath.CGPath;
    //        leftLabelAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ;
    //        leftLabelAnimation.duration = 0.3;
    //
    //        CAKeyframeAnimation *rightLabelAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //        rightLabelAnimation.path = rightPath.CGPath;
    //        rightLabelAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] ;
    //        rightLabelAnimation.duration = 0.3;
    //
    //        __weak WordsRangingSwitchVC *weakSelf = self;
    //
    //         //perform animations
    //        [CATransaction begin];
    //        {
    //            [CATransaction setCompletionBlock:^
    //            {
    //                if (toTopView.center.y != weakSelf.topCenter.y)
    //                {
    //                    toTopView.center = weakSelf.topCenter;
    //                    toBottomView.center = weakSelf.bottomCenter;
    //                }
    //
    //
    //                if (completionBlock)
    //                    completionBlock();
    //            }];
    //
    //
    //            [self.leftLabel.layer addAnimation:leftLabelAnimation forKey:@"left"];
    //            [self.rightLabel.layer addAnimation:rightLabelAnimation forKey:@"left"];
    //
    //
    //
    //            //[self.leftLabel.layer addAnimation:self.animations.firstObject forKey:@"testLeftAnimation"];
    //            //[self.rightLabel.layer addAnimation:self.animations.lastObject forKey:@"testRightAnimation"];
    //        }
    //        [CATransaction commit];
}

-(UILabel *) currentTopLabel
{
    if (CGRectContainsPoint(self.leftLabel.frame, self.topCenter))
    {
        return self.leftLabel;
    }
    else if(CGRectContainsPoint(self.rightLabel.frame, self.topCenter))
    {
        return self.rightLabel;
    }
    else
    {
        //NSLog(@"\r - %@  Some error occured while determining ranging result", NSStringFromClass([self class]));
        return nil;
    }
}

//#pragma mark - UIScrollViewDelegate
//
//-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (scrollView == self.leftHiddenScrollView)
//    {
//       // NSLog(@" Left    did   begin dragging ");
//        self.rightHiddenScrolLView.scrollEnabled = NO;
//    }
//    else
//    {
//       // NSLog(@" Right   did   begin dragging ");
//        self.leftHiddenScrollView.scrollEnabled = NO;
//    }
//    
//    self.currentContentOffset = scrollView.contentOffset.y;
//    //NSLog(@"  Assigned current offset to : %.01f", self.currentContentOffset);
//}
//
//-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//   //NSLog(@"\n did END decelerating");
//    if (scrollView == self.leftHiddenScrollView)
//    {
//        //NSLog(@" Left     did   end decelerating ");
//        self.rightHiddenScrolLView.scrollEnabled = YES;
//    }
//    else
//    {
//        //NSLog(@" Right    did   end  decelerating ");
//        self.leftHiddenScrollView.scrollEnabled = YES;
//    }
//    
//    //this is needed because we will have contentOffset of scrollviews as (0,0)
//    self.currentContentOffset = - 2;
//    
//    //NSLog(@"  Assigned current offset to : %.01f", self.currentContentOffset);
//}
//
//-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate)// enable disabled scrollview
//    {
//        //NSLog(@"\n  WILL NOT deceletare");
//        if (scrollView == self.leftHiddenScrollView)
//        {
//            //NSLog(@" Left    did      end dragging ");
//            self.rightHiddenScrolLView.scrollEnabled = YES;
//        }
//        else
//        {
//            //NSLog(@" Right    did     end dragging ");
//            self.leftHiddenScrollView.scrollEnabled = YES;
//        }
//    }
//    else
//    {
//        //NSLog(@" WILL decelerate");
//    }
//}
//
//- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    __weak typeof(self) weakSelf = self;
//    CGFloat verticalVelocity = velocity.y;
//    if (scrollView == self.leftHiddenScrollView) //left scroll view
//    {
//        // if velocity is between 0 and 1 or minus 1 , we don`t react on user`s swipes or pans
//        if (verticalVelocity < - 1)
//        {
//            //animate left label to bottom and right label to top
//            scrollView.scrollEnabled = NO;
//            self.tapToChange.enabled = NO;
//            
//            [self animateViewToTop:self.rightLabel
//                       andToBottom:self.leftLabel
//                        completion:^
//            {
//                scrollView.scrollEnabled = YES;
//                weakSelf.tapToChange.enabled = YES;
//            }];
//        }
//        else if (verticalVelocity > 1)
//        {
//            //animate left label to top and right label to bottom
//            scrollView.scrollEnabled = NO;
//            self.tapToChange.enabled = NO;
//            
//            [self animateViewToTop:self.leftLabel
//                       andToBottom:self.rightLabel
//                        completion:^
//            {
//                scrollView.scrollEnabled = YES;
//                weakSelf.tapToChange.enabled = YES;
//            }];
//        }
//    }
//    else //right scroll view
//    {
//        // if velocity is between 0 and 1 or minus 1 , we don`t react on user`s swipes or pans
//        if (verticalVelocity < - 1)
//        {
//            //animate left label to top and right label to bottom
//            scrollView.scrollEnabled = NO;
//            self.tapToChange.enabled = NO;
//            
//            [self animateViewToTop:self.leftLabel
//                       andToBottom:self.rightLabel
//                        completion:^
//             {
//                 scrollView.scrollEnabled = YES;
//                 weakSelf.tapToChange.enabled = YES;
//             }];
//        }
//        else if (verticalVelocity > 1)
//        {
//            //animate left label to top and right label to bottom
//            scrollView.scrollEnabled = NO;
//            self.tapToChange.enabled = NO;
//            
//            [self animateViewToTop:self.rightLabel
//                       andToBottom:self.leftLabel
//                        completion:^
//             {
//                 scrollView.scrollEnabled = YES;
//                 weakSelf.tapToChange.enabled = YES;
//             }];
//        }
//    }
//}

#pragma mark - IBActions
- (IBAction) dismissSelf
{
    //Check if current emotions are stored for later responding, because the User did not range emotions
    
    [self.rangingDelegate wordsRangingSwitchCancelButtonTapped:self];
    //our presenting VC will dismiss us (our delegate)
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) doneTapped
{
    //our presenting VC will dismiss us (our delegate)
    
    WordsRangingSwitchResult result = WordsRangingSwitchResultFailure;
    //1 check positions of views
    UILabel *currentTopLabel = [self currentTopLabel];
    if (currentTopLabel == self.leftLabel)
    {
        // result Unchanged
//        NSLog(@"\r - Result Unchanged");
        result = WordsRangingSwitchResultUnchanged;
    }
    else if(currentTopLabel == self.rightLabel)
    {
        // result Changed
//        NSLog(@"\r - Result Cnahged");
        result = WordsRangingSwitchResultChanged;
    }
    else
    {
        //NSLog(@"\r - %@  Some error occured while determining ranging result", NSStringFromClass([self class]));
        return;
    }
    
    [self.rangingDelegate wordsRangingSwitchSubmitButtonTapped:self withResult:result];
}


- (void)changeRangingByTap:(UITapGestureRecognizer *)sender
{
    __weak typeof (self) weakSelf = self;
    if ([self currentTopLabel] == self.leftLabel)
    {
//        self.leftHiddenScrollView.scrollEnabled = NO;
//        self.rightHiddenScrolLView.scrollEnabled = NO;
        self.tapToChange.enabled = NO;
        
        [self animateViewToTop:self.rightLabel
                   andToBottom:self.leftLabel
                    completion:^
         {
//             weakSelf.leftHiddenScrollView.scrollEnabled = YES;
//             weakSelf.rightHiddenScrolLView.scrollEnabled = YES;
             weakSelf.tapToChange.enabled = YES;
         }];
    }
    else
    {
//        self.leftHiddenScrollView.scrollEnabled = NO;
//        self.rightHiddenScrolLView.scrollEnabled = NO;
        self.tapToChange.enabled = NO;
        
        [self animateViewToTop:self.leftLabel
                   andToBottom:self.rightLabel
                    completion:^
         {
//             weakSelf.leftHiddenScrollView.scrollEnabled = YES;
//             weakSelf.rightHiddenScrolLView.scrollEnabled = YES;
             weakSelf.tapToChange.enabled = YES;
         }];
    }
}

#pragma mark - background rotating
-(void) startRotatingMesh
{
    //animation of mesh rotating
    AnimationsCreator *animationCreator = [[AnimationsCreator alloc] init];
    CAAnimation *smoothRotationAnimation = [animationCreator animationForMesh];
    [self.rotatingImageView.layer addAnimation:smoothRotationAnimation forKey:@"rotationAnimation"];
}

-(void) stopRotatingMesh
{
    [self.rotatingImageView.layer removeAllAnimations];
}

-(void) dismissByCancelling
{
    [self dismissSelf];
}
@end
