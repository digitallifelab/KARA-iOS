//
//  RegisterVC.h
//  Origami
//
//  Created by CloudCraft on 17.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ServerRequester.h"
@interface RegisterVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *firstNameTF;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTF;

@property (weak, nonatomic) IBOutlet UITextField *emailTF;

@property (weak, nonatomic) IBOutlet UITextField *languageTF;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

//@property (nonatomic, assign) BOOL didDetectLicenseAgreement;

-(BOOL) stringIsValidEmail:(NSString *)checkString;
-(void) showAlertWithTitle:(NSString *)title message:(NSString *) message closeButtonTitle:(NSString *)closeTitle closeHandler:(void(^)(void))closeHandler;
-(void) showLoadingIndicator:(BOOL)show;
@end
