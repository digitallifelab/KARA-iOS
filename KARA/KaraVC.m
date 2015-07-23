//
//  KaraVC.m
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "KaraVC.h"

#import "Constants.h"
#import "Protocols.h"
#import "AmbienceAnimationView.h"
#import "FaceAnimationView.h"
#import "AnimatorFromSides.h"
#import "DonateHolderNavVC.h"
#import "DonateScreenVC.h"
#import "TrendWordsVC.h"
#import "TrendsHolderNavController.h"
#import "WordsRangingSwitchVC.h"
#import "ProfileVC.h"

#import "ServerRequester.h"
#import "FileHandler.h"

#import "KaraMessagingSentCell.h"
#import "KaraMessagingRecievedCell.h"
#import "EmotionsTimer.h"

#import <Social/Social.h>
#import "AppDelegate.h"
#import "IntroVC.h"
#import "UIView+ColorAtPoint.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger
{
    SocialNetworkTypeFacebook = 1,
    SocialNetworkTypeTwitter,
} SocialNetworkType;

@interface KaraVC ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,  UIViewControllerTransitioningDelegate, WordsRangingSwitchDelegate, DismissDelegate, AnimationCompletionDelegate, ProfileDelegate>//FBSDKSharingDelegate>

@property AnimatorFromSides *modalViewControllersAnimator;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeightConstraint; //to animate when text size(number of lines) changes
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textHolderToBottomConstraint; // to animate when keyboard appears or dismisses
@property (nonatomic, assign) CGFloat defaultHolderToBottom;
@property (nonatomic, assign) CGFloat defaultTextViewHeight;

@property(nonatomic, weak) IBOutlet UITableView *chatTable;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftScreenPan;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightScreenPan;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIView *textViewHolder;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UIButton *nothingInCommonButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nothingInCommonWidth;

@property (nonatomic, weak) IBOutlet UIButton *startChatButton;
@property (nonatomic, weak) IBOutlet UIButton *noButton;
@property (nonatomic, weak) IBOutlet UIButton *yesButton;
@property (nonatomic, assign) BOOL isAnsweringDefinitionQuestion;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) AVPlayer *videoPlayer;

@property (nonatomic, weak) IBOutlet UIButton *soundsButton;

//animation stuff
@property (nonatomic, weak) IBOutlet UIView *animationsHolderView;
@property (nonatomic, weak) IBOutlet FaceAnimationView *faceAnimationView;
@property (nonatomic, weak) IBOutlet AmbienceAnimationView *ambienceAnimationView;
@property (nonatomic, assign) BOOL isAnimatingAmbience;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *animationVerticalCenter;
//temp stuff
@property (nonatomic, strong) NSArray *animationNames;
@property (nonatomic, assign) NSUInteger currentAninationIndex;

@property (nonatomic, weak) IBOutlet UIImageView *meshImageView;

@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSNumber *editingMessageType;

@property (nonatomic, assign) BOOL needsToUnsubscribe;
@property (nonatomic, strong) Contact *currentKaraContact;
@property (nonatomic, strong) NSMutableArray *currentMessages;

@property (nonatomic, assign) BOOL shouldDisplayKaraQuestion;
@property (nonatomic, assign) BOOL didLoad;

//@property (nonatomic, assign) NSUInteger videoLoopsCounter;

@property (nonatomic, strong) Message *currentAnsweringQuestionMessage;

@property (nonatomic, strong) NSTimer *mesagesHidingTimer;

@end




@implementation KaraVC

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentMessages = [[NSMutableArray alloc] initWithArray:[DataSource sharedInstance].messages ];
    
    //add "swipe down" to close keyboard
    self.swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardFromSwipeDown:)];
    self.swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    self.swipeDownRecognizer.enabled = NO;// we enable it only when user sees keyboard
    [self.animationsHolderView addGestureRecognizer:self.swipeDownRecognizer];
    
    self.chatTable.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.chatTable.estimatedRowHeight = 33.0;
    self.chatTable.rowHeight = UITableViewAutomaticDimension;
   
    self.animationNames = Animation_Names_Array;//@[@"pain", @"sorrow", @"anxiety", @"apathy", @"ambience",  @"interest", @"confidence", @"joy", @"enjoyment"];
    self.currentAninationIndex = 4;
    
    self.ambienceAnimationView.animationFinishDelegate = self;
    
    [self setupTitleView];
    [self setupTransparentNavigationBar:YES];
    [self setupBarButtons];
    
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];

    //design of bottom button
    self.startChatButton.layer.cornerRadius = self.startChatButton.bounds.size.height / 2;
    self.startChatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startChatButton.layer.borderWidth = 1.0;
    [self.startChatButton.layer setShadowColor:[UIColor whiteColor].CGColor/*[UIColor blackColor].CGColor];*//*[UIColor colorWithRed:206/255.0 green:152/255.0 blue:149/255.0 alpha:1.0].CGColor]*/];
    [self.startChatButton.layer setShadowOpacity:0.7];
    [self.startChatButton.layer setShadowRadius:0.0];
    [self.startChatButton.layer setShadowOffset:CGSizeMake(0.0,0.0)];
    
    [self.yesButton setTitle:NSLocalizedString(@"answerYes", nil) forState:UIControlStateNormal];
    [self.noButton setTitle:NSLocalizedString(@"answerNo", nil) forState:UIControlStateNormal];
    self.yesButton.userInteractionEnabled = NO;
    self.noButton.userInteractionEnabled = NO;
    self.yesButton.alpha = self.noButton.alpha = 0.0;
    
    self.leftScreenPan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showDonateVC:)];
    self.leftScreenPan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:self.leftScreenPan];
    
    self.rightScreenPan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showTrendsVC:)];
    self.rightScreenPan.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.rightScreenPan];
    
    if (!self.currentKaraContact)
    {
        self.currentKaraContact = [[DataSource sharedInstance] getKaraContact];
    }

    if (self.currentMessages.count > 0)
    {
        self.chatTable.delegate = self;
        self.chatTable.dataSource = self;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimationsFromWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeAnimationsFromDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        // listen to "Change MOOD animation"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentAnimationIndexAndUpdateUI_ifVisible:) name:@"Change_Mood" object:nil];
    
   
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"messages" options:NSKeyValueObservingOptionNew context:nil];
    self.needsToUnsubscribe = YES;

    //refreshing for last messages every X seconds
    [[DataSource sharedInstance] startLastMessagesTimer];
    
    //to start animation from first appearing after login
    self.didLoad = YES;
    
    //this will help to see better the answer of user in chatTable on iPhone 4S
    if ([UIScreen mainScreen].bounds.size.height < 500)
    {
        self.animationVerticalCenter.constant = 40.0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    __weak typeof(self) weakSelf = self;
    [self.faceAnimationView stopAnimatingFaceImmediately:YES withCompletion:^(BOOL completed)
     {
        weakSelf.faceAnimationView.faceAnimation = nil;
    }];
//    [self.ambienceAnimationView stopAssignedAnimationWithCompletion:nil];
    
    [self.ambienceAnimationView stopPlayingCurrentAnimationWithCompletion:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardAppearing:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardAppearing:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFreshMesagesNotification:) name:@"LoadedNewMessages" object:[ServerRequester sharedRequester]];
//    [self checkToEnableSideButtons];
    [self.chatTable setAlpha:0.0];

    if([UIApplication sharedApplication].applicationIconBadgeNumber > 0)
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadedNewMessages" object:[ServerRequester sharedRequester]];
    [[DataSource sharedInstance] stopPlaying];
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.defaultTextViewHeight = self.textViewHeightConstraint.constant;
    self.defaultHolderToBottom = self.textHolderToBottomConstraint.constant;
    
    
    [self.faceAnimationView addLayersIfNotExist];
//    [self.ambienceAnimationView addAnimatedLayerIfNotExist];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"KaraIntroShown"])
    {
        self.didLoad = YES; //needed to start animating KARA after Intro screen dismissed
        [self showIntroVC];
        return;
    }

    
    if (self.didLoad)
    {
        //scroll to bottom message
        NSIndexPath *currentPath = [self.chatTable indexPathsForVisibleRows].lastObject;
        if (currentPath.row - 1 < self.currentMessages.count && self.currentMessages.count > 1)
        {
            NSIndexPath *bottomPath = [NSIndexPath indexPathForRow:self.currentMessages.count - 1 inSection:0];
            [self.chatTable scrollToRowAtIndexPath:bottomPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            CGFloat contentOffsetY = self.chatTable.contentOffset.y;
            [self.chatTable setContentOffset:CGPointMake(0.0, contentOffsetY + 10)];
        }
        else
        {
            [self.chatTable scrollToRowAtIndexPath:currentPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        self.didLoad = NO;
        
        //set current emotion
        EmotionsTimer *lvEmotionsTimer = [[EmotionsTimer alloc] init];
        
        NSUInteger emotionToShowFromStart = [lvEmotionsTimer getCurrentEmotionIndexFromLastBackgroundState];
        
        self.currentAninationIndex = emotionToShowFromStart;
        [lvEmotionsTimer postponeNextEmotionChangeInMinutes:(self.currentAninationIndex > 5)?10:5
                                        currentEmotionIndex:self.currentAninationIndex];
        
        //start animating emotions
        [self resumeAnimations];
        
        [self loadTrendWordsAsynchronously];
    }
    
    [self.chatTable setAlpha:1.0];
}

#pragma mark - INTRO
-(void) showIntroVC
{
    UIStoryboard *loginBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    IntroVC *karaIntro = [loginBoard instantiateViewControllerWithIdentifier:@"Intro"];
    [self presentViewController:karaIntro
                       animated:YES
                     completion:^
     {
         //karaIntro.delegate = self;
     }];
}

#pragma mark - 
- (void) setupTitleView
{
    UIImage *karaLogo = [UIImage imageNamed:@"Logo"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:karaLogo];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = CGRectMake(0, 0, 100, 35);

    self.navigationItem.titleView = titleImageView;
    
    UITapGestureRecognizer *navTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfileVC:)];
    navTapRecognizer.numberOfTouchesRequired = 1;
    navTapRecognizer.numberOfTapsRequired = 1;
    [titleImageView addGestureRecognizer:navTapRecognizer];
    titleImageView.userInteractionEnabled = YES;
}

- (void) setupTransparentNavigationBar:(BOOL)transparent
{
    if (transparent)
    {
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init]; //remove thin line under navigation bar
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
    }
    else
    {
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
        self.navigationController.navigationBar.backgroundColor = nil;
        
        self.navigationController.navigationBar.tintColor = Global_Tint_Color;
    }
}

-(void) setupBarButtons
{
    //left bar button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    [leftButton setImage:[UIImage imageNamed:@"button-arrow-left"]  forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
    [leftButton addTarget:self action:@selector(showDonateVC:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [UIColor colorWithRed:90.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:0.8];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    //right bar button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    [rightButton setImage:[UIImage imageNamed:@"button-arrow-right"] forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
    [rightButton addTarget:self action:@selector(showTrendsVC:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.tintColor = [UIColor colorWithRed:90.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:0.8];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;//@[rightFlexible, rightBarButton ];
}


#pragma mark - DELEGATES NATIVE
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentMessages.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *lvCurrentMessage = [self.currentMessages objectAtIndex:indexPath.row];
    if (lvCurrentMessage.creatorId.integerValue == self.currentKaraContact.contactId.integerValue)
    {
        KaraMessagingRecievedCell *recievedCell = (KaraMessagingRecievedCell *)[tableView dequeueReusableCellWithIdentifier:@"KaraRecievedCell" forIndexPath:indexPath];
        
        recievedCell.messageLabel.text = lvCurrentMessage.textBody;
        recievedCell.selectionStyle = UITableViewCellSelectionStyleNone;

        return recievedCell;
    }
    else
    {
        KaraMessagingSentCell *sentCell = (KaraMessagingSentCell *)[tableView dequeueReusableCellWithIdentifier:@"KaraSentCell" forIndexPath:indexPath];
        sentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sentCell.messageLabel.text = lvCurrentMessage.textBody;
        
        return sentCell;
    }
    return nil;
}

#pragma mark - UITextViewDelegate
-(void) textViewDidChange:(UITextView *)textView
{
    self.messageText = self.textView.text;
    
    //resize textview
    CGFloat toConstant = ceilf([self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)].height);
    if (toConstant != _textViewHeightConstraint.constant)
    {
        _textViewHeightConstraint.constant = toConstant;
    }

    [self.view layoutIfNeeded];
}


#pragma mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if (!self.modalViewControllersAnimator)
    {
        self.modalViewControllersAnimator = [[AnimatorFromSides alloc] init];
    }
    
    if ([presented isKindOfClass:[DonateHolderNavVC class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeFromLeftShow;
    }
    else if ([presented isKindOfClass:[TrendsHolderNavController class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeFromRightShow;
    }
    else if ([presented isKindOfClass:[WordsRangingSwitchVC class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeFromBottomShow;
    }
    else if ([presented isKindOfClass:[ProfileVC class]] || [presented isKindOfClass:[UINavigationController class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeFromTopShow;
    }
    
    
    // save CPU and battery
    self.ambienceAnimationView.animationFinishDelegate = nil;
    [self stopAnimationsWithCompletion:nil];
    
    if (self.isAnsweringDefinitionQuestion)
    {
        [self startAnsweringForDefinitionQiestion:NO animated:NO];
    }
    
    return self.modalViewControllersAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if (!self.modalViewControllersAnimator)
    {
        self.modalViewControllersAnimator = [[AnimatorFromSides alloc] init];
    }
    
    if ([dismissed isKindOfClass:[DonateHolderNavVC class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeToLeftHide;
    }
    else if ([dismissed isKindOfClass:[TrendsHolderNavController class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeToRightHide;
    }
    else if ([dismissed isKindOfClass:[WordsRangingSwitchVC class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeToBottomHide;
    }
    else if ([dismissed isKindOfClass:[ProfileVC class]] || [dismissed isKindOfClass:[UINavigationController class]])
    {
        self.modalViewControllersAnimator.transitionDirection = TransitionTypeToTopHide;
    }
    
    return self.modalViewControllersAnimator;
}

#pragma mark - Delegstes Custom
#pragma mark WordsRangingSwitchDelegate
-(void) wordsRangingSwitchCancelButtonTapped:(WordsRangingSwitchVC *)viewController
{
    //put message, cut from pending questions back to pending questions
    [[DataSource sharedInstance].pendingQuestions addObject:self.currentAnsweringQuestionMessage];
    
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive )
        {
            [weakSelf resumeAnimations];
        }
    }];
}

-(void) wordsRangingSwitchSubmitButtonTapped:(WordsRangingSwitchVC *)viewController withResult:(WordsRangingSwitchResult)result
{
    __weak typeof(self) weakKaraVC = self;
    [self dismissViewControllerAnimated:YES completion:^
    {
        [weakKaraVC resumeAnimations];
    }];
//    NSLog(@"\r %@ Ranging result : %lu", NSStringFromClass([self class]),(unsigned long)result);
    
    NSString *messageText;
    if (result == WordsRangingSwitchResultChanged)
    {
        messageText = [NSString stringWithFormat:@"#09#yes"];
    }
    else if (result == WordsRangingSwitchResultUnchanged)
    {
        messageText = [NSString stringWithFormat:@"#09#no"];
    }
    else if (result == WordsRangingSwitchResultFailure)
    {
        //return to default message type
        self.editingMessageType = @(0);
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:@"Something went wrong. Could not rate words." closeButtonTitle:NSLocalizedString(@"Close", nil)];
        return;
    }
    
    //return to default message type
    self.editingMessageType = @(9);
    
    //send result to server
//   Message *rangedMessage = [[DataSource sharedInstance] getRangeWordsQuestionMessage];
   [[ServerRequester sharedRequester] sendRateMessage:messageText
                                            toContact:self.currentKaraContact
                                       withCompletion:^(NSDictionary *successResponse, NSError *error)
    {
        if (error)
        {
            [weakKaraVC showAlertWithTitle:NSLocalizedString(@"WordsRatingError", nil)
                                   message:error.localizedDescription
                          closeButtonTitle:NSLocalizedString(@"Close", nil)];
        }
        else
        {
            weakKaraVC.currentAnsweringQuestionMessage.isNew = @(0);
            Message *userReadableAnswer = [[Message alloc] init];
            userReadableAnswer.creatorId = [ServerRequester sharedRequester].currentUser.userID;
            userReadableAnswer.isNew = @(NO);
            userReadableAnswer.dateCreated = [NSDate date];
            userReadableAnswer.typeId = @(0);
            NSRange yesRange = [messageText rangeOfString:@"yes"];
            BOOL didChange = yesRange.location != NSNotFound;
            
            NSArray *words = [weakKaraVC.currentAnsweringQuestionMessage.textBody componentsSeparatedByString:NSLocalizedString(@"spaceANDspace", nil)];
            //clear text
            NSMutableArray *rangedWords = [[NSMutableArray alloc] initWithCapacity:2];
            NSString *editedString;
            for (NSString *lvString in words)
            {
                if ([lvString containsString:@"."])
                    editedString = [lvString componentsSeparatedByString:@"."].firstObject;
                else
                    editedString = lvString;
                
                [rangedWords addObject:editedString];
            }
            NSString *newTextBody = [NSString stringWithFormat:@"%@ %@ %@", rangedWords.firstObject,(didChange)?@"<":@">" ,rangedWords.lastObject];

            userReadableAnswer.textBody = newTextBody;
            NSInteger countOfMessages = [[DataSource sharedInstance] countOfMessages];
            NSIndexSet *indexForTwoMessages = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(countOfMessages, 2)];
            //insert  question and answer to display in table
            [[DataSource sharedInstance] insertMessages:@[weakKaraVC.currentAnsweringQuestionMessage, userReadableAnswer]
                                              atIndexes:indexForTwoMessages];
            
        }
   }];
}

#pragma mark DismissDelegate
-(void) viewControllerWantsToDismiss:(UIViewController *)vc
{
    __weak typeof(self) weakSelf = self;
    self.ambienceAnimationView.animationFinishDelegate = self;
    [self dismissViewControllerAnimated:YES completion:^
    {
        [weakSelf resumeAnimations];
    }];
}
#pragma mark ProfileDelegate
-(void) profileViewController:(ProfileVC *)profileVC logoutButtonPressed:(UIBarButtonItem *)buttonItem
{
    __weak typeof(self)weakKaraVC = self;
    [self dismissViewControllerAnimated:YES completion:^
    {
        [weakKaraVC stopAnimationsWithCompletion:nil];
        [[DataSource sharedInstance].messagesUpdaterOperation cancel];//stopping loading new messages with interval
        [[DataSource sharedInstance] removeElements:[NSSet setWithArray:[DataSource sharedInstance].elements]];
        [[DataSource sharedInstance] removeMessages:nil];
        [[DataSource sharedInstance].echoes removeAllObjects];
        [[DataSource sharedInstance].pendingQuestions removeAllObjects];
        
        FileHandler *filer = [[FileHandler alloc] init];
        [filer deleteSavedUser];
        [filer deleteSavedMessages];
        
        weakKaraVC.chatTable.delegate = nil;
        weakKaraVC.chatTable.dataSource = nil;
        weakKaraVC.currentMessages = nil;
        
        [ServerRequester sharedRequester].currentUser = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CURRENT_USER_PASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [weakKaraVC.navigationController popToRootViewControllerAnimated:NO];
    }];
}

#pragma mark AnimationCompletionDelegate
-(void) animationView:(AmbienceAnimationView *)view didFinishAnimation:(CAKeyframeAnimation *)animation
{
    self.isAnimatingAmbience = NO;
}

-(void) animationView:(AmbienceAnimationView *)view didStartAnimation:(CAKeyframeAnimation *)animation
{
    self.isAnimatingAmbience = YES;
}

-(void) animationView:(AmbienceAnimationView *)view didStartVideoAnimationWithName:(NSString *)animationName
{
    if (animationName)
    {
//        NSLog(@"\r - Did START animating \"%@\" animation", animationName);
        self.isAnimatingAmbience = YES;
    }
    else
    {
//        NSLog(@"\r - Did START animating NO NAME animation");
        self.isAnimatingAmbience = NO;
    }
}

-(void) animationView:(AmbienceAnimationView *)view didFinishVideoAnimation:(NSString *)animationName
{
    if (!self.presentedViewController)
    {
        [self resumeAnimations];
    }
}

#pragma mark - IBActions
-(IBAction)sendMessageTap:(id)sender
{
    self.messageText = self.textView.text;
    
    [self.textView resignFirstResponder];
    //remove question from Kara if present
    [[self.textViewHolder viewWithTag:0xAA] removeFromSuperview];
    
    [self handleSendMessage];
}

-(IBAction)nothingInCommonTapped:(id)sender
{
    self.messageText = @"NНOИTЧHЕIГNОG";
    
    [self.textView resignFirstResponder];
    //remove question from Kara if present
    [[self.textViewHolder viewWithTag:0xAA] removeFromSuperview];
    
    [self handleSendMessage];
}

-(IBAction)startMessageTap:(id)sender
{
    if (self.isAnsweringDefinitionQuestion)
    {
        [self startAnsweringForDefinitionQiestion:NO animated:YES];
        return;
    }
    //user pressed ANSWER button
    if (!self.textView.isFirstResponder)
    {
        self.editingMessageType = @(10);
        [[self.textViewHolder viewWithTag:0xAA] removeFromSuperview];
    }
    
    dispatch_semaphore_t waiterSemathore = dispatch_semaphore_create(0);
    
    [self hideAnswersAfterInterval:0
                          animated:NO
                        completion:^{
                            dispatch_semaphore_signal(waiterSemathore);
                        }];
    
    
    dispatch_semaphore_wait(waiterSemathore, DISPATCH_TIME_FOREVER);
    Message *currentQuestion;

    currentQuestion = [[DataSource sharedInstance] getNextRandomQuestion]; // removes question from pendingQuestions
    
    if (currentQuestion == nil || currentQuestion.creatorId.integerValue != self.currentKaraContact.contactId.integerValue)
    {
        //NSLog(@"\r - Last message |is nil| or |is our respond|, do nothing.");
        [self startPulsingShadowAnimation:NO];
        return;
    }
    
    switch (currentQuestion.typeId.integerValue)
    {
        case 7: //assotiation question
        {
            self.currentAnsweringQuestionMessage = currentQuestion;
            [self questionButtonTap:nil];
        }
            break;
        case 8: //common between words
        {
            self.currentAnsweringQuestionMessage = currentQuestion;
            [self questionButtonTap:nil];
        }
            break;
        case 9: //range words
        {
            NSArray *wordsToRange = [currentQuestion.textBody componentsSeparatedByString:NSLocalizedString(@"spaceANDspace", nil)];
            NSString *editedString;
            NSMutableArray *toRange = [[NSMutableArray alloc] initWithCapacity:2];
            for (NSString *lvWord in wordsToRange)
            {
                if ([lvWord containsString:@"."])//cut the rest of second word
                    editedString = [lvWord componentsSeparatedByString:@"."].firstObject;
                else
                    editedString = lvWord;
                
                [toRange addObject:editedString];
            }
            self.currentAnsweringQuestionMessage = currentQuestion;
            if (toRange.count == 2)
            {
                 [self showWordsRangingVC:toRange];
            }
            else
            {
                [[DataSource sharedInstance].pendingQuestions addObject:self.currentAnsweringQuestionMessage];
            }
        }
            break;
        case 14:
        {
            self.currentAnsweringQuestionMessage = currentQuestion;
            [self startAnsweringForDefinitionQiestion:YES animated:YES];
        }
            break;
        default:
            break;
    }
}

-(IBAction)questionButtonTap:(id)sender
{
    //request question from Kara and start chat on success
    if (!self.currentAnsweringQuestionMessage)
    {
        self.currentAnsweringQuestionMessage = self.currentMessages.lastObject;
    }

    self.editingMessageType = (self.currentAnsweringQuestionMessage.typeId)?self.currentAnsweringQuestionMessage.typeId:0;

    //1 - switch to answering mode
    if (self.editingMessageType.integerValue > 0)
    {
        self.shouldDisplayKaraQuestion = YES;
        
        //2 - get last question from Kara if any
        NSAttributedString *attributed = [self makeAttributedStringFromString:self.currentAnsweringQuestionMessage.textBody];
        
        //3 - start answering - show keyboard and questionView above "message textView"
        [self addLastQuestionSubviewAboveTextInputWithQuestion:attributed];
        
        //4 - show keyboard
        [self.textView becomeFirstResponder];
    }
    else
    {
#ifdef DEBUG
        NSLog(@"\r - %@ No questions found", NSStringFromClass([self class]));
#endif
    }
}

-(void) startAnsweringForDefinitionQiestion:(BOOL)start animated:(BOOL)animate
{
    __weak typeof(self) weakKaraVC = self;
    if (start)
    {
        UIView *questionHolderView = [self makeQuestionDisplayLabelWithAttributedString:[self makeAttributedStringFromString:self.currentAnsweringQuestionMessage.textBody]];
        CGRect questionHolderFrame = questionHolderView.frame;
        CGFloat distanceToAnimationsViewBottom = CGRectGetMaxY(self.animationsHolderView.frame) ;
        
        questionHolderFrame.origin.y = distanceToAnimationsViewBottom;
        questionHolderView.frame = questionHolderFrame;
        
        questionHolderView.alpha = 0.1;
        [self.view addSubview:questionHolderView];
        
        [self.view setNeedsDisplayInRect:questionHolderFrame];
        
        self.isAnsweringDefinitionQuestion = YES;
        
        if (!animate)
        {
            questionHolderView.alpha = 1.0;
            weakKaraVC.noButton.alpha = 1.0;
            weakKaraVC.yesButton.alpha = 1.0;
            weakKaraVC.noButton.userInteractionEnabled = YES;
            weakKaraVC.yesButton.userInteractionEnabled = YES;
        }
        else
        {
            
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
            {
                questionHolderView.alpha = 1.0;
            }
                             completion:^(BOOL finished)
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^
                 {
                     weakKaraVC.noButton.alpha = 1.0;
                     weakKaraVC.yesButton.alpha = 1.0;
                 }
                                 completion:^(BOOL finished)
                 {
                     weakKaraVC.noButton.userInteractionEnabled = YES;
                     weakKaraVC.yesButton.userInteractionEnabled = YES;
                 }];
            }];
        }
    }
    else
    {
        __block UIView *questionHolderView = [self.view viewWithTag:0xAA];
        
        if (!animate) //urgent dismissing (app will resign active or another vc is called...)
        {
            [[DataSource sharedInstance].pendingQuestions addObject:weakKaraVC.currentAnsweringQuestionMessage];
            weakKaraVC.noButton.userInteractionEnabled = NO;
            weakKaraVC.yesButton.userInteractionEnabled = NO;
            weakKaraVC.noButton.alpha = 0.0;
            weakKaraVC.yesButton.alpha = 0.0;
            [questionHolderView removeFromSuperview];
            self.isAnsweringDefinitionQuestion = NO;
        }
        else
        {
            weakKaraVC.noButton.userInteractionEnabled = NO;
            weakKaraVC.yesButton.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 weakKaraVC.noButton.alpha = 0.0;
                 weakKaraVC.yesButton.alpha = 0.0;
             }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.2
                                       delay:0.0
                                     options:UIViewAnimationOptionCurveEaseInOut
                                  animations:^
                  {
                      
                      questionHolderView.alpha = 0.0;
                  }
                                  completion:^(BOOL finished)
                  {
                      [questionHolderView removeFromSuperview];
                      weakKaraVC.isAnsweringDefinitionQuestion = NO;
                  }];
             }];
        }
    }
}

-(IBAction)definitionQuestionAnswerButtonTapped:(UIButton *)sender
{
    //[self startAnsweringForDefinitionQiestion:NO animated:YES];
    
    NSString *typeId;
    NSNumber *currentAnsweringTypeId = self.currentAnsweringQuestionMessage.typeId;
    if (currentAnsweringTypeId)
        typeId = [NSString stringWithFormat:@"%ld", (long)currentAnsweringTypeId.integerValue];
    else
        typeId = @"14";
    
    NSString *answerToSend;
    NSString *yesString = NSLocalizedString(@"answerYes", nil);
    if ([sender.titleLabel.text isEqualToString:yesString])
        answerToSend = [NSString stringWithFormat:@"#%@#yes", typeId];
    else
        answerToSend = [NSString stringWithFormat:@"#%@#no", typeId];
    
    Message *lvMessage = [[Message alloc] init];
    lvMessage.textBody = answerToSend;
    
    __weak typeof (self) weakSelf = self;
    
    [[ServerRequester sharedRequester] sendMessage:lvMessage
                                         toContact:self.currentKaraContact
                                    withCompletion:^(NSDictionary *successResponse, NSError *error)
    {
        if (error)
        {
            [[DataSource sharedInstance].pendingQuestions addObject:weakSelf.currentAnsweringQuestionMessage];
        }
        
        [weakSelf startAnsweringForDefinitionQiestion:NO animated:YES];
        
    }];
    
}

-(IBAction)soundButtonTap:(id)sender
{
    [self enableSounds:sender];
}

-(IBAction)shareButtonTap:(id)sender
{
    /*Uncomment to use facebook custom story after approoval from facebook */
//    FBSDKAccessToken *fbToken = [FBSDKAccessToken currentAccessToken];
//    if ([fbToken.permissions containsObject:@"publish_actions"])
//    {
//          [self prepareInfoToShareAndPostToFacebook];
//    }
//    else
//    {
//        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//        [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
//         {
//             if (error)
//             {
//                 // Process error
//             }
//             else if (result.isCancelled)
//             {
//                 // Handle cancellations
//             }
//             else
//             {
//                 // If you ask for multiple permissions at once, you
//                 // should check if specific permissions missing
//                 if ([result.grantedPermissions containsObject:@"publish_actions"])
//                 {
//                     // Do work
//                     [self prepareInfoToShareAndPostToFacebook];
//                 }
//             }
//         }];
//    }
// 
//    
//    return;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] || [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        // 1 - scroll table to last message and hide all the messages except last one.
        NSUInteger allMessagesCount = self.currentMessages.count;
        __weak typeof(self) weakKaraVC = self;
        
        NSNumber *myUserId = [[DataSource sharedInstance]getCurrentUser].userID;
        
        NSInteger reverseCount = allMessagesCount - 1;
        for (Message *lvMessage in weakKaraVC.currentMessages.reverseObjectEnumerator)
        {
            if (lvMessage.creatorId == myUserId)
            {
                break;
            }
            reverseCount -= 1;
        }
        
        if (reverseCount >= 0)
        {
            NSIndexPath *lvToScroll = [NSIndexPath indexPathForRow:reverseCount inSection:0];
            [weakKaraVC.chatTable scrollToRowAtIndexPath:lvToScroll atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            
            NSInteger visibleCount = weakKaraVC.chatTable.visibleCells.count;
            
            NSInteger border = allMessagesCount - visibleCount;
            
            for (NSInteger i = allMessagesCount; i > border; i--)
            {
                if (visibleCount == 0)
                {
                    break;
                }
                UITableViewCell *lvVisibleCell = [weakKaraVC.chatTable.visibleCells objectAtIndex:visibleCount - 1];
                if (i != allMessagesCount)
                {
                    lvVisibleCell.alpha = 0;
                }
                visibleCount -= 1;
            }
        }
        
        // 2 - prepareViewForSnapshoting
        [weakKaraVC.ambienceAnimationView displayEmotionName:YES];
        
        [weakKaraVC.view setNeedsDisplay];
        
        //weakKaraVC.ambienceAnimationView.image = [UIImage imageWithCGImage:(CGImageRef) [[weakKaraVC.ambienceAnimationView.keyFrameAnimatedLayer presentationLayer] contents] ];
        weakKaraVC.ambienceAnimationView.image = [weakKaraVC.ambienceAnimationView pauseForTakingScreenshot];
        weakKaraVC.faceAnimationView.image = [UIImage imageWithCGImage:(CGImageRef)[[weakKaraVC.faceAnimationView.keyFrameAnimatedLayer presentationLayer] contents] ];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           //create screenshot of the needed area view
                           UIImage *screenshotImage = [self takeScreenshotForSharing];
                           [weakKaraVC.ambienceAnimationView resumeAfterPausing];
                           if (screenshotImage)
                           {
                               weakKaraVC.ambienceAnimationView.image = nil;
                               weakKaraVC.faceAnimationView.image = nil;
                               
                               NSURL *siteUrl = [NSURL URLWithString:@"http://thekaraproject.com/"];
                               //show actionSheet
                               UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                             {
                                                                 [weakKaraVC.ambienceAnimationView displayEmotionName:NO];
                                                                 
                                                                 for (UITableViewCell *lvCell in weakKaraVC.chatTable.visibleCells)
                                                                 {
                                                                     if (lvCell.alpha == 0.0)
                                                                     {
                                                                         lvCell.alpha = 1.0;
                                                                     }
                                                                 }
                                                                 
                                                             }];
                               
                               UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Share" message:@"Shoose social network" preferredStyle:UIAlertControllerStyleActionSheet];
                               
                               [actionSheet addAction:closeAction];
                               
                               if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
                               {
                                   UIAlertAction *shareViaFacebook = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                                      {
                                                                          [weakKaraVC shareToSocialNetwotkType:SocialNetworkTypeFacebook attachedImage:screenshotImage caption:@"KARA caption" message:@"An emotion I`ve got from KARA" attachedURL:siteUrl];
                                                                      }];
                                   [actionSheet addAction:shareViaFacebook];
                               }
                               
                               if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                               {
                                   UIAlertAction *shareViaTwitter = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                                     {
                                                                         [weakKaraVC shareToSocialNetwotkType:SocialNetworkTypeTwitter attachedImage:screenshotImage caption:@"KARA caption" message:@"An emotion I`ve got from KARA" attachedURL:siteUrl];
                                                                     }];
                                   [actionSheet addAction:shareViaTwitter];
                               }
                               
                               
                               if (actionSheet.actions.count > 1) //don`t present action sheet only with "Close" buttom
                               {
                                   [self presentViewController:actionSheet
                                                      animated:YES
                                                    completion:^
                                    {
                                        for (UITableViewCell *lvCell in weakKaraVC.chatTable.visibleCells)
                                        {
                                            if (lvCell.alpha == 0.0)
                                            {
                                                lvCell.alpha = 1.0;
                                            }
                                        }
                                    }];
                               }
                           }
                           else
                           {
                               [weakKaraVC.ambienceAnimationView displayEmotionName:NO];
                               weakKaraVC.ambienceAnimationView.hidden = NO;
//                               weakKaraVC.rateWordsBottomButton.hidden = NO;
                               for (UITableViewCell *lvCell in weakKaraVC.chatTable.visibleCells)
                               {
                                   if (lvCell.alpha == 0.0)
                                   {
                                       lvCell.alpha = 1.0;
                                   }
                               }
                           }
                       });
    }
    else
    {
        [self showAlertWithTitle:NSLocalizedString(@"sharing_disabled", nil)
                         message:NSLocalizedString(@"sharing_disabled_reason", nil)
                closeButtonTitle:NSLocalizedString(@"Close", nil)];
    }
}

#pragma mark Swipe Down
-(void)dismissKeyboardFromSwipeDown:(UISwipeGestureRecognizer *)swipeRecognizer
{
    //put message, cut from pending questions back to pending questions
    [[DataSource sharedInstance].pendingQuestions addObject:self.currentAnsweringQuestionMessage];
    
    self.messageText = nil;
    self.textView.text = @"";
    [self.textView resignFirstResponder];
}
#pragma mark -
- (void) addLastQuestionSubviewAboveTextInputWithQuestion:(NSAttributedString *)attributedTextToDisplay
{
    UIView *labelHolder = [self makeQuestionDisplayLabelWithAttributedString:attributedTextToDisplay];
    [self.textViewHolder addSubview:labelHolder];
}


-(void) quitTypingIfIsTyping
{
    if (self.textView.isFirstResponder)
    {
        self.textView.text = @"";
        [self.textView resignFirstResponder];
        
        if (self.currentAnsweringQuestionMessage)
        {
            [[DataSource sharedInstance].pendingQuestions addObject:self.currentAnsweringQuestionMessage];
            self.currentAnsweringQuestionMessage = nil;
        }
    }
}

-(UIImage *) takeScreenshotForSharing
{
    CGFloat originY = self.animationsHolderView.frame.origin.y;
    CGRect targetFrame = CGRectMake(0, originY, self.view.bounds.size.width, self.view.bounds.size.height - originY );
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(targetFrame.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(targetFrame.size);
    
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(void) handleSendMessage
{
    if (!(self.messageText && self.messageText.length > 0))
    {
        //NSLog(@"\r - %@ Error: Current message is nil or empty.\r - Will not send any message to server.\r\n", NSStringFromClass([self class]));
        [[DataSource sharedInstance].pendingQuestions addObject:self.currentAnsweringQuestionMessage];
        return;
    }
    
    //check for valid answer
    NSCharacterSet *validChars = [NSCharacterSet letterCharacterSet];
    NSString *checkString = [self.messageText stringByTrimmingCharactersInSet:[validChars invertedSet]];
    if (!(checkString && checkString.length > 0))
    {
        self.messageText = @"";
        [self showAlertWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"TextHasToContainLetters", nil) closeButtonTitle:NSLocalizedString(@"Close", nil)];
        
        return;
    }
    
    Message *newMessage = [[Message alloc] init];
    newMessage.elementId = self.currentKaraContact.elementId;
    newMessage.creatorId = [ServerRequester sharedRequester].currentUser.userID;
    newMessage.firstName = [ServerRequester sharedRequester].currentUser.firstName;
    newMessage.isNew = [NSNumber numberWithBool:YES];
    
    newMessage.typeId = @(0);//self.editingMessageType;
    
    if (self.editingMessageType.integerValue == 10)
    {
         //type opinion
        newMessage.textBody = [NSString stringWithFormat:@"#10#%@",self.messageText];
    }
    else if (self.editingMessageType.integerValue == 7) //assotiations for a word
    {
        newMessage.textBody = [NSString stringWithFormat:@"#07#%@", self.messageText];
        //debug
    }
    else if (self.editingMessageType.integerValue == 8) //a connection word between words
    {
        newMessage.textBody = [NSString stringWithFormat:@"#08#%@", self.messageText];
    }
    else
    {
        //type chat
        newMessage.textBody = self.messageText;
    }
    
    if (newMessage.textBody && newMessage.textBody.length > 0)
    {
        __block Message *copyMessage = newMessage;
        __weak typeof(self) weakKaraVC = self;
        
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^
        {
            [[ServerRequester sharedRequester] sendMessage:newMessage
                                                 toContact:self.currentKaraContact
                                            withCompletion:^(NSDictionary *successResponse, NSError *error)
             {
                 if (error)
                 {
                     [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                      {
                          [weakKaraVC showAlertWithTitle:@"Did not send message"
                                                 message:error.localizedDescription
                                        closeButtonTitle:@"close"];
                      }];
                 }
                 else
                 {
                     [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                      {
                          copyMessage.isNew = [NSNumber numberWithBool:NO];
                          weakKaraVC.currentAnsweringQuestionMessage.isNew = @(0);
                          
                          //also set new boolean in DataSourse`s messages
                          [[DataSource sharedInstance] setMessageWithText:weakKaraVC.currentAnsweringQuestionMessage.textBody toBeNew:NO];
                          
                          NSString *fixedText = [[ServerRequester sharedRequester] fixMessageBody:copyMessage.textBody];
                          if (fixedText)
                          {
                              copyMessage.textBody = fixedText;
                          }
                          //trigger KVO refresh chatVC table
                          NSIndexSet *indexToInsert = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([[DataSource sharedInstance] countOfMessages], 2)];
                          [[DataSource sharedInstance] insertMessages:@[weakKaraVC.currentAnsweringQuestionMessage, copyMessage]
                                                            atIndexes:indexToInsert];
                          
                      }];//end of operationQueue
                 }
             }];//end of sendMessage
        }];//end of operationQueue
    }
//    else
//    {
//        NSLog(@"\r - %@ Error: Current message is nil or empty.\r - Will not send any message to server.\r\n", NSStringFromClass([self class]) );
//    }
    
}

-(BOOL) checkIfUnAnsweredQuestionsPresentInTable
{
    Message *remaimingIsNewQuestion = [self.currentMessages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isNew == 1"]].firstObject;
    if (remaimingIsNewQuestion)
    {
       // NSLog(@"\r - Current isNew Question: \"%@\" ", remaimingIsNewQuestion.textBody);
        return YES;
    }
    
    return NO;
}

-(void) hideAnswersAfterInterval:(NSTimeInterval)timeInterval animated:(BOOL)shouldAnimate completion:(void(^)(void))completionBlock
{
    __weak typeof(self) weakSelf = self;
    if (shouldAnimate)
    {
        self.mesagesHidingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(hideMessagesByTimer:) userInfo:nil repeats:NO];
        
    }
    else
    {
        self.chatTable.scrollEnabled = NO;
        for(UITableViewCell *lvCell in weakSelf.chatTable.visibleCells)
        {
            [lvCell setAlpha:0.0];
        }
        [self.currentMessages removeAllObjects];
        [self.chatTable reloadData];
        self.chatTable.scrollEnabled = YES;
        if (completionBlock)
            completionBlock();
    }
}
-(void) hideMessagesByTimer:(NSTimer *)timer
{
    __weak typeof(self) weakSelf = self;
    self.chatTable.scrollEnabled = NO;
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         for(UITableViewCell *lvCell in weakSelf.chatTable.visibleCells)
         {
             [lvCell setAlpha:0.0];
         }
     }
                     completion:^(BOOL finished)
     {
         [self.currentMessages removeAllObjects];
         [weakSelf.chatTable reloadData];
         weakSelf.mesagesHidingTimer = nil;
         weakSelf.chatTable.scrollEnabled = YES;
     }];
}

#pragma mark -
-(void) loadTrendWordsAsynchronously
{
//    [[ServerRequester sharedRequester] getListOfTrendWordsWithCompletion:^(NSDictionary *successResponse, NSError *error)
//     {
//         if (error)
//         {
//#ifdef DEBUG
//             NSLog(@"\n loadTrendWordsAsynchronously ERROR: \n %@", error.localizedDescription);
//#endif
//         }
//        
//    }];
    [[ServerRequester sharedRequester] getListOfTrendWordsWithCompletion:nil];
}

#pragma mark Social Networks
//-(void) prepareInfoToShareAndPostToFacebook
//{
//    //[FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorNetworkRequests];
//    __weak typeof(self) weakKaraVC = self;
//    UIImage *lvImageToPost = [self takeScreenshotForSharing];
//    dispatch_queue_t backgroundShareQueue = dispatch_queue_create("fb_Sharer_Queue", DISPATCH_QUEUE_SERIAL);
//    
//    dispatch_async(backgroundShareQueue, ^{
//        
//    FBSDKSharePhoto *fbPhoto = [[FBSDKSharePhoto alloc] init];
//    fbPhoto.image = lvImageToPost;
//    fbPhoto.userGenerated = NO;
//    
//    //NSURL *imageURL = [NSURL URLWithString:@"https://fbstatic-a.akamaihd.net/images/devsite/attachment_blank.png"];
//    //FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:imageURL userGenerated:NO];
//    NSDictionary *properties = @{
//                                 @"og:type": @"fb_kara:question",
//                                 @"og:title": @"Ненависть?",
//                                 @"og:description": @"Злость, агрессия, обида",
//                                 @"og:url": @"http://thekaraproject.com",
//                                 @"og:image": @[fbPhoto]
//                                 };
//    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
//    
//    FBSDKShareOpenGraphAction *action = [FBSDKShareOpenGraphAction actionWithType:@"fb_kara:answer" object:object key:@"question"];
//    
//    //[action setString:@"http://samples.ogp.me/702477133207778" forKey:@"question"];
//    //[action setString:@"10204843375578222" forKey:@"question"];
//    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
//    content.action = action;
//    content.previewPropertyName = @"question";
//    FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
//    shareAPI.delegate = weakKaraVC;
//    shareAPI.shareContent = content;
//
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [shareAPI share];
//    });
//    
//   // [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
//}

//#pragma mark -  Facebook Delegates
//#pragma mark SharingDelegate
//-(void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
//{
//    //NSLog(@"\r - Results: \n%@", results.description);
//    NSNumber *idNumber = [results objectForKey:@"postId"];
//    NSLog(@"\r - Facebook PostId: %@", idNumber);
// [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//}
//-(void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
//{
//    NSLog(@"\r - Facebook Sharing Error: \n %@", error.description);
//     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//}
//-(void) sharerDidCancel:(id<FBSDKSharing>)sharer
//{
//    NSLog(@"\r - Facebook Sharing Cancelled ...\n");
//     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//}


#pragma mark -
-(void) shareToSocialNetwotkType:(SocialNetworkType)networkType attachedImage:(UIImage *)imageToShare caption:(NSString *)caption message:(NSString *)message attachedURL:(NSURL *)urlToAttach
{
    if (networkType < SocialNetworkTypeFacebook || networkType > SocialNetworkTypeTwitter)
    {
#ifdef DEBUG
        NSLog(@" \r Error while sharing: wrong social network type");
#endif
        return;
    }
    
    switch (networkType)
    {
        case SocialNetworkTypeFacebook:
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                SLComposeViewController *facebookShareController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [facebookShareController setInitialText:message];
                [facebookShareController addURL:urlToAttach];
                [facebookShareController addImage:imageToShare];
                
                [self presentViewController:facebookShareController
                                   animated:YES
                                 completion:nil];
            }
            else
            {
#ifdef DEBUG
                NSLog(@"\r Error while posting to Facebook: service not available");
#endif
            }
        }
            break;
        case SocialNetworkTypeTwitter:
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                //instantiate sharing VC
                SLComposeViewController *twitterShareController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [twitterShareController setInitialText:message];
                [twitterShareController addURL:urlToAttach];
                [twitterShareController addImage:imageToShare];
                
                //set completion handler
                __weak SLComposeViewController *weakTwitter = twitterShareController;
                twitterShareController.completionHandler = ^(SLComposeViewControllerResult result)
                {
                    switch (result)
                    {
                        case SLComposeViewControllerResultDone:
                        {
                            [weakTwitter dismissViewControllerAnimated:YES
                                                             completion:^
                            {
#ifdef DEBUG
                                NSLog(@"\r - Shared to Twitter.");
#endif
                            }];
                        }
                            break;
                        case SLComposeViewControllerResultCancelled:
                        {
                            [weakTwitter dismissViewControllerAnimated:YES
                                                             completion:^
                            {
#ifdef DEBUG
                                NSLog(@"\r - Cancelled sharing to Twitter.");
#endif
                            }];
                        }
                    }
                };
                
                //finaly, present sharing vc
                [self presentViewController:twitterShareController
                                   animated:YES
                                 completion:nil];
            }
            else
            {
#ifdef DEBUG
                NSLog(@"\r Error while posting to Twitter: service not available");
#endif
            }
        }
            break;
    }
}

#pragma mark - Modal View Controllers
-(void) showDonateVC:(id)sender
{
    if ([sender isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
    {
        if (((UIScreenEdgePanGestureRecognizer *)sender).state != UIGestureRecognizerStateBegan)
        {
            return;
        }
    }
    
    [self quitTypingIfIsTyping];
    
    DonateHolderNavVC *donateHolderNav = [self.storyboard instantiateViewControllerWithIdentifier:@"DonateHolderNAvController"];
    
    DonateScreenVC *donateVC = (DonateScreenVC *)donateHolderNav.viewControllers.firstObject;
    donateHolderNav.modalPresentationStyle = UIModalPresentationCustom;
    donateHolderNav.transitioningDelegate = self;
    
    [self presentViewController:donateHolderNav animated:YES completion:^
    {
        //to set delegate or shown info.... or else..
        donateVC.dismissDelegate = self;
    }];
}

-(void) showTrendsVC:(id)sender
{
    if ([sender isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
    {
        if (((UIScreenEdgePanGestureRecognizer *)sender).state != UIGestureRecognizerStateBegan)
        {
            return;
        }
    }
    
    [self quitTypingIfIsTyping];
    
    TrendsHolderNavController *trendsNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrendHolder"];
    trendsNavController.modalPresentationStyle = UIModalPresentationCustom;
    trendsNavController.transitioningDelegate = self;
    
    TrendWordsVC *trendsVC = (TrendWordsVC *)trendsNavController.viewControllers.firstObject;
    trendsVC.trendWords = [[[DataSource sharedInstance].echoes subarrayWithRange:NSMakeRange(0, 5) ] mutableCopy];
    [self presentViewController:trendsNavController animated:YES completion:^
    {
        //to set delegate or shown info.... or else..
        
        trendsVC.dismissDelegate = self;
    }];
}

-(void) showWordsRangingVC:(NSArray *)wordsToRange
{
    //[self quitTypingIfIsTyping];
    
    WordsRangingSwitchVC *wordsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WordsRangingSwitch"];
    wordsVC.modalPresentationStyle = UIModalPresentationCustom;
    wordsVC.transitioningDelegate = self;

    [self presentViewController:wordsVC animated:YES completion:^
    {
        //  to set two words to rate or something else.....
        wordsVC.rangingDelegate = self;
        wordsVC.wordsToRange = wordsToRange;
        [wordsVC setUpRangingViews]; //reload data :-)
    }];
}

-(void) showProfileVC:(id)sender
{
    [self quitTypingIfIsTyping];
    
    UINavigationController *profileHolder = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileNavController"];
    profileHolder.modalPresentationStyle = UIModalPresentationCustom;
    profileHolder.transitioningDelegate = self;
    
    ProfileVC *profileVC = (ProfileVC *)[profileHolder.viewControllers firstObject];
    
    [self presentViewController:profileHolder animated:YES completion:^
    {
        profileVC.dismissDelegate = self;
        profileVC.profileDelegate = self;
    }];
}

#pragma mark - Notifications
-(void) handleKeyboardAppearing:(NSNotification *)keyboardNotification
{
    NSDictionary *info = keyboardNotification.userInfo;
    
    CGRect keyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyBoardFrame.size.height;
    
    UIViewAnimationOptions animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval interval = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    BOOL show = NO;
    if ([keyboardNotification.name isEqualToString:UIKeyboardWillShowNotification])
    {
        show = YES;
        self.textHolderToBottomConstraint.constant = keyboardHeight;
    
        self.textViewHolder.hidden = NO;
    }
    else if ([keyboardNotification.name isEqualToString:UIKeyboardWillHideNotification])
    {
        self.textHolderToBottomConstraint.constant = self.defaultHolderToBottom;
        self.textViewHeightConstraint.constant = self.defaultTextViewHeight;
        self.textView.text = @"";
    }
 
    CGAffineTransform translateToTopTransform = CGAffineTransformMakeTranslation(0, -120);
    if (self.view.bounds.size.height > 667)
    {
        translateToTopTransform = CGAffineTransformMakeTranslation(0, -100);
    }
    if (self.view.bounds.size.height < 500)
    {
        translateToTopTransform = CGAffineTransformMakeTranslation(0, -150);
    }
    
    __weak typeof(self) weakSelf = self;
    
    BOOL hiddenNothingButton = (weakSelf.currentAnsweringQuestionMessage.typeId.integerValue != 8);
    [UIView animateWithDuration:interval
                          delay:0.0
                        options:animationCurve
                     animations:^
    {
        if (show)
        {
            weakSelf.textViewHolder.alpha = 1.0;
            weakSelf.chatTable.alpha = 0.0;
            weakSelf.animationsHolderView.transform = translateToTopTransform;
            weakSelf.nothingInCommonButton.hidden = hiddenNothingButton;
            weakSelf.nothingInCommonWidth.constant = (hiddenNothingButton)?0.0:40.0;
        }
        else
        {
            weakSelf.textViewHolder.alpha = 0.0;
            weakSelf.chatTable.alpha = 1.0;
            weakSelf.animationsHolderView.transform = CGAffineTransformIdentity;
            weakSelf.nothingInCommonButton.hidden = YES;
        }
        
        [weakSelf.view layoutIfNeeded];
    }
                     completion:^(BOOL finished)
    {
        if (!show)
        {
            weakSelf.textViewHolder.hidden = YES;
            weakSelf.swipeDownRecognizer.enabled = NO;
            [[weakSelf.textViewHolder viewWithTag:0xAA] removeFromSuperview];
        }
        else
        {
            weakSelf.swipeDownRecognizer.enabled = YES;
        }
    }];
}


-(void) stopAnimationsWithCompletion:(void(^)(void))completionBlock
{
    self.isAnimatingAmbience = NO;
    __weak typeof(self) weakKaraVC = self;
    [self.faceAnimationView stopAnimatingFaceImmediately:YES withCompletion:nil];

    [self.ambienceAnimationView stopPlayingCurrentAnimationWithCompletion:^(NSString *stoppedAnimationName)
    {
        
        if (completionBlock)
        {
            completionBlock();
        }
    }];
    
    [weakKaraVC startMeshRotatingAnimation:NO];
    
    [weakKaraVC startPulsingShadowAnimation:NO];

}
-(void) stopAnimationsFromWillResignActiveNotification:(NSNotification *)notification
{
    if ([self.textView isFirstResponder]) //handle device will recieve incoming call or Home button...
    {
        [self dismissKeyboardFromSwipeDown:self.swipeDownRecognizer];
    }
    else if(self.presentedViewController && [self.presentedViewController isKindOfClass:[WordsRangingSwitchVC class]])
    {
        [((WordsRangingSwitchVC *)self.presentedViewController) dismissByCancelling];
    }
    else if (self.isAnsweringDefinitionQuestion)
    {
        [self startAnsweringForDefinitionQiestion:NO animated:NO]; //dismiss keyboard and return question to pending questions
    }
    
    [[DataSource sharedInstance] stopPlaying];
    
    self.ambienceAnimationView.animationFinishDelegate = nil;
    [self stopAnimationsWithCompletion:nil];
    
    self.faceAnimationView.faceAnimation = nil;
    
    if (self.mesagesHidingTimer.isValid)
    {
        [self.mesagesHidingTimer invalidate];
    }
    if (self.currentMessages)
    {
        [self.currentMessages removeAllObjects];
    }
  
    [[DataSource sharedInstance].messages removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(self.currentAninationIndex) forKey:Last_Active_Animation];
}


-(void)resumeAnimations
{
    if (self.presentedViewController != nil)
    {
#ifdef DEBUG
        NSLog(@"\r - %@ is not top View controller, so no animation will be started.", NSStringFromClass([self class]));
        NSLog(@"\r current presented VC is : %@", NSStringFromClass([self.presentedViewController class]));
#endif
        return;
    }
    __weak typeof(self) weakKaraVC = self;
    
    //animating emotion
    NSString *animationName = [self.animationNames objectAtIndex:self.currentAninationIndex];
    [weakKaraVC.ambienceAnimationView playAnimationNamed:animationName forMinutes:5];
    self.isAnimatingAmbience = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.currentAninationIndex) forKey:Last_Active_Animation];
    
    //animating face nodding up and down
    if (!weakKaraVC.faceAnimationView.faceAnimation)
    {
        BOOL newAnimationSet = [weakKaraVC.faceAnimationView setNewFaceAnimationFromName:@"face"];
        
        if (newAnimationSet)
        {
            [weakKaraVC.faceAnimationView startAnimatingFaceWithInterval:5.0];
        }
    }
    else
    {
        weakKaraVC.faceAnimationView.shouldAnimateFace = YES;
        [weakKaraVC.faceAnimationView startAnimatingFaceWithInterval:5.0];
    }
    
    
    //animating rotating background
    [self startMeshRotatingAnimation:YES];
    
    [self playAmbienceIfSoundsEnabled];
    
    //animation for bottom button
    [self startPulsingShadowAnimation:YES];
 
}

-(void)resumeAnimationsFromDidBecomeActiveNotification:(NSNotification *)notification
{
    self.ambienceAnimationView.animationFinishDelegate = self;
    [self resumeAnimations];
}

-(void) changeCurrentAnimationIndexAndUpdateUI_ifVisible:(NSNotification *)changeAnimationNote
{
    EmotionsTimer *lvEmotionChangeTimer = [[EmotionsTimer alloc] init];
    NSInteger shouldPayVideo = arc4random_uniform(4);
    __weak typeof(self) weakKaraVC = self;
    
    NSInteger newValue = ((NSNumber *)[[changeAnimationNote userInfo] objectForKey:@"newMood"]).integerValue + 4;
    if (changeAnimationNote.object != [ServerRequester sharedRequester])
    {
        newValue -= 4;
    }
    if (newValue != self.currentAninationIndex && (newValue < 9 && newValue >= 0))
    {
        self.currentAninationIndex = newValue;
        if (!self.presentedViewController)
        {
            self.ambienceAnimationView.animationFinishDelegate = nil;
            [self stopAnimationsWithCompletion:^
            {
                weakKaraVC.ambienceAnimationView.animationFinishDelegate = weakKaraVC;
                
                if (shouldPayVideo == 2)
                    [weakKaraVC playVideoRandomly];
                else
                    [weakKaraVC resumeAnimations];
            }];
        }
        
        NSTimeInterval nextPostponeTime = 5;
        //postpone next emotion change
        
        if (self.currentAninationIndex < (self.animationNames.count - 1)) //postpone next emotion change only if we are displaying not top emotion
        {
            
            //return to "Ambient" state
            //or switch to next "positive" in 5 minutes of active app
            
            
            if (self.currentAninationIndex > 5)
            {
                nextPostponeTime = 10; //switch to next higher positive emotons in 10 minutes. if current emotion is higher, than usual ambience
            }
        
            [lvEmotionChangeTimer postponeNextEmotionChangeInMinutes:nextPostponeTime currentEmotionIndex:self.currentAninationIndex];
            //NSLog(@"KaraVC Postponing next emotion change in %f minutes", nextPostponeTime );
        }
        else
        {
            [lvEmotionChangeTimer postponeNextEmotionChangeInMinutes:nextPostponeTime currentEmotionIndex:self.currentAninationIndex];
        }
    }
    
    if (self.currentAninationIndex == 8)
    {
        if (!self.presentedViewController)
        {
            if (shouldPayVideo == 2)
            {
                [self stopAnimationsWithCompletion:^
                {
                    [weakKaraVC playVideoRandomly];
                }];
            }
            else
            {
                [lvEmotionChangeTimer postponeNextEmotionChangeInMinutes:10 currentEmotionIndex:self.currentAninationIndex];
            }
        }
        else
        {
            [lvEmotionChangeTimer postponeNextEmotionChangeInMinutes:10 currentEmotionIndex:self.currentAninationIndex];
        }
    }
}

-(void) playVideoRandomly
{
    //NSLog(@"\r                     -__ -__-\r  Starting RANDOM video...\r");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __block AVPlayerItem *playerItem;
    dispatch_group_t group =  dispatch_group_create();
    dispatch_group_enter(group);
    
    //get random video from server
    [[ServerRequester sharedRequester]  getRandomVideoWithCompletion:^(NSDictionary *successResponse, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if (successResponse)
         {
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 /*Important  
                  URLWithString: is not proper method for file system
                  //From Apple`s Docs:
                  //To create NSURL objects for file system paths, use fileURLWithPath:isDirectory: instead.
                  */
                 NSString *videoURL = [successResponse objectForKey:@"url"];
                 NSURL *lvURL = [NSURL fileURLWithPath:videoURL isDirectory:NO];
                 AVAsset *videoAsset = [AVAsset assetWithURL:lvURL];
                 playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
             });
             
         }
         dispatch_group_leave(group);
    }];
    
    __weak typeof(self) weakSelf = self;
    
    //after network query completes or reaches timeout we proceed
    dispatch_group_notify(group, dispatch_get_main_queue(), ^
    {
        if (!playerItem)
        {
            //test video animation
            NSArray *videoNames = @[@"ambience", @"joy"];
            NSString *videoName = [NSString stringWithFormat:@"%@", [videoNames objectAtIndex:arc4random_uniform((uint32_t)videoNames.count)] ];
            //NSLog(@"\n  --  Starting playing TEST Video: \"%@\"", videoName);
            NSURL *lvURL = [[NSBundle mainBundle] URLForResource:videoName withExtension:@"mov"];
            playerItem = [[AVPlayerItem alloc] initWithURL:lvURL];
        }
        self.ambienceAnimationView.animationFinishDelegate = nil;
        [self.ambienceAnimationView stopPlayingCurrentAnimationWithCompletion:^(NSString *stoppedAnimationName)
         {
            [weakSelf.ambienceAnimationView playVideoItem:playerItem forMinutes:1 atRate:1.0];
             weakSelf.ambienceAnimationView.animationFinishDelegate = weakSelf;
        }];
        
        [self startMeshRotatingAnimation:YES];
        
        [self startPulsingShadowAnimation:YES];
    });
}

-(void) startPulsingShadowAnimation:(BOOL) start
{
    if (start)
    {
        if (self.startChatButton.layer.animationKeys.count > 0)
        {
            return;
        }
        
        CABasicAnimation *shadowPulsingAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        shadowPulsingAnimation.repeatCount = HUGE_VALF;
        shadowPulsingAnimation.autoreverses = YES;
        shadowPulsingAnimation.duration = 4.0;
        shadowPulsingAnimation.fromValue = @(0.0);
        shadowPulsingAnimation.toValue = @(15.0);
        shadowPulsingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.startChatButton.layer addAnimation:shadowPulsingAnimation forKey:@"pulsingShadow"];
        //self.startChatButton.userInteractionEnabled = YES;
    }
    else
    {
        [self.startChatButton.layer removeAllAnimations];
        //self.startChatButton.userInteractionEnabled = NO;
    }
}

-(void) startMeshRotatingAnimation:(BOOL) start
{
    if (start)
    {
        AnimationsCreator *animationCreator = [[AnimationsCreator alloc] init];
        CAAnimation *smoothRotationAnimation = [animationCreator animationForMesh];
        [self.meshImageView.layer addAnimation:smoothRotationAnimation forKey:@"rotationAnimation"];
    }
    else
        [self.meshImageView.layer removeAllAnimations];
}

-(void) handleFreshMesagesNotification:(NSNotification *)notification
{
    [self startPulsingShadowAnimation:YES];
}

#pragma mark Audio
-(void) playAmbienceIfSoundsEnabled
{
    //this typically happens once per app install - default is to playsound
    NSNumber *checkIfSoundsBoolPresentInDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:SOUNDS_ENABLED];
    if (!checkIfSoundsBoolPresentInDefaults)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SOUNDS_ENABLED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    BOOL soundsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SOUNDS_ENABLED];
    //play
    if (soundsEnabled)
    {
        if (![[DataSource sharedInstance].ambiencePlayer isPlaying])
        {
            [[DataSource sharedInstance] playAmbienceSound];
        }
    }
    [self setSoundsButtonImageForEnabledSounds:soundsEnabled];
}

-(void)enableSounds:(id)sender
{
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:SOUNDS_ENABLED];
    if (enabled)
    {
        //disableSounds and stop playing
        [[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:SOUNDS_ENABLED];
        [[DataSource sharedInstance] fadeOutAmbienceSoundWithCompletion:^
        {
            [[DataSource sharedInstance] stopPlaying];
        }];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:SOUNDS_ENABLED];
        [self playAmbienceIfSoundsEnabled];
    }
    
    //set needed image for button
    enabled = [[NSUserDefaults standardUserDefaults] boolForKey:SOUNDS_ENABLED];
    [self setSoundsButtonImageForEnabledSounds:enabled];
}

-(void) setSoundsButtonImageForEnabledSounds:(BOOL)enabled
{
    [self.soundsButton setImage:[UIImage imageNamed:(enabled)?@"button-sound-on":@"button-sound-off"] forState:UIControlStateNormal];
}

#pragma mark - KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    __weak typeof(self)weakKaraVC = self;

    if ([keyPath isEqualToString:@"messages"])
    {
        
#ifdef DEBUG
        NSLog(@"\r -(%@)-- Handling new messages . . .", NSStringFromClass([self class]));
#endif
        
        if (![[change objectForKey:@"new"] isKindOfClass:[NSArray class]])
        {
            @try
            {
                [[DataSource sharedInstance] removeObserver:weakKaraVC forKeyPath:@"messages"];
#ifdef DEBUG
                NSLog(@" \r %@ unsubscribed from \"messages\" keyPath", NSStringFromClass([self class]));
#endif
                weakKaraVC.needsToUnsubscribe = NO;
            }
            @catch(NSException *exception)
            {
#ifdef DEBUG
                NSLog(@" (%@) Caught an Exception while tryied to unregister self from \"messages\" keyPath: \n%@", NSStringFromClass([self class]), exception.description);
#endif
            }
            return ;
        }
        
        NSArray *lvMessages = [change objectForKey:@"new" ];

        [weakKaraVC.currentMessages addObjectsFromArray:lvMessages];//excludedMessages];
#ifdef DEBUG
        NSLog(@"\r - - Inserted %ld messages to Table", (long)lvMessages.count);//excludedMessages.count);
#endif
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             NSInteger messagesCount  = weakKaraVC.currentMessages.count;
             if (messagesCount > 0)
             {
                 weakKaraVC.chatTable.delegate = weakKaraVC;
                 weakKaraVC.chatTable.dataSource = weakKaraVC;
                 [weakKaraVC.chatTable reloadData];
                
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                 {
                    //hide answer and question after 1 minute(60 seconds)
                    [weakKaraVC hideAnswersAfterInterval:60 animated:YES completion:nil];
                 });
             }
        }];
    }
}

#pragma mark - Attributed Text Display Tools
-(UIView *)makeQuestionDisplayLabelWithAttributedString:(NSAttributedString *)attributedString
{
    UIView *labelHolder = [[UIView alloc] initWithFrame:CGRectOffset(self.textViewHolder.bounds, 0.0, -self.textViewHolder.bounds.size.height)];
    labelHolder.backgroundColor = [UIColor clearColor];
    labelHolder.tag = 0xAA;
    
    UILabel *lvMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, labelHolder.bounds.size.width - 10, labelHolder.bounds.size.height - 10)];
    lvMessageLabel.numberOfLines = 0;
    lvMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    lvMessageLabel.textAlignment = NSTextAlignmentLeft;
    lvMessageLabel.font = [UIFont systemFontOfSize:13];
    lvMessageLabel.textColor = [UIColor darkGrayColor];
    lvMessageLabel.attributedText = attributedString;
    lvMessageLabel.backgroundColor = [UIColor clearColor];
    
    [labelHolder addSubview:lvMessageLabel];
    
    
    [lvMessageLabel sizeToFit];
    
    if (lvMessageLabel.bounds.size.height > labelHolder.bounds.size.height)
    {
        CGRect labelFrame = lvMessageLabel.bounds;
        
        labelFrame.size.height *= 1.2;
        labelFrame.size.width = labelHolder.bounds.size.width;
        labelFrame.origin.y = self.textViewHolder.bounds.origin.y - labelFrame.size.height;
        labelHolder.frame = labelFrame;
        
    }
    lvMessageLabel.center = CGPointMake(CGRectGetMidX(labelHolder.bounds), CGRectGetMidY(labelHolder.bounds));
    
    return labelHolder;
}

-(NSAttributedString *)makeAttributedStringFromString:(NSString *)toProcess
{
    NSString *lastQuestion =[ NSString stringWithFormat:@"%@", self.currentAnsweringQuestionMessage.textBody];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:lastQuestion];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:[UIFont fontWithName:@"Segoe UI" size:20]};
    
    [attributed addAttributes:attributes
                        range:NSMakeRange(0, lastQuestion.length)];
    
    return attributed;
}


#pragma mark - Errors Alert view
-(void) showAlertWithTitle:(NSString *)title message:(NSString *) message closeButtonTitle:(NSString *)closeTitle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:NO completion:nil];
    }];
    [alertController addAction:closeAction];
    __weak typeof(self) weakSelf = self;
    [weakSelf presentViewController:alertController animated:YES completion:nil];
}
@end
