//
//  RegisterVC.m
//  Origami
//
//  Created by CloudCraft on 17.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "RegisterVC.h"

//#import "ServerRequester.h"
//#import "LicenseAgreementVC.h"
#import "UIImage+FromColor.h"
#import "TableItemPickerVC.h"
#import "Protocols.h"

@interface RegisterVC ()<UITextFieldDelegate, TableItemPickerDelegate>//, LicenseAgreementDelegate>


//@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;
//
//@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;
//
//@property (weak, nonatomic) IBOutlet UITextField *emailTF;
//
//@property (weak, nonatomic) IBOutlet UITextField *languageTF;
//
//@property (weak, nonatomic) IBOutlet UIButton *registerButton;

//constraints to deal with iPhone 4 screen size
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoToTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstNameTopToLogoBottomComstraint;
//@property (nonatomic, assign) BOOL didDetectLicenseAgreement;
@end




@implementation RegisterVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 

    _firstNameTF.delegate = self;
    _lastNameTF.delegate = self;
    _emailTF.delegate = self;
    _languageTF.delegate = self;
    
    [self addKaraBackgroundImage];
    
    //add swipe down to dismiss functionaity.
    UISwipeGestureRecognizer *swipeToBottom = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf:)];
    swipeToBottom.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeToBottom];
    
    [_registerButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [_registerButton setTitleColor: Global_Border_Color/*[UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0]*/ forState:UIControlStateDisabled];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _registerButton.enabled = NO; //will be enabled only after inserting data into fields
    _registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _registerButton.layer.borderWidth = 1.0;
    _registerButton.layer.cornerRadius = 7.0;
    _registerButton.layer.masksToBounds = YES;
    [_registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    
    _emailTF.layer.cornerRadius = 7.0;
    _firstNameTF.layer.cornerRadius = 7.0;
    _lastNameTF.layer.cornerRadius = 7.0;
    _languageTF.layer.cornerRadius = 7.0;
    
    _lastNameTF.layer.borderColor = _firstNameTF.layer.borderColor = _emailTF.layer.borderColor = _languageTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _lastNameTF.layer.borderWidth = _firstNameTF.layer.borderWidth = _emailTF.layer.borderWidth = _languageTF.layer.borderWidth = 1.0;
    
    //left margin for text in textfields
    UIView *firstMargin, *secondMargin, *thirdMargin, *languageMargin;
    
    CGRect marginFrame = CGRectMake(0, 0, 10.0, 40.0);
    
    firstMargin = [[UIView alloc] initWithFrame:marginFrame];
    secondMargin = [[UIView alloc] initWithFrame:marginFrame];
    thirdMargin = [[UIView alloc] initWithFrame:marginFrame];
    languageMargin = [[UIView alloc] initWithFrame:marginFrame];
    
    _emailTF.leftViewMode = _firstNameTF.leftViewMode = _lastNameTF.leftViewMode = _languageTF.leftViewMode = UITextFieldViewModeAlways;
    _emailTF.leftView = firstMargin;
    _firstNameTF.leftView = secondMargin;
    _lastNameTF.leftView = thirdMargin;
    _languageTF.leftView = languageMargin;
    
    
    
    //text colot
    _emailTF.textColor = [UIColor whiteColor];
    _firstNameTF.textColor = [UIColor whiteColor];
    _lastNameTF.textColor = [UIColor whiteColor];
    _languageTF.textColor = [UIColor whiteColor];
    
    //tint color (caret)
    _lastNameTF.tintColor = [UIColor whiteColor];
    _firstNameTF.tintColor = [UIColor whiteColor];
    _emailTF.tintColor = [UIColor whiteColor];
    _languageTF.tintColor = [UIColor whiteColor];
    
    NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName:[UIColor grayColor]};
    _firstNameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"firstName", nil) attributes:placeholderAttributes];
    _lastNameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"lastName", nil) attributes:placeholderAttributes];
    _emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"e-mail" attributes:placeholderAttributes];
    _languageTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"language", nil) attributes:placeholderAttributes];
    
    //iphone 4, 4s screen
    if ([UIScreen mainScreen].bounds.size.height < 500)
    {
        self.logoToTopConstraint.constant = 00.0;
        self.firstNameTopToLogoBottomComstraint.constant = 5.0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    BOOL licenseAccepted = [[NSUserDefaults standardUserDefaults] boolForKey:LICENSE_ACCEPTED];
//    if (!licenseAccepted && !self.didDetectLicenseAgreement)
//    {
//        [self showLicenseAgreementVC];
//    }
}

#pragma mark -

//-(void) showLicenseAgreementVC
//{
//    LicenseAgreementVC *lvAgreementVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LicenseAgreement"];
//    lvAgreementVC.delegate = self;
//    
//    [self presentViewController:lvAgreementVC animated:YES completion:nil];
//}

-(void) dismissSelf:(UISwipeGestureRecognizer *)swipeDown
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerPress:(UIButton *)sender
{
    //step 1 - try to validate email address
    if ([self stringIsValidEmail:_emailTF.text])
    {
        LanguageObject *lvChoosenUSerLanguage = [[LanguageObject alloc] initWithInfo:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserLanguage"]];
        
        if (_firstNameTF.text.length > 0 && _lastNameTF.text.length > 0 && lvChoosenUSerLanguage)
        {
            [self proceedRegistration];
        }
        else
        {
            [self showAlertWithTitle:NSLocalizedString(@"Warning", nil)
                             message:NSLocalizedString(@"CheckNames", nil)
                    closeButtonTitle:NSLocalizedString(@"Close", nil)
                        closeHandler:nil];
        }
    }
    else
    {
        [self showAlertWithTitle:NSLocalizedString(@"Warning", nil)
                         message:NSLocalizedString(@"WrongEmail", nil)
                closeButtonTitle:NSLocalizedString(@"Close", nil)
                    closeHandler:nil];
        
        _emailTF.text = @"";
    }
}

#pragma mark - UITExtFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (_firstNameTF.text.length > 0 && _lastNameTF.text.length > 0 && _emailTF.text.length > 0)
    {
        _registerButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0].CGColor;
        _registerButton.enabled = YES;
    }
    else
    {
        _registerButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7].CGColor;
        _registerButton.enabled = NO;
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_firstNameTF.text.length > 0 && _lastNameTF.text.length > 0 && _emailTF.text.length > 0)
    {
        _registerButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0].CGColor;
        _registerButton.enabled = YES;
    }
    else
    {
        _registerButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7].CGColor;
        _registerButton.enabled = NO;
    }
    
    if ([string isEqualToString:@""])
    {
        if (_emailTF.text.length == 1 || _firstNameTF.text.length == 1 || _lastNameTF.text.length == 1) //disable reg button
        {
            _registerButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7].CGColor;
            _registerButton.enabled = NO;
        }
    }
    
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _languageTF)
    {
        for (UITextField *lvField in self.view.subviews)
        {
            if ([lvField respondsToSelector:@selector(resignFirstResponder)])
            {
                [lvField resignFirstResponder];
            }
        }
        [self startEditingLanguage];
        return NO;
    }
    return YES;
}
#pragma mark -


-(BOOL) stringIsValidEmail:(NSString *)checkString //example taken from stackoverflow.com
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void) proceedRegistration
{
    if (self.firstNameTF.isFirstResponder)
    {
        [self.firstNameTF resignFirstResponder];
    }
    else if (self.lastNameTF.isFirstResponder)
    {
        [self.lastNameTF resignFirstResponder];
    }
    else if (self.emailTF.isFirstResponder)
    {
        [self.emailTF resignFirstResponder];
    }
    
    //step 2 - send registration is valid
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    //add "loadig" indicator

    [self showLoadingIndicator:YES];
    
    
    _registerButton.enabled = NO;
    
    //prepare registration info
    __weak RegisterVC *weakSelf = self;
    NSArray *keys = @[@"UserName",@"FirstName",@"LastName"];
    NSArray *values = @[_emailTF.text,_firstNameTF.text,_lastNameTF.text];
    NSDictionary *paramsToPass = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    //send request to server
    ServerRequester *requester = [ServerRequester sharedRequester];
    [requester registrationRequestWithParams:paramsToPass completionBlock:^(NSDictionary *successResponse, NSError *error)
     {
         
         [weakSelf showLoadingIndicator:NO];
         
         weakSelf.registerButton.enabled = YES;
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if (error)
         {
             //NSLog(@"\nRegistration Error: \n%@",error);
             NSString *title = NSLocalizedString(@"RegistrationTrouble", nil);
             NSString *reason = error.localizedDescription;
             
             [weakSelf showAlertWithTitle:title message:reason closeButtonTitle:NSLocalizedString(@"Close", nil) closeHandler:nil];
            
         }
         if (successResponse)
         {
             //for new user by defaults sounds are enabled
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SOUNDS_ENABLED];
            
             //NSLog(@"\nRegistration Success: \n%@",successResponse);
             //empty response
             //show login screen and alert to go to email to get password
             [[NSUserDefaults standardUserDefaults] setObject:_emailTF.text forKey:CURRENT_USER_NAME];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [weakSelf showAlertWithTitle:NSLocalizedString(@"Congrats", nil)
                                  message:NSLocalizedString(@"CheckEmailForPassword", nil)
                         closeButtonTitle:NSLocalizedString(@"Close", nil)
                             closeHandler:^
             {
                [weakSelf dismissViewControllerAnimated:YES completion:nil]; //dismises not alert controller, but us (RegisterVC) for Root view controller to proceed registration - show ChangePasswordVC to user - to change 1 time password.(and assign choosen language).
             }];
         }
     }];
}

-(void) showLoadingIndicator:(BOOL)show
{
    if (show)
    {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(self.view.bounds.size.width / 2 - 100, self.view.bounds.size.height / 2 - 100, 200.0, 200.0);
        activityView.hidesWhenStopped = YES;
        activityView.layer.cornerRadius = 10.0;
        activityView.backgroundColor = [UIColor lightGrayColor];
        
        activityView.tag = 1;
        [self.view addSubview:activityView];
        [activityView startAnimating];
    }
    else
    {
        //remove animating
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[self.view viewWithTag:1];
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
}

-(void) showAlertWithTitle:(NSString *)title message:(NSString *) message closeButtonTitle:(NSString *)closeTitle closeHandler:(void(^)(void))closeHandler
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeTitle
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action)
    {
        if (closeHandler)
            closeHandler();
    }];
    
    [alertController addAction:closeAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    _registerButton.enabled = NO;
}


#pragma Customizations
-(void) addKaraBackgroundImage
{
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view insertSubview:bgImageView atIndex:0];
    
    NSDictionary *subViews = NSDictionaryOfVariableBindings(bgImageView);
    
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bgImageView]|" options:0 metrics:nil views:subViews];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bgImageView]|" options:0 metrics:nil views:subViews];
    
    [self.view addConstraints:verticalConstraints];
    [self.view addConstraints:horizontalConstraints];
    
}

#pragma mark - Language Picking stuff
-(void) startEditingLanguage
{
    //show picker view
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    TableItemPickerVC *countryAndLanguagePicker = (TableItemPickerVC *)[mainSB instantiateViewControllerWithIdentifier:@"TableItemPickerVC"];
    
    countryAndLanguagePicker.itemsToChoose = [DataSource sharedInstance].languages;
    
    [self presentViewController:countryAndLanguagePicker animated:YES completion:^
     {
         countryAndLanguagePicker.delegate = self;
         countryAndLanguagePicker.doneBtton.hidden = YES; //we will dismiss picker View Controller by ourselves when country choosing happens
     }];
}

-(BOOL) tablePickerShouldAllowMultipleSelection:(TableItemPickerVC *)pickerViewController
{
    return NO;
}

-(void) tablePicker:(TableItemPickerVC *)pickerViewCotroller didSelectObject:(id)object currentType:(NSInteger)currentType
{
    TablePickerType pickerType = currentType;
    switch (pickerType)
    {
        case PickLanguage:
        {
            LanguageObject *choosenLanguage = (LanguageObject *)object;
            [[NSUserDefaults standardUserDefaults] setObject:[choosenLanguage toDictionary] forKey:@"UserLanguage"];
            self.languageTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:choosenLanguage.languageName
                                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
#ifdef DEBUG
            NSLog(@"\r - User has choosen %@ language", choosenLanguage.languageName);
#endif
        }
            break;
            
        default:
            break;
    }
    
    //__weak typeof(self) weakProfileVC = self;
    [pickerViewCotroller dismissViewControllerAnimated:YES completion:^
     {
//         [weakProfileVC.profileTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(currentType == PickCountry)?5:4 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
         [[NSUserDefaults standardUserDefaults] synchronize];
     }];
}

-(void) tablePicker:(TableItemPickerVC *)pickerViewController doneButtonTapped:(UIButton *)sender
{
    
}

//#pragma mark LicenseAgreementDelegate
//-(void) licenseAgreementVC:(LicenseAgreementVC *)viewController didAcceptLicense:(BOOL)accepted
//{
//    [[NSUserDefaults standardUserDefaults] setBool:accepted forKey:LICENSE_ACCEPTED];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    self.didDetectLicenseAgreement = YES;
//    if (!accepted)
//    {
//        __weak typeof(self) weakSelf = self;
//        [viewController dismissViewControllerAnimated:YES completion:^
//        {
//            [weakSelf dismissViewControllerAnimated:YES completion:nil];
//        }];
//    }
//    else
//    {
//        [viewController dismissViewControllerAnimated:YES completion:nil];
//    }
//}

@end
