//
//  ForgotPasswordVC.m
//  KARA
//
//  Created by CloudCraft on 28.05.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ForgotPasswordVC.h"

@interface ForgotPasswordVC ()<UITextFieldDelegate>

@end

@implementation ForgotPasswordVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //sublassing issues fixing
//    self.didDetectLicenseAgreement = YES;
    [self.registerButton setTitle:NSLocalizedString(@"StartChangingPassword", nil) forState:UIControlStateNormal];
    self.registerButton.enabled = YES;
    self.emailTF.delegate = self;
    self.emailTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_NAME];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerPress:(UIButton *)sender
{
    if ([self stringIsValidEmail:self.emailTF.text])
    {
        NSArray *lvValues = @[self.emailTF.text, dictNULL, dictNULL];
        NSArray *lvKeys = @[@"UserName", @"FirstName", @"LastName"];
        NSDictionary *registrationParams = [NSDictionary dictionaryWithObjects:lvValues forKeys:lvKeys];
        [self sendChangePasswordRequestWithParams:registrationParams];
    }
}

-(IBAction)dismissSelf:(UISwipeGestureRecognizer *)swipeDown
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(void) sendChangePasswordRequestWithParams:(NSDictionary *)params
{
    __weak typeof(self) weakSelf = self;
    [self showLoadingIndicator:YES];
    [[ServerRequester sharedRequester] registrationRequestWithParams:params
                                                     completionBlock:^(NSDictionary *successResponse, NSError *error)
    {
        [weakSelf showLoadingIndicator:NO];
        if (error)
        {
            //NSLog(@"\nResetPassword Error: \n%@",error);
            NSString *title = NSLocalizedString(@"ChangePasswordTrouble", nil);
            NSString *reason = error.localizedDescription;
            
            [weakSelf showAlertWithTitle:title
                                 message:reason
                        closeButtonTitle:NSLocalizedString(@"Close", nil)
                            closeHandler:nil];
        }
        else if (successResponse)
        {
            [weakSelf showAlertWithTitle:NSLocalizedString(@"EmailSent", nil)
                             message:NSLocalizedString(@"CheckEmailForPassword", nil)
                    closeButtonTitle:NSLocalizedString(@"Close", nil)
                        closeHandler:^
            {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
