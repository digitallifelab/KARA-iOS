//
//  DonateScreenVC.m
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "DonateScreenVC.h"


#import "DonateScreenCollectionCell.h"


#import "AboutUsTextCell.h"
#import "AboutUsDonateItemsCell.h"
#import "IntroVC.h"

@interface DonateScreenVC ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> //UICollectionViewDelegate, UICollectionViewDataSource, 

@property (nonatomic, strong)  UIScreenEdgePanGestureRecognizer *dismissRecognizer;

@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, strong) NSAttributedString *aboutUsString;
@end

@implementation DonateScreenVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTransparentNavigationBar];
    //self.title = NSLocalizedString(@"AboutUsTitle", nil);
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    [titleLabel setTextColor:[UIColor whiteColor]];
//    [titleLabel setFont:[UIFont fontWithName:@"Segoe UI" size:25]];
//    [titleLabel setText:self.title];
//    self.navigationItem.titleView = titleLabel;
    
    //right bar button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    [rightButton setImage:[UIImage imageNamed:@"button-arrow-right"] forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
    [rightButton addTarget:self action:@selector(dismissByRightBarButton) forControlEvents:UIControlEventTouchUpInside];
    rightButton.tintColor = [UIColor colorWithRed:90.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:0.8];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.dismissRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissByPan:)];
    self.dismissRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.dismissRecognizer];

//    self.payedItemsCollection.delegate = self;
//    self.payedItemsCollection.dataSource = self;
    
    [self configureAttributedText];
    
    self.table.estimatedRowHeight = 200;
    self.table.rowHeight = UITableViewAutomaticDimension;
    self.table.dataSource = self;
    self.table.delegate = self;
    
    [self setupNavigationBarButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPurchaseAlert:) name:completeTransactionNotification object:nil];
//}
//
//-(void) viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:completeTransactionNotification object:nil];
//}
#pragma mark -
- (void) setupTransparentNavigationBar
{
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init]; //remove thin line under navigation bar
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void) setupNavigationBarButtons
{
    
    UIColor *buttonsTintColor = [UIColor colorWithRed:90.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:0.8];
    
    //right back button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    rightButton.tintColor = buttonsTintColor;
    [rightButton setImage:[UIImage imageNamed:@"button-arrow-right"] forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
    [rightButton addTarget:self action:@selector(dismissByRightBarButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    //left info button
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setFrame:CGRectMake(0, 0, 40, 40)];
    [infoButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    infoButton.tintColor = buttonsTintColor;
    [infoButton setImage:[UIImage imageNamed:@"button-info"] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(presentHowToGuide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftInfoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.leftBarButtonItem = leftInfoButton;
}
#pragma mark -
-(void) dismissByRightBarButton
{
    [self.dismissDelegate viewControllerWantsToDismiss:self];
}

-(void) dismissByPan:(UIScreenEdgePanGestureRecognizer *)sender
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

-(void) configureAttributedText
{
    
    NSString *linkText = NSLocalizedString(@"AboutUsLink", nil);
    NSString *aboutUs = NSLocalizedString(@"AboutUs", nil);
    NSString *supportUsText = NSLocalizedString(@"AboutUsFinish1", nil);
    NSString *thanksText = NSLocalizedString(@"AboutUsFinish2", nil);
    
    NSMutableAttributedString *toReturn = [[NSMutableAttributedString alloc] init];

    //link
    
    NSRange linkRange = NSMakeRange(0, linkText.length);
    NSMutableAttributedString *mutableLink = [[NSMutableAttributedString alloc] initWithString:linkText];
    
    [mutableLink addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Segoe UI" size:15] range:linkRange];
    NSMutableParagraphStyle *linkParagraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [linkParagraphStyle setAlignment:NSTextAlignmentCenter];
    //[linkParagraphStyle setParagraphSpacingBefore:10.0];
    [linkParagraphStyle setLineSpacing:10.0];
    [mutableLink addAttribute:NSParagraphStyleAttributeName value:linkParagraphStyle range:linkRange];
    [mutableLink addAttribute:NSLinkAttributeName value:linkText range:linkRange];
    [mutableLink addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:linkRange];
    
    
    
    //about us
    NSRange preRange = NSMakeRange(0, aboutUs.length);
    NSMutableAttributedString *mutablePre = [[NSMutableAttributedString alloc] initWithString:aboutUs];
    [mutablePre addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:preRange];
    [mutablePre addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Segoe UI" size:15] range:preRange];
    NSMutableParagraphStyle *preParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[preParagraphStyle setFirstLineHeadIndent:15.0];
    //[preParagraphStyle setParagraphSpacingBefore:5.0];
    [preParagraphStyle setParagraphSpacing:10.0];
    [preParagraphStyle setLineSpacing:2.0];
    [mutablePre addAttribute:NSParagraphStyleAttributeName value:preParagraphStyle range:preRange];
    

    
    //supportUs
    NSRange postRange = NSMakeRange(0, supportUsText.length);
    NSMutableAttributedString *mutablePost = [[NSMutableAttributedString alloc] initWithString:supportUsText];
    [mutablePost addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:postRange];
    [mutablePost addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Segoe UI" size:14] range:postRange];
    NSMutableParagraphStyle *postParagraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    //[postParagraphStyle setFirstLineHeadIndent:15.0];
    [postParagraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [postParagraphStyle setParagraphSpacingBefore:15.0];
    [mutablePost addAttribute:NSParagraphStyleAttributeName value:postParagraphStyle range:postRange];
    
   
    
    //thanks centered
    NSRange thanksRange = NSMakeRange(0, thanksText.length);
    NSMutableAttributedString *mutableThanks = [[NSMutableAttributedString alloc] initWithString:thanksText];
    NSMutableParagraphStyle *thanksParagraph = [[NSMutableParagraphStyle alloc] init];
    [thanksParagraph setAlignment:NSTextAlignmentCenter];
    [thanksParagraph setLineBreakMode:NSLineBreakByWordWrapping];
    [thanksParagraph setParagraphSpacingBefore:10.0];
    [mutableThanks addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:thanksRange];
    [mutableThanks addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Segoe UI" size:14] range:thanksRange];
    [mutableThanks addAttribute:NSParagraphStyleAttributeName value:thanksParagraph range:thanksRange];
    
    [toReturn appendAttributedString:mutableLink];
    
    [toReturn appendAttributedString:mutablePre];
  
    [toReturn appendAttributedString:mutablePost];
    
    [toReturn appendAttributedString:mutableThanks];
    
    self.aboutUsString = toReturn;
}


#pragma mark - UITextViewDelegate
-(BOOL) textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([URL.absoluteString isEqualToString:@"ru.thekaraproject.com"])
    {
        URL = [NSURL URLWithString:@"http://ru.thekaraproject.com"];
    }
    [[UIApplication sharedApplication] openURL:URL];
    
    return NO;
}

//#pragma mark - UICollectionViewDataSource
//-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 6;
//}
//
//-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    DonateScreenCollectionCell *collectionCell = (DonateScreenCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DonateCell" forIndexPath:indexPath];
//    collectionCell.layer.borderColor = [UIColor whiteColor].CGColor;
//    collectionCell.layer.borderWidth = 1.0;
//    collectionCell.imageView.image = [UIImage imageNamed:@"button-keyboard"];
//    
//    return collectionCell;
//}
//#pragma mark - UICollectionViewDelegate

//-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    PurchasesManager *pManager = [PurchasesManager defaultManager];
//    [pManager purchaseItemWithId:@"KARA.TestDonation0"];
//}

//#pragma mark - Purchase Notification

//-(void)showPurchaseAlert:(NSNotification *)notification
//{
//    NSDictionary *info = notification.userInfo;
//    if (((NSNumber *)[info objectForKey:@"status"]).boolValue)
//    {
//        [self showAlertWithTitle:@"Success" message:@"test purchase seems to be successfull" closeButtonTitle:@"Close"];
//    }
//    else
//    {
//        [self showAlertWithTitle:@"Failure" message:@"test purchase seems to be unsuccessfull" closeButtonTitle:@"Close"];
//    }
//}


#pragma mark - UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            AboutUsTextCell *textCell = (AboutUsTextCell *)[tableView dequeueReusableCellWithIdentifier:@"DonateTextCell" forIndexPath:indexPath];
            
            [textCell.textView setAttributedText:self.aboutUsString];
            [textCell.textView sizeToFit];
            textCell.textView.delegate = self;
            return textCell;
        }
            break;
//        case 1:
//        {
//            AboutUsDonateItemsCell *donateCell = (AboutUsDonateItemsCell *)[tableView dequeueReusableCellWithIdentifier:@"DonateItemsCell" forIndexPath:indexPath];
//            return donateCell;
//        }
//            break;
        default:
            return nil;
            break;
    }
}

#pragma mark - Errors Alert view
-(void) showAlertWithTitle:(NSString *)title message:(NSString *) message closeButtonTitle:(NSString *)closeTitle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeTitle style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:closeAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - the HOW-TO screens
-(void) presentHowToGuide
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

@end
