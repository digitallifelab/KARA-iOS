//
//  Intro VC.m
//  KARA
//
//  Created by CloudCraft on 28.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "IntroVC.h"
#import "IntroPageView.h"
#import "KaraPageControlView.h"
#import "KaraRangeWordsAnimationView.h"

@interface IntroVC ()<UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *proceedButton;
@property (nonatomic, strong) KaraPageControlView *pagerView;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSArray *introViews;
@property (nonatomic, weak) IBOutlet KaraRangeWordsAnimationView *wordsAnimationView;

@end

@implementation IntroVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView.delegate = self;
    //set initial intro page
    self.currentPage = 0;
    [self.proceedButton addTarget:self action:@selector(IntroProceedButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Prepare views to add to scrollview
    CGSize screenBounds = self.scrollView.bounds.size;
    NSMutableArray *lvIntroViews = [[NSMutableArray alloc] initWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++)
    {
        NSString *topKeyString = [NSString stringWithFormat:@"header%ld", (long)i];
        NSString *bottomKEyString = [NSString stringWithFormat:@"bottom%ld", (long)i];
        
        NSString *localizedHeader = NSLocalizedString(topKeyString, nil);
        NSString *localizedFooter = NSLocalizedString(bottomKEyString, nil);
        UIImage *introImage = [UIImage imageNamed:[NSString stringWithFormat:@"introImage%ld", (long)i]];
        if (!introImage) // i = 3  - will play animation of RangeWordsVC, so just add empry image
        {
            introImage = [[UIImage alloc] init];
        }
        CGRect lvPageFrame = CGRectMake(screenBounds.width * i, 0, screenBounds.width, screenBounds.height - 20);
        IntroPageView *lvIntroPage = [[IntroPageView alloc] initWithFrame:lvPageFrame
                                                                  andInfo:@{@"image":introImage, @"header":localizedHeader, @"footer":localizedFooter}];
        [lvIntroViews addObject:lvIntroPage];
    }
    self.introViews = lvIntroViews;
    
    NSInteger screensToShow = self.introViews.count;
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGSize contentSize = CGSizeMake(scrollViewSize.width * screensToShow, scrollViewSize.height);
    
    self.scrollView.contentSize = contentSize;
    UIEdgeInsets scrollViewInsets = self.scrollView.contentInset;
    if (scrollViewInsets.left != 0)
    {
        scrollViewInsets.left = 0.0;
    }
    [self.scrollView setContentInset:scrollViewInsets];
    
    for (IntroPageView *lvIntroPage in self.introViews)
    {
        [self.scrollView addSubview:lvIntroPage];
    }
    
    //add pager view
    if (!self.pagerView)
    {
        CGRect bounds = self.view.bounds;
        CGRect pagerFrame = CGRectMake(CGRectGetMidX(bounds) - 75, CGRectGetMaxY(bounds) - 40, 150, 40);
        
        self.pagerView = [[KaraPageControlView alloc] initWithFrame:pagerFrame andNumberOfPages:self.introViews.count];

        [self.view insertSubview:self.pagerView aboveSubview:self.scrollView];
    }
    
    [self adjustPager];
}

#pragma mark -

-(void)adjustPager
{
    CGFloat currentContentOffsetX = self.scrollView.contentOffset.x;
    
    CGFloat pageWidth =  self.scrollView.bounds.size.width;
    
    NSInteger currentPage = lroundf( currentContentOffsetX / pageWidth);
    self.currentPage = currentPage;
    [self.pagerView setCurrentPage:self.currentPage];
    
    if (self.currentPage == 5)//last page
    {
        self.proceedButton.hidden = NO;
    }
    else
    {
        self.proceedButton.hidden = YES;
    }
    
    if (self.currentPage == 3)
    {
        [self playRateWordsAnimation];
    }
    else
    {
        self.wordsAnimationView.alpha = 0.0;
        [self.view sendSubviewToBack:self.wordsAnimationView];
    }
}
-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.currentPage == 3)
    {
        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:0.2 animations:^
        {
            weakSelf.wordsAnimationView.alpha = 0.0;
            
        } completion:^(BOOL finished)
        {
            [weakSelf.view sendSubviewToBack:weakSelf.wordsAnimationView];
        }];
    }
}
-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self adjustPager];
    }
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustPager];
}

-(void) playRateWordsAnimation
{
    self.scrollView.scrollEnabled = NO;
    __weak typeof(self) weakSelf = self;
    self.wordsAnimationView.alpha = 1.0;
    NSArray *words = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Love", nil), NSLocalizedString(@"Happiness", nil), nil];
    [self.wordsAnimationView assignWords:words];
    
    [self.view bringSubviewToFront:self.wordsAnimationView];
    [self.wordsAnimationView animateLabelsRotationCompletion:^
    {
        weakSelf.scrollView.scrollEnabled = YES;
    }];
}

-(void) IntroProceedButtonPress:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"KaraIntroShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
