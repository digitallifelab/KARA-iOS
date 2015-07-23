//
//  RootViewController.m
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "RootViewController.h"
#import "Constants.h"
#import "ServerRequester.h"
#import "AmbienceAnimationView.h"
#import "AnimationsCreator.h"
#import "LoginVC.h"
#import "ChangePasswordVC.h"
#import "RegisterVC.h"

#import "KaraVC.h"
#import "FileHandler.h"
#import "NSData+PhotoConverter.h"

@interface RootViewController ()<LoginScreenDelegate, ChangePasswordDelegate, AnimationCompletionDelegate>

@property (nonatomic, assign) BOOL didLoadContacts;
@property (nonatomic, assign) BOOL didLoadMessages;
@property (nonatomic, strong) NSString *tempPassword;
@property (nonatomic, strong) NSString *tempEmail;


@property (nonatomic, assign) BOOL isLoggingIn;
@property (nonatomic, assign) BOOL isLoadingMessagesAndKaraContact;
@property (nonatomic, assign) BOOL noInternet;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet AmbienceAnimationView *animationView;

@property (nonatomic, assign) BOOL didAppear;
@property (nonatomic, assign) BOOL shouldShowAnimation;
@property (nonatomic, assign) BOOL didPlayPreloaderAnimation;

@end

@implementation RootViewController

- (void)viewDidLoad
{
//    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSString *lang = [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:langID];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Transparent top nav bar
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init]; //remove thin line under navigation bar
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //
    NSDictionary *savedUserDict = [[[FileHandler alloc] init] getSavedUser];
    if (savedUserDict)
    {
        User *lastSavedUser = [User userFromJSON:savedUserDict];
        [ServerRequester sharedRequester].currentUser = lastSavedUser;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.animationView.isCurrentlyAnimating && !self.isLoggingIn && !self.didAppear && !self.didPlayPreloaderAnimation)
    {
        self.shouldShowAnimation = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.shouldShowAnimation)
    {
        self.didAppear = YES;
        [self startPreloaderAnimation];
        self.shouldShowAnimation = NO;
        
        [self addObserver:self forKeyPath:@"didPlayPreloaderAnimation" options:NSKeyValueObservingOptionNew context:nil];
    }
    else
    {
        [self proceedAuthenticatingWorkflow];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 
-(void) proceedAuthenticatingWorkflow
{
    User *lvCurrentUser = [ServerRequester sharedRequester].currentUser;
    __weak typeof(self) weakSelf = self;
    if (lvCurrentUser) // viewDidAppera after login screen or something else disappeared
    {
        ////  Did appear after login screen disappeared
        if (lvCurrentUser.state.integerValue == 1)
        {
            [self showChangePasswordVC];
        }
        else
        {
            if ([DataSource sharedInstance].messages.count > 0 || self.didLoadMessages)
            {
                [weakSelf showKaraScreen];
                
                // by the way, save current user to disk.
                dispatch_queue_t bgQueue = dispatch_queue_create("user_saver_queue", DISPATCH_QUEUE_SERIAL);
                dispatch_async(bgQueue, ^{
                    [[[FileHandler alloc] init] saveCurrentUserToDisk:[[ServerRequester sharedRequester].currentUser toDictionary]];
                });
                
            }
            else
            {
                if (!self.isLoadingMessagesAndKaraContact)
                {
                    
                    [self loadKaraContactAndMessagesCompletion:^
                     {
                         weakSelf.isLoadingMessagesAndKaraContact = NO;
                         [weakSelf proceedAuthenticatingWorkflow];
                     }];
                }
            }
        }
        return;
    }
    
    
    ////  Did appear NOT after login screen disappeared
    
    NSString *currentAuthType = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_AUTH_TYPE];
    NSString *userPass = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_PASSWORD];
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_NAME];
    
    if (self.tempPassword && self.tempEmail)
    {
        userEmail = self.tempEmail;
        userPass = self.tempPassword;
        currentAuthType = AUTH_TYPE_EMAIL;
    }
    
    if (!currentAuthType || (currentAuthType && !(userEmail && userPass)) || self.noInternet)
    {
        if (!self.isLoggingIn)
        {
            [self showLoginScreen];
        }
    }
    else
    {
        if (self.isLoggingIn)
        {
            //[self showPreloaderScreen];
            
            //play animation
            if (!self.didPlayPreloaderAnimation)
            {
               [self startPreloaderAnimation];
            }
        }
        else if ([currentAuthType isEqualToString:AUTH_TYPE_EMAIL])
        {
            if (userPass && userEmail) ///automatic login
            {
                //login with existing email
                self.isLoggingIn = YES;
                [self loginWithParams:@{loginNameStringKey:userEmail, loginPasswordStringKey:userPass} completionUser:^(User *loggeUser)
                 {
                     weakSelf.isLoggingIn = NO;
                     if (loggeUser)
                     {
                         if (loggeUser.state.integerValue == 1)
                         {
                             [weakSelf proceedAuthenticatingWorkflow];
                         }
                         else
                         {
                             [weakSelf loadKaraContactAndMessagesCompletion:^
                             {
                                 [weakSelf proceedAuthenticatingWorkflow];
                             }];
                         }
                     }
                     else
                     {
                         [weakSelf proceedAuthenticatingWorkflow];
                     }
                 }];
            }
        }
        else if ([currentAuthType isEqualToString:AUTH_TYPE_FACEBOOK])
        {
            
        }
        else if ([currentAuthType isEqualToString:AUTH_TYPE_TWITTER])
        {
            
        }
    }

}


-(void)loginWithParams:(NSDictionary *)loginParams completionUser:(void(^)(User *loggeUser))completionBlock
{
    
    NSString *lvLoginName = [loginParams objectForKey:loginNameStringKey];
    NSString *lvLoginPassword = [loginParams objectForKey:loginPasswordStringKey];
    
    self.tempPassword = nil;
    self.tempEmail = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self) weakRootViewController = self;
    [[ServerRequester sharedRequester] loginRequestWithParams:@{@"username":lvLoginName, @"password":lvLoginPassword}
                                                   completion:^(NSDictionary *successResponse, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
         
         if (successResponse)
         {
             //NSLog(@"\n-SuccessResponse:\n%@", successResponse);
             if ([successResponse objectForKey:@"LoginResult"] != nil)
             {
                 NSDictionary *userDictObject = [successResponse objectForKey:@"LoginResult"];
                 if ([userDictObject objectForKey:@"LoginName"] != nil) //success response
                 {
                     User *currentUser = [[User alloc] initWithParameters:userDictObject];
                  
                     [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                     {
                         //UIImage *lvAvatar = [UIImage imageWithData: currentUser.photo];
                         FileHandler *filer = [[FileHandler alloc] init];
                         
                         NSData *lvDiskAvatar = [filer imageDataForUserAvatarWithUserName:currentUser.loginName];
                         if (lvDiskAvatar)
                         {
                             [ServerRequester sharedRequester].currentUser.photo = lvDiskAvatar;
                         }
                         else
                         {
                             // when KaraVC will be presented, user image downloading also will start
                         }
                     }];
                     
                     
                     [ServerRequester sharedRequester].currentUser = currentUser;
                     
                     [[NSUserDefaults standardUserDefaults] setObject:currentUser.password forKey:CURRENT_USER_PASSWORD];
                     [[NSUserDefaults standardUserDefaults] setObject:currentUser.loginName forKey:CURRENT_USER_NAME];
                     [[NSUserDefaults standardUserDefaults] setObject:AUTH_TYPE_EMAIL forKey:CURRENT_USER_AUTH_TYPE];
                     [[NSUserDefaults standardUserDefaults] setObject:currentUser.token forKey:CURRENT_USER_TOKEN];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                    
                     if (completionBlock)
                     {
                         completionBlock([ServerRequester sharedRequester].currentUser);
                     }
                 }
                 else
                 {
                     //something went wrong
                     //show alert
                     //NSLog(@"Error in login:\n %@", successResponse.description);
                     if (completionBlock)
                     {
                         completionBlock(nil);
                     }
                 }
             }
         }
         else if (error)
         {
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:CURRENT_USER_PASSWORD];
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:CURRENT_USER_AUTH_TYPE];
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:CURRENT_USER_NAME];
             
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             if (completionBlock)
             {
                 NSString *title = @"Login problem";
                 NSString *reason;
                 if (error.code == -1004)
                 {
                     reason = error.localizedDescription;
                 }
                 else if (error.code == 701)
                 {
                     reason = error.localizedDescription;
                 }
                 else if(error.code == - 1001)
                 {
                     NSString *errorString = error.localizedDescription;
                     reason = [NSString stringWithFormat:@"%@ %@", errorString, NSLocalizedString(@"CheckYourConnection", nil)];
                 }
                 else
                     reason = @"Try again, please. Check password and email.";
                 
                 if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
                 {
                     [[[UIAlertView alloc] initWithTitle:title message:reason delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles: nil] show];
                 }
                 else
                 {
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:reason preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)  style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                     {
                         [weakRootViewController proceedAuthenticatingWorkflow];
                     }];
                     
                     [alertController addAction:closeAction];
                     if (!weakRootViewController.presentedViewController)
                     {
                         [weakRootViewController  presentViewController:alertController
                                                               animated:YES
                                                             completion:^
                         {
                             completionBlock(nil);
                         }];
                     }
                     else if ([weakRootViewController.presentedViewController isKindOfClass:[LoginVC class]])
                     {
                         [weakRootViewController.presentedViewController  presentViewController:alertController
                                                                                       animated:YES
                                                                                     completion:nil];
                     }
                     
                 }
                
             }
         }
     } progressView:nil];//self.progressView];
}

#pragma mark - 
-(void) showLoginScreen
{
    self.tempPassword = nil;
    self.tempEmail = nil;
    
    __weak typeof(self) weakRootVC = self;
    
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginVC *loginScreen = [loginStoryBoard instantiateViewControllerWithIdentifier:@"LoginVC"];
    
    if (self.presentedViewController)
    {
        //we need to wain until user taps on Close button in alert view
    }
    else
    {
        [self presentViewController:loginScreen
                           animated:YES
                         completion:^
         {
             loginScreen.loginDelegate = weakRootVC;
         }];
    }
    
   
}

-(void) showKaraScreen
{
    __weak typeof(self) weakSelf = self;
    KaraVC *lvKaraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"KaraVC"];
    if (self.presentedViewController != nil)
    {
        
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^
         {
             //[weakSelf performSegueWithIdentifier:@"PushKaraScreen" sender:self];
             [weakSelf.progressView setProgress:0.0];
             [weakSelf.navigationController pushViewController:lvKaraVC animated:YES];
         }];
    }
    else
    {
//        [self performSegueWithIdentifier:@"PushKaraScreen" sender:self];
        [self.progressView setProgress:0.0];
        [self.navigationController pushViewController:lvKaraVC animated:YES];
        
        //clean a little bit
        self.tempEmail = nil;
        self.tempPassword = nil;
        self.didLoadContacts = NO;
        self.didLoadMessages = NO;
        [self.progressView setProgress:0.0 animated:NO];
    }
    
    //load user`s avatar
    if ([ServerRequester sharedRequester].currentUser.photo == nil)
    {
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [[ServerRequester sharedRequester] searchForContactByEmail:[ServerRequester sharedRequester].currentUser.loginName completion:^(NSDictionary *successResponse, NSError *error)
             {
                 //this happens in background queue
                 if (error)
                 {
                     //NSLog(@"\n - Could not get user photo: %@", error.localizedDescription);
                 }
                 else
                 {
                     if (successResponse.allKeys.count > 0)
                     {
                         if ([successResponse objectForKey:@"Photo"] != [NSNull null])
                         {
                             NSData *photoData = [NSData dataFromIntegersArray: [successResponse objectForKey:@"Photo"]];
                             [ServerRequester sharedRequester].currentUser.photo = photoData;
                             //NSLog(@"\n - Loaded user`s photo...");
                             FileHandler *lvFiler = [[FileHandler alloc] init];
                             [lvFiler saveAvatar:photoData forName:[ServerRequester sharedRequester].currentUser.loginName];
                         }
                     }
//                     else
//                     {
//                         NSLog(@"\n - Could not get user photo: Recieved empty dictionary");
//                     }
                 }
                 
             }];
        }];//end of operationQueue
    }
}

-(void) showChangePasswordVC
{
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    ChangePasswordVC *lvChangePasswordVC = [loginStoryBoard instantiateViewControllerWithIdentifier:@"ChangePassVC"];
    
    __weak typeof(self)weakSelf = self;
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[LoginVC class]])
    {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:^
        {
            [weakSelf presentViewController:lvChangePasswordVC animated:YES completion:^
            {
                lvChangePasswordVC.changePasswordDelegate = weakSelf;
            }];
        }];
    }
    else
    {
        [self presentViewController:lvChangePasswordVC
                           animated:YES
                         completion:^
         {
             lvChangePasswordVC.changePasswordDelegate = weakSelf;
         }];
    }
    
}


-(void) loadKaraContactAndMessagesCompletion:(void(^)(void))completion
{
    __weak typeof(self)weakSelf = self;
    self.isLoadingMessagesAndKaraContact = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_group_t backgroundLoaderGroup = dispatch_group_create();
   
    dispatch_group_enter(backgroundLoaderGroup);
    [[ServerRequester sharedRequester] loadContactsWithCompletion:^(NSDictionary *successResponse, NSError *error)
     {
         if (!successResponse)
         {
//             NSLog(@"\r - Dismissing loading contacts, probably, wrong saved token.");
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             [ServerRequester sharedRequester].currentUser = nil;
             dispatch_group_leave(backgroundLoaderGroup);
             return ;
         }
         
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            weakSelf.didLoadContacts = YES;
                        });
         //NSLog(@" \r - Loaded Contact Kara");
         
         [[ServerRequester sharedRequester] loadAllMessagesWithCompletion:^(NSDictionary *successResponse, NSError *error)
         {
             [[ServerRequester sharedRequester] loadPendingMessageIDsWithCompletion:^(NSDictionary *successResponse, NSError *error) {
                
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    weakSelf.didLoadMessages = YES;
                                    weakSelf.isLoadingMessagesAndKaraContact = NO;
                                });
                 
                 //NSLog(@" \n - loaded All Messages");
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 dispatch_group_leave(backgroundLoaderGroup);
             }];
             
          } progressView:nil];//weakSelf.progressView];
    
     } progressView:nil];//self.progressView];
    
    
    
    dispatch_group_notify(backgroundLoaderGroup, dispatch_get_main_queue(), ^
                          {
                              //NSLog(@" \r - Notified end of dispatch group. \r");
                              
                              if (weakSelf.presentedViewController && [weakSelf.presentedViewController isKindOfClass:[LoginVC class]])
                              {
                                  //LoginVC *lvLoginVC = (LoginVC *)weakSelf.presentedViewController;
//                                  NSLog(@"\r - Dismissing |- Login -| screen after login...");
                                  [weakSelf dismissViewControllerAnimated:YES completion:completion];
                              }
                              else
                              {
                                  if (completion)
                                  {
                                      completion();
                                  }
                              }
                          });
}

#pragma mark - Delegate methods
-(void) loginScreen:(LoginVC *)loginViewController loginWithParameters:(NSDictionary *)userLoginParams
{
    [loginViewController disableUI:YES];
    
    //__weak LoginVC *weakLoginScreen = loginViewController;
    NSString *lvLoginName = [userLoginParams objectForKey:loginNameStringKey];
    NSString *lvLoginPassword = [userLoginParams objectForKey:loginPasswordStringKey];
    
    self.tempEmail = lvLoginName;
    self.tempPassword = lvLoginPassword;

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) loginScreenLoginWithTwitterPressed:(LoginVC *)loginViewController
{
    [[ServerRequester sharedRequester] tryToRequestTwitterInfoWithResult:^(NSDictionary *result)
    {
//        if (result)
//        {
//            NSLog(@"\r %@ \n - Recieved TWITTER user info: \n%@", NSStringFromClass([self class]), result.description);
//        }
    }];
}

-(void) loginScreenLoginWithFacebookPressed:(LoginVC *)loginViewController
{
    [[ServerRequester sharedRequester] tryToRequestFacebookInfoWithResult:^(NSDictionary *result)
     {
//         if (result)
//         {
//             NSLog(@"\r %@ \n - Recieved FACEBOOK user info: \n%@", NSStringFromClass([self class]), result.description);
//         }
    }];
}

#pragma mark - ChangePasswordDelegate
-(void) changePasswordViewController:(ChangePasswordVC *)changePasswordVC didChangePasswordSuscessfully:(BOOL)success
{
    if (success)
    {
        [ServerRequester sharedRequester].currentUser.state = @(0);
        __weak typeof(self) weakRootVC = self;
        if (self.presentedViewController && [self.presentedViewController isKindOfClass:[ChangePasswordVC class]])
        {
            [changePasswordVC dismissViewControllerAnimated:YES
                                                 completion:^
             {
                 [weakRootVC proceedAuthenticatingWorkflow];
             }];
        }
        
    }
    else
    {
        [changePasswordVC enableUI:YES];
        UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:@"Error while changing password"
                                                                            message:@"Please, try again. New password and confirmation should match"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                      {
                                          
                                      }];
        [emailAlert addAction:closeAction];
        
        [self presentViewController:emailAlert animated:YES completion:nil];
    }
}

//#pragma mark - DismissDelegate
//-(void) viewControllerWantsToDismiss:(UIViewController *)vc
//{
//    if([vc isKindOfClass:[PreloaderVC class]])
//    {
//        if (self.isLoggingIn)
//        {
//            NSLog(@"\r - %@ - Waiting for login.", NSStringFromClass([self class]));
//        }
//        else if (self.isLoadingMessagesAndKaraContact)
//        {
//             NSLog(@"\r - %@ - Waiting for messages and Kara to load.", NSStringFromClass([self class]));
//        }
//        else
//        {
//            NSLog(@"\r - Dismissing PreloaderVC after animation completion...");
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//        
//    }
//}
#pragma mark - Animations
-(void) startPreloaderAnimation
{
    self.animationView.animationFinishDelegate = self;
    AnimationsCreator *lvAnimator = [[AnimationsCreator alloc] init];
    CAKeyframeAnimation *lvPreloading = [lvAnimator preloaderAnimation];
    [self.animationView addAnimatedLayerIfNotExist];
    [self.animationView setCurrentAmbientAnimation:lvPreloading];
    [self.animationView proceedAnimatingAmbience];
}
#pragma mark AnimationCompletionDelegate
-(void) animationView:(AmbienceAnimationView *)view didFinishAnimation:(CAKeyframeAnimation *)animation
{
    UIImage *lastImage = [UIImage imageWithCGImage:(CGImageRef)animation.values.lastObject];
    view.image = lastImage;
    __weak typeof(self) weakRootVC = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        weakRootVC.shouldShowAnimation = NO;
         weakRootVC.didPlayPreloaderAnimation = YES;
    });
   
}

//-(void) animationView:(AmbienceAnimationView *)view didStartAnimation:(CAKeyframeAnimation *)animation
//{
////    NSLog(@"Preloader animation started");
//}

#pragma mark - Alret

-(void) showNeedPasswordAlertForEmail:(NSString *)userEmail
{
    NSString *message = [NSString stringWithFormat:@"Please check your email: \"%@\" to get temporary password and proceed to last step of registration.", userEmail];
    NSString *title = @"Attention";
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:title
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                      {
                                          
                                      }];
        [emailAlert addAction:closeAction];
        
        [self presentViewController:emailAlert animated:YES completion:nil];
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

#pragma mark - KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"didPlayPreloaderAnimation"])
    {
        [self proceedAuthenticatingWorkflow];
        [self removeObserver:self forKeyPath:keyPath];
    }
}






@end
