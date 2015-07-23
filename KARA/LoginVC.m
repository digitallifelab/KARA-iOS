//
//  LoginVC.m
//  Origami
//
//  Created by CloudCraft on 17.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "LoginVC.h"
#import "Constants.h"
#import "ServerRequester.h"
@interface LoginVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *forgotPasswordTap;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *buttonsHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *logoTopConstraint;

@end

const NSString *loginNameStringKey = @"loginName";
const NSString *loginPasswordStringKey = @"loginPass";

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userNameTF.delegate = self;
    _passwordTF.delegate = self;
    
    _loginButton.tintColor = [UIColor whiteColor];
    _registerButton.tintColor = [UIColor whiteColor];
    _loginButton.backgroundColor = [UIColor clearColor] ;
    _registerButton.backgroundColor =  [UIColor clearColor];
    _loginButton.layer.cornerRadius = 7.0;
    _registerButton.layer.cornerRadius = 7.0;
    
    _userNameTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _passwordTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _passwordTF.layer.borderWidth = 1.0;
    _userNameTF.layer.borderWidth = 1.0;
    _userNameTF.layer.cornerRadius = 7.0;
    _passwordTF.layer.cornerRadius = 7.0;
    _passwordTF.layer.masksToBounds = YES;
    _userNameTF.layer.masksToBounds = YES;
    _userNameTF.tintColor =  [UIColor whiteColor];
    _passwordTF.tintColor =  [UIColor whiteColor];
    
    //add left margin to textfields
    UIView *leftViewOne = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, _userNameTF.bounds.size.height)];
    leftViewOne.backgroundColor = [UIColor clearColor];
    _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    _userNameTF.leftView = leftViewOne;
    
    UIView *leftViewTwo = [[UIView alloc] initWithFrame:leftViewOne.frame];
    leftViewTwo.backgroundColor = [UIColor clearColor];
    _passwordTF.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF.leftView = leftViewTwo;

    _passwordTF.textColor = [UIColor whiteColor];
    _userNameTF.textColor = [UIColor whiteColor] ;
    
    
    //add background image or gradient
    _loginButton.layer.cornerRadius = 7.0;
    _loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _loginButton.layer.borderWidth = 1.0;
    [_loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    
    _registerButton.layer.cornerRadius = 7.0;
    _registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _registerButton.layer.borderWidth = 1.0;
    [_registerButton setTitle:NSLocalizedString(@"Registration", nil) forState:UIControlStateNormal];
    
    [self addKaraBackgroundImage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [_facebookButton maskToOctagon];
//    [_twitterButton maskToOctagon];
    UIColor *color = [UIColor grayColor];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_NAME];
    if (userName)
    {
        _userNameTF.text = userName;
    }
    else
    {
        _userNameTF.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email", nil)
                                        attributes:@{NSForegroundColorAttributeName:color}];
    }
    
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_PASSWORD];
    if (password)
    {
        _passwordTF.text = password;
    }
    else
    {
        if ([ServerRequester sharedRequester].currentUser.state.integerValue == 1)
        {
            _passwordTF.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"RecievedPassword", nil)
                                            attributes:@{NSForegroundColorAttributeName:color}];
        }
        else
        {
            _passwordTF.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil)
                                            attributes:@{NSForegroundColorAttributeName:color}];
        }
    }
    
    CGFloat viewHeight = self.view.bounds.size.height;
    if (viewHeight < 500)
    {
        _buttonsHeightConstraint.constant = 44.0;
        _logoTopConstraint.constant = 8.0;
    }
    
    if (self.logoImage.image == nil)
    {
        self.logoImage.image = [UIImage imageNamed:@"logo-1"];
    }
    
    if (_passwordTF.text.length < 1)
    {
        _loginButton.enabled = NO;
    }
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//}

#pragma mark - login buttons
- (IBAction)loginButtonPress:(UIButton *)sender
{
    if (self.passwordTF.isFirstResponder)
    {
        [self.passwordTF resignFirstResponder];
    }
    else if ( self.userNameTF.isFirstResponder)
    {
        [self.userNameTF resignFirstResponder];
    }
    
    if (_userNameTF.text.length > 0 && _passwordTF.text.length > 0)
    {
        [self.loginDelegate loginScreen:self loginWithParameters:@{loginNameStringKey:_userNameTF.text, loginPasswordStringKey:_passwordTF.text}];
    }
}

- (IBAction)registerButtonPress:(UIButton *)sender
{
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LICENSE_ACCEPTED];
    [self performSegueWithIdentifier:@"RegistrationSegue" sender:self];
}

-(IBAction)forgotPasswordTap:(UITapGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"ForgotPasswordSegue" sender:self];
}

-(IBAction)twitterLoginPress:(id)sender
{
    [self.loginDelegate loginScreenLoginWithTwitterPressed:self];
}


-(IBAction)facebookLoginPress:(id)sender
{
    [self.loginDelegate loginScreenLoginWithFacebookPressed:self];
}
#pragma mark -


#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (_passwordTF.text.length > 0 && _userNameTF.text.length > 0)
    {
        _loginButton.enabled = YES;
    }
    else
    {
        _loginButton.enabled = NO;
    }
    return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_passwordTF.text.length > 0 && _userNameTF.text.length > 0)
    {
        if (textField.text.length == 1 && string.length == 0)
        {
            _loginButton.enabled = NO;
            return YES;
        }
  
        _loginButton.enabled = YES;
        return YES;
    }
    else
    {
        _loginButton.enabled = NO;
        return YES;
    }

}



#pragma mark - Customization

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

-(void) disableUI:(BOOL)disable
{
    self.view.userInteractionEnabled = !disable;
}

@end
