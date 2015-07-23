//
//  TrendWordsVC.m
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "TrendWordsVC.h"
#import "TrendCell.h"
#import "TrendWordsSubordinateVC.h"
#import "Protocols.h"
#import "DataSource.h"
#import "ServerRequester.h"
#import "AnimationsCreator.h"

@interface TrendWordsVC ()<UITableViewDelegate, UITableViewDataSource, TrendWordTapDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *dismissRecognizer;

@property (nonatomic, weak) IBOutlet UITableView *trendsTable;
@property (nonatomic, weak) IBOutlet UIImageView *rotatingImageView;
@property (nonatomic, strong) NSDictionary *tappedWordDict;
@property (nonatomic, strong) NSTimer *bubblesTimer;

@property (nonatomic, assign) NSUInteger previousRow;
@property (nonatomic, assign) NSUInteger previousLabelNumber;


@end

@implementation TrendWordsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dismissRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissByPanFromLeftEdge:)];
    self.dismissRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:self.dismissRecognizer];
    
   // self.title = NSLocalizedString(@"Echoe", nil);
    self.trendsTable.delegate = self;
    self.trendsTable.dataSource = self;
    
    [self setupTransparentNavigationBar];
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//    if (height > 660)
//    {
        NSLayoutConstraint *tableHeightConstraint = [NSLayoutConstraint constraintWithItem:self.trendsTable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.75 constant:0.0];
        [self.view addConstraint:tableHeightConstraint];
//    }
    
    
    //Add title
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    [titleLabel setTextColor:[UIColor whiteColor]];
//    [titleLabel setFont:[UIFont fontWithName:@"Segoe UI" size:25]];
//    [titleLabel setText:self.title];
//    self.navigationItem.titleView = titleLabel;
    
    //Add left bar button for dismissing
    //left bar button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    [leftButton setImage:[UIImage imageNamed:@"button-arrow-left"]  forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
    [leftButton addTarget:self action:@selector(dismissByLeftBarButton) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [UIColor colorWithRed:90.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:0.8];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startAnimations];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopAnimations];
}

#pragma mark -
- (void) setupTransparentNavigationBar
{
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init]; //remove thin line under navigation bar
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Animations
-(void) startAnimations
{
    //animation of mesh rotating
    AnimationsCreator *animationCreator = [[AnimationsCreator alloc] init];
    CAAnimation *smoothRotationAnimation = [animationCreator animationForMesh];
    [self.rotatingImageView.layer addAnimation:smoothRotationAnimation forKey:@"rotationAnimation"];
    
    self.bubblesTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startPulsingBubbleWithCompletion:) userInfo:nil repeats:YES];
}

-(void) stopAnimations
{
    [self.rotatingImageView.layer removeAnimationForKey:@"rotationAnimation"];
    
    if (self.bubblesTimer.isValid)
    {
        [self.bubblesTimer invalidate];
    }
    self.bubblesTimer = nil;
}

-(void) startPulsingBubbleWithCompletion:(void(^)(void))completionBlock
{
    NSUInteger rowNumber = arc4random_uniform(5);
    if (rowNumber == self.previousRow)
    {
#ifdef DEBUG
        NSLog(@"\n - Recursing Row randomization");
#endif
        [self startPulsingBubbleWithCompletion:
        ^{
            
        }];
    }
    else
    {
        if (self.previousLabelNumber == 0 || self.previousLabelNumber == 2)
        {
            self.previousLabelNumber = 1;
        }
        else
        {
            self.previousLabelNumber = 2;
        }
        
        self.previousRow = rowNumber;
        
        UIView *lvImageView; //imageView actually
        NSIndexPath *currentAnimatingCellPath = [NSIndexPath indexPathForRow:self.previousRow inSection:0];
        TrendCell *lvCell = (TrendCell *)[self.trendsTable cellForRowAtIndexPath:currentAnimatingCellPath];
        lvImageView = [lvCell viewWithTag:self.previousLabelNumber];
        
        if (lvImageView)
        {
            AnimationsCreator *animator = [[AnimationsCreator alloc] init];
            CABasicAnimation *pulseAnimation = [animator pulseWordBubbleAnimation];
            [CATransaction begin];
            {
//                [CATransaction setCompletionBlock:^
//                 {
//                     if (lvImageView)
//                     {
//                         [lvImageView.layer removeAllAnimations];
//                     }
//                     
//                     if (completionBlock)
//                     {
//                         completionBlock();
//                     }
//                 }];
                
                [lvImageView.layer addAnimation:pulseAnimation forKey:@"pulsing"];
                
            }
            [CATransaction commit];
        }
    }
}

#pragma mark -
- (void)dismissByPanFromLeftEdge:(UIScreenEdgePanGestureRecognizer *)sender
{
    switch (sender.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            self.dismissRecognizer.enabled = NO;
            [self.dismissDelegate viewControllerWantsToDismiss:self];
        }
            break;
        default:
            break;
    }
}

-(void) dismissByLeftBarButton
{
    [self.dismissDelegate viewControllerWantsToDismiss:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.trendWords.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WordEcho *lvEcho = [self.trendWords objectAtIndex:indexPath.row];
    TrendCell *trendCell = (TrendCell *)[tableView dequeueReusableCellWithIdentifier:@"TrendWordCell" forIndexPath:indexPath];
    [trendCell.leftLabel setText: lvEcho.keyWord];
    [trendCell.rightLabel setText: lvEcho.word];
    trendCell.wordTapDelegate = self;
    
    return trendCell;
}

#pragma mark - UITableViewDelegate
//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    
//    
//}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.trendsTable.bounds.size.height / self.trendWords.count;
}
#pragma mark - TrendWordTapDelegate
-(void) trendWordHolderView:(UIView *)view didTapOnSubordinateWord:(NSString *)word
{
    self.tappedWordDict = @{word:@[@"first", @"second", @"third", @"fourth", @"fifth"]};
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self) weakTrendsVC = self;
    [[ServerRequester sharedRequester] getTrendLinkedWordsForWord:word
                                                   withCompletion:^(NSDictionary *successResponse, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if (!error)
         {
             if (successResponse.allKeys.count > 0)
             {
                 NSString *key = successResponse.allKeys.firstObject;
                 NSArray *valuesArray =  [successResponse objectForKey:key];
                 if (valuesArray.count > 5)
                 {
                     valuesArray = [valuesArray subarrayWithRange:NSMakeRange(0, 5)];
                 }
                 //all words should be capitalized
                 NSMutableArray *capitalizedStrings = [[NSMutableArray alloc] initWithCapacity:valuesArray.count];
                 for (NSString *lvWord in valuesArray)
                 {
                     NSString *capitalizedWord = [lvWord capitalizedString];
                     [capitalizedStrings addObject:capitalizedWord];
                 }
                 
                 weakTrendsVC.tappedWordDict = [NSDictionary dictionaryWithObject:capitalizedStrings forKey:key];
                 [weakTrendsVC performSegueWithIdentifier:@"ShowChildTrendWord" sender:weakTrendsVC];
             }
             else
             {
                 [weakTrendsVC showAlertWithTitle:NSLocalizedString(@"Sorry", nil)
                                          message:[NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"NoRelatedWords", nil), word]
                                 closeButtonTitle:NSLocalizedString(@"Close", nil)
                                   dismissHandler:nil];
             }
         }
         else
         {
             [weakTrendsVC showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                      message:error.localizedDescription
                             closeButtonTitle:NSLocalizedString(@"Close", nil)
                               dismissHandler:nil];
         }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowChildTrendWord"])
    {
        TrendWordsSubordinateVC *targetVC = segue.destinationViewController;
        NSDictionary *toPass = self.tappedWordDict;
        targetVC.shownWords = toPass;
    }
}



#pragma mark - Errors Alert view
-(void) showAlertWithTitle:(NSString *)title message:(NSString *) message closeButtonTitle:(NSString *)closeTitle dismissHandler:(void(^)(void)) closeBlock
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (closeBlock)
            closeBlock();
    }];
    [alertController addAction:closeAction];
    
    if (self.presentedViewController)
    {
        [self.presentedViewController presentViewController:alertController animated:NO completion:nil];
    }
    else
        [self presentViewController:alertController animated:YES completion:nil];
}









@end
