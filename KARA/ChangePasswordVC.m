//
//  ChangePasswordVC.m
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ChangePasswordVC.h"
#import "ServerRequester.h"
#import "Constants.h"


@interface ChangePasswordVC()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@property (weak, nonatomic) IBOutlet UITextField *userPass;

@property (weak, nonatomic) IBOutlet UITextField *verifyPass;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end



@implementation ChangePasswordVC

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifdef Messenger
    self.isKaraMessenger = YES;
#endif
    
    _userPass.delegate = self;
    _verifyPass.delegate = self;
    
    _changeButton.backgroundColor = Global_Tint_Color;
    _changeButton.layer.cornerRadius = 7.0;
    _changeButton.enabled = NO;
    
    _userPass.layer.cornerRadius = 7.0;
    _verifyPass.layer.cornerRadius = 7.0;
    
    _verifyPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _verifyPass.layer.borderWidth = 1.0;
    
    _userPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _userPass.layer.borderWidth = 1.0;
    
    _userPass.tintColor =  [UIColor whiteColor];
    _verifyPass.tintColor =  [UIColor whiteColor];
    
    
    //left text margin
    UIView *firstMargin, *secondMargin;
    CGRect marginFrame = CGRectMake(0, 0, 10.0, 40.0);
    
    firstMargin = [[UIView alloc] initWithFrame:marginFrame];
    secondMargin = [[UIView alloc] initWithFrame:marginFrame];
    
    _userPass.leftViewMode = _verifyPass.leftViewMode  = UITextFieldViewModeAlways;
    _verifyPass.leftView = firstMargin;
    _userPass.leftView = secondMargin;
    
    _titleLabel.text = NSLocalizedString(@"ChangePasswordTitle", nil);
    [self addKaraBackgroundImage];
    
}

-(void) enableUI:(BOOL)enable
{
    self.view.userInteractionEnabled = enable;
}


-(IBAction)ChangePressed:(id)sender
{
    if ([_userPass.text isEqualToString:_verifyPass.text])
    {
        [self performChangePasswordQuery]; //this will dismiss us if change password will be successfull
    }
    else
    {
        [self showAlertWithTitle:@"Warning!"
                          mesage:@"Passwords don`t match. Please retype."
                closeButtonTitle:@"Ok"];
    }
}

-(void) performChangePasswordQuery
{
    [self enableUI:NO];
    
    __weak ChangePasswordVC *weakSelf = self;
    [[ServerRequester sharedRequester] changePasswordWithNewPassword:_verifyPass.text completionBlock:^(NSDictionary *successResponse, NSError *error)
     {
         if (successResponse)
         {
             NSString *responseDescription = successResponse.description;
             
             if (responseDescription.length < 4)
             {
                 //save new password as user`s password to use in login routine
                 [[NSUserDefaults standardUserDefaults] setObject:weakSelf.verifyPass.text forKey:CURRENT_USER_PASSWORD];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [weakSelf.changePasswordDelegate changePasswordViewController:weakSelf didChangePasswordSuscessfully:YES];
                 //our job is done, we dismiss
//                 [weakSelf dismissViewControllerAnimated:YES completion:nil];
             }
         }
         else if (error)
         {
#ifdef DEBUG
             NSLog(@" ChangePressed Error: %@", error);
#endif
             [weakSelf showAlertWithTitle:@"Error"
                                   mesage:[NSString stringWithFormat: @"Failed to change password: %@", error.localizedFailureReason]
                         closeButtonTitle:@"Close"];
             [weakSelf.changePasswordDelegate changePasswordViewController:weakSelf didChangePasswordSuscessfully:NO];
         }
     }];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([_userPass.text isEqualToString:_verifyPass.text])
    {
        _changeButton.enabled = YES;
    }
    else
    {
        _changeButton.enabled = NO;
    }
    
    [textField resignFirstResponder];
    return YES;
}

-(void) showAlertWithTitle:(NSString *)title mesage:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:closeButtonTitle otherButtonTitles: nil] show];
    }
    else
    {
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonTitle style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:closeAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


#pragma Customizations
-(void) addKaraBackgroundImage
{
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view insertSubview:bgImageView atIndex:0];
    
    NSDictionary *subViews = NSDictionaryOfVariableBindings(bgImageView);
    
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bgImageView]|" options:0 metrics:nil views:subViews];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bgImageView]|" options:0 metrics:nil views:subViews];
    
    [self.view addConstraints:verticalConstraints];
    [self.view addConstraints:horizontalConstraints];
    
}



@end
