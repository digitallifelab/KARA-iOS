//
//  ProfileVC.m
//  KARA
//
//  Created by CloudCraft on 06.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ProfileVC.h"

#import "ProfileCell.h"
#import "ProfileEditCell.h"
#import "ProfileSexEditingCell.h"
#import "ProfileButtonCell.h"
#import "ProfilePasswordCell.h"
#import "ServerRequester.h"
#import "DataSource.h"
#import "NSDate+ServerFormat.h"
#import "NSString+ServerDate.h"
#import "Constants.h"

#import "DatePickerViewController.h"
#import "NSDate+Compare.h"

#import "TableItemPickerVC.h"
#import "CurrentUserHeader.h"
#import "AvatarPickerController.h"
#import "FileHandler.h"
@interface ProfileVC ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, UITextViewDelegate, SexCellDelegate, ButtonCellDelegate, DateChoosingDelegate, TableItemPickerDelegate, ContactProfileHeaderDelegate, ImagePickingDelegate>

@property (nonatomic, strong) UIBarButtonItem *cancelPhoneButton;
@property (nonatomic, strong) UIBarButtonItem *donePhoneButton;

@property (nonatomic, weak) IBOutlet UITableView *profileTable;
@property (nonatomic, assign) BOOL isEditingProfile;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, assign) BOOL hasUpdatedUser;
@property (nonatomic, assign) BOOL enabledPasswordChange;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (nonatomic, assign) CGFloat defaultTableBottom;
@property (nonatomic, strong) NSString *stringNewPassword;
@property (nonatomic, strong) NSString *stringConfirmPassword;

@property (nonatomic, strong) NSMutableDictionary *editedStrings;

@end


@implementation ProfileVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [[DataSource sharedInstance] getCurrentUser];
    
    [self setupTitleView];
    [self setupTransparentNavigationBar:YES];
    [self setupBarButtons];
    
    
    self.profileTable.estimatedRowHeight = 50.0;
    self.profileTable.rowHeight = UITableViewAutomaticDimension;
    self.profileTable.delegate = self;
    self.profileTable.dataSource = self;
    
    self.editedStrings = [[NSMutableDictionary alloc] initWithCapacity:10];
  
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.defaultTableBottom = self.tableBottomConstraint.constant;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardAppearing:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardAppearing:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
#pragma mark -
- (void) setupTitleView
{
//    UIImage *karaLogo = [[UIImage imageNamed:@"logo-1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:karaLogo];
//    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
//    titleImageView.frame = CGRectMake(0, 0, 100, 30);
//    //titleImageView.layer.borderWidth = 1.0;
//    self.navigationItem.titleView = titleImageView;
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    userNameLabel.textAlignment = NSTextAlignmentCenter;
    userNameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.currentUser.firstName attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:19.0]}];
    
    [userNameLabel sizeToFit];
    
    self.navigationItem.titleView = userNameLabel;
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
//    else
//    {
//        self.navigationController.navigationBar.translucent = NO;
//        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = nil;
//        self.navigationController.navigationBar.backgroundColor = nil;
//        
//        self.navigationController.navigationBar.tintColor = Global_Tint_Color;
//    }
}

-(void) setupBarButtons
{

    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(closeTap:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;

    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                    target:self
                                                                                    action:@selector(toggleEditing:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

#pragma mark - 
-(void) colorPasswordCellsForMathcing:(BOOL)match
{
    if (self.enabledPasswordChange)
    {
        UIColor *toChange = (match)?[[UIColor greenColor] colorWithAlphaComponent:0.7]:[UIColor clearColor];
        //get last 2 cells
        for (NSInteger i = 9; i<11; i++)
        {
            NSIndexPath *lvPath = [NSIndexPath indexPathForRow:i inSection:1];
            ProfilePasswordCell *lvPassCell = (ProfilePasswordCell *)[self.profileTable cellForRowAtIndexPath:lvPath];
            [lvPassCell setNewBackgroundColor: toChange];
        }
    }
}
#pragma mark - 
-(BOOL) checkUserProfileNeedsUpdate
{
    if (self.stringNewPassword && self.stringConfirmPassword && [self.stringNewPassword isEqualToString:self.stringConfirmPassword] && ![self.currentUser.password isEqualToString:self.stringNewPassword])
    {
        self.hasUpdatedUser = YES;
    }
    
    if(self.hasUpdatedUser)
        return YES;
    
    
    BOOL didChangeProfile = NO;
    if (self.editedStrings.allKeys.count > 0)
    {
        for (NSString *key in self.editedStrings.allKeys)
        {
            NSString *newValue = [self.editedStrings objectForKey:key];
            NSString *testedUserValue;
            if ([key isEqualToString:NSLocalizedString(@"mood", nil)])
            {
                testedUserValue = self.currentUser.mood;
            }
            else if ([key isEqualToString:NSLocalizedString(@"firstName", nil)])
            {
                testedUserValue = self.currentUser.firstName;
            }
            else if ([key isEqualToString:NSLocalizedString(@"lastName", nil)])
            {
                testedUserValue = self.currentUser.lastName;
            }
            //        else if ([key isEqualToString:@"sex"])
            //        {
            //
            //        }
            else if ([key isEqualToString:NSLocalizedString(@"phoneNumber", nil)])
            {
                testedUserValue = self.currentUser.phoneNumber;
            }
            
            if (testedUserValue && ![testedUserValue isEqualToString:newValue])
            {
                didChangeProfile = YES;
                break;
            }
            
        }
    }
    
    
    return didChangeProfile;
}

#pragma mark - IBActions
-(void) closeTap:(id)sender
{
    [self.dismissDelegate viewControllerWantsToDismiss:self];
}
-(void) enableEditingButton:(BOOL) enable
{
    if (enable)
    {
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
        [self.profileTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
        self.navigationItem.rightBarButtonItem = doneBarButton;
        
        [self.profileTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void) toggleEditing:(id)sender
{
    self.isEditingProfile = !self.isEditingProfile;
    
    if (self.isEditingProfile)
    {
        [self.editedStrings removeAllObjects];
        
        [self enableEditingButton:YES];
    }
    else
    {
        if ([self checkUserProfileNeedsUpdate])
        {
            __weak typeof(self) weakProfileVC = self;
            //update user
            [self updateUserInBackgroundWithCompletion:^(BOOL updated)
             {
                [weakProfileVC enableEditingButton:NO];
            }];
        }
        else
        {
            //refresh UI
            [self enableEditingButton:NO];
        }
    }
}

-(void) updateUserInBackgroundWithCompletion:(void(^)(BOOL updated))updateComplitionBlock
{
    User *backupUser = [[User alloc] initWithParameters:[[ServerRequester sharedRequester].currentUser toDictionary]];
    
    User *currentUser = [ServerRequester sharedRequester].currentUser;
    if (self.editedStrings.allKeys.count > 0)
    {
        for (NSString *key in self.editedStrings.allKeys)
        {
            NSString *keyPath;
            if ([key isEqualToString:NSLocalizedString(@"firstName", nil)])
            {
                keyPath = @"firstName";
            }
            else if ([key isEqualToString:NSLocalizedString(@"lastName", nil)])
            {
                keyPath = @"lastName";
            }
            else if ([key isEqualToString:NSLocalizedString(@"mood", nil)])
            {
                keyPath = @"mood";
            }
            else if ([key isEqualToString:NSLocalizedString(@"phoneNumber", nil)])
            {
                keyPath = @"phoneNumber";
            }
            else if ([key isEqualToString:NSLocalizedString(@"birthDay", nil)])
            {
                keyPath = @"birthDay";
            }
            
            if (keyPath)
            {
                [currentUser setValue:[self.editedStrings objectForKey:key] forKeyPath:keyPath];
            }
        }
    }

    if (self.stringNewPassword && self.stringConfirmPassword && [self.stringNewPassword isEqualToString:self.stringConfirmPassword])
    {
        currentUser.password = self.stringNewPassword;
#ifdef DEBUG
        NSLog(@"\n - Updating new user password...\n");
#endif
    }
    
    [[ServerRequester sharedRequester] updateUserInfoWithCompletion:^(NSDictionary *successResponse, NSError *error)
     {
         if (updateComplitionBlock)
         {
             if (error)
             {
                 [ServerRequester sharedRequester].currentUser = backupUser;
                // NSLog(@"\n - Did not update User Info\n");
                 updateComplitionBlock(NO);
             }
             else
             {
                 //NSLog(@"\n - Updated User Info.\n");
                 updateComplitionBlock(YES);
             }
         }
    }];
}

#pragma mark - Editing
#pragma mark Phone number
-(void) startEditingTelNumber
{
    NSIndexPath *telNumberCellPath = [NSIndexPath indexPathForRow:7 inSection:1];
    ProfilePasswordCell *cell = (ProfilePasswordCell *)[self.profileTable cellForRowAtIndexPath:telNumberCellPath];
    cell.passwordTextField.userInteractionEnabled = YES;
    
    
    [cell.passwordTextField setKeyboardType:UIKeyboardTypePhonePad];
    [cell.passwordTextField setSecureTextEntry:NO];
    
    [cell.passwordTextField becomeFirstResponder];
}

-(UIView *)setupTextFieldAccessoryView
{
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0,0, 50, 40);
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPhoneEntry) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    //[buttonsHolder addSubview:self.dismissButton];
    
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 0, 50, 40);
    [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(submitPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    [doneButton sizeToFit];
    
    
    UIToolbar * toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    [toolBar setBarTintColor:Global_Tint_Color];
    [toolBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    self.cancelPhoneButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.donePhoneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    //self.searchBarButon = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    //self.searchBarButon.enabled = NO;
    toolBar.items = @[self.cancelPhoneButton, flexibleSpace, self.donePhoneButton];//, flexibleSpace, self.searchBarButon];
    
    return toolBar;
}

-(void) submitPhoneNumber
{
    NSIndexPath *phoneCellPath = [NSIndexPath indexPathForRow:7 inSection:1];
    ProfilePasswordCell *cell = (ProfilePasswordCell *)[self.profileTable cellForRowAtIndexPath:phoneCellPath];
    NSString *newPhone = cell.passwordTextField.text;
    
    if ([[newPhone substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"])
    {
        NSCharacterSet *allowedDigits = [NSCharacterSet decimalDigitCharacterSet];
        NSString *phoneString = [newPhone stringByTrimmingCharactersInSet:allowedDigits.invertedSet];
        if (phoneString.length == 12)
        {
            cell.passwordTextField.userInteractionEnabled = NO;
            [cell.passwordTextField resignFirstResponder];
            [self.editedStrings setObject:newPhone forKey:NSLocalizedString(@"phoneNumber", nil)];
        }
        else
        {
            cell.passwordTextField.userInteractionEnabled = NO;
            [cell.passwordTextField resignFirstResponder];
            cell.passwordTextField.text = @"";
            [self showAlertWithTitle:@"Warning"
                             message:@"phone number must be in the international format: \"+\"and 12 digits"
                    closeButtonTitle:@"Ok"
                      dismissHandler:nil];
        }
        
    }
    else
    {
        cell.passwordTextField.userInteractionEnabled = NO;
        [cell.passwordTextField resignFirstResponder];
        cell.passwordTextField.text = @"";
        [self showAlertWithTitle:@"Warning"
                         message:@"phone number must be in the international format: \"+\"and 12 digits"
                closeButtonTitle:@"Ok"
                  dismissHandler:nil];
    }
}

-(void) cancelPhoneEntry
{
    NSIndexPath *phoneCellPath = [NSIndexPath indexPathForRow:7 inSection:1];
    ProfilePasswordCell *cell = (ProfilePasswordCell *)[self.profileTable cellForRowAtIndexPath:phoneCellPath];
    cell.passwordTextField.userInteractionEnabled = NO;

    [cell.passwordTextField resignFirstResponder];
    [self.profileTable reloadRowsAtIndexPaths:@[phoneCellPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark Birthday
-(void) startEditingBirthday
{
    
    DatePickerViewController *dateVC = (DatePickerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DatePicking"];
    
    dateVC.currentDate = [[ServerRequester sharedRequester].currentUser.birthDay dateFromServerDateString];
    dateVC.isBirthdayPicker = YES; //hide time picker
    [self presentViewController:dateVC animated:YES completion:^
     {
         dateVC.delegate = self;
     }];
}

-(void) dateChoosingDidFinishSelectingDate:(NSDate *)date
{
    NSString *birthDateStringNew = [date dateForServer];//[NSString stringWithFormat:@"/Date(%ld000+0000)/", (long)birthInterval];
    
    NSDate *currentUserBirthDayDate = [[ServerRequester sharedRequester].currentUser.birthDay dateFromServerDateString];
    if (currentUserBirthDayDate)
    {
        if ([currentUserBirthDayDate compareDateOnly:date] != NSOrderedSame)
        {
            //update user birth date to new one
            [self.editedStrings setObject: birthDateStringNew forKey: NSLocalizedString(@"birthDay", nil) ];
        }
    }
    else
    {
        //assign new birthday
        [ServerRequester sharedRequester].currentUser.birthDay = birthDateStringNew;
        _hasUpdatedUser = YES;
    }
}

#pragma mark Language
-(void) startEditingCountry
{
//    UIStoryboard *settingsSB = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    
    TableItemPickerVC *countryAndLanguagePicker = (TableItemPickerVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"TableItemPickerVC"];
    
    countryAndLanguagePicker.itemsToChoose = [DataSource sharedInstance].countries;
    
    [self presentViewController:countryAndLanguagePicker animated:YES completion:^
     {
         countryAndLanguagePicker.delegate = self;
         countryAndLanguagePicker.doneBtton.hidden = YES; //we will dismiss picker View Controller by ourselves when country choosing happens
     }];
}

#pragma mark Country
-(void) startEditingLanguage
{
    //show picker view
//    UIStoryboard *settingsSB = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    
    TableItemPickerVC *countryAndLanguagePicker = (TableItemPickerVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"TableItemPickerVC"];
    
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
    
    User *currentUser = [ServerRequester sharedRequester].currentUser;
    switch (pickerType)
    {
        case PickCountry:
        {
            CountryObject *choosenCountry = (CountryObject *)object;
            if (currentUser.country && choosenCountry.countryName)
            {
                if (![currentUser.country isEqualToString:choosenCountry.countryName])
                {
                    currentUser.country = choosenCountry.countryName;
                    currentUser.countryID = choosenCountry.countryId;
                    self.hasUpdatedUser = YES;
                }
            }
            else if (choosenCountry)
            {
                currentUser.country = choosenCountry.countryName;
                currentUser.countryID = choosenCountry.countryId;
                self.hasUpdatedUser = YES;
            }
        }
            break;
            
        case PickLanguage:
        {
            LanguageObject *choosenLanguage = (LanguageObject *)object;
            if (currentUser.language && choosenLanguage.languageName)
            {
                if (![currentUser.language isEqualToString:choosenLanguage.languageName])
                {
                    currentUser.language = choosenLanguage.languageName;
                    currentUser.languageID = choosenLanguage.languageId;
                    self.hasUpdatedUser = YES;
                }
            }
            else if (choosenLanguage)
            {
                currentUser.language = choosenLanguage.languageName;
                currentUser.languageID = choosenLanguage.languageId;
                self.hasUpdatedUser = YES;
            }
        }
            break;
            
        default:
            break;
    }
    
    __weak typeof(self) weakProfileVC = self;
    [pickerViewCotroller dismissViewControllerAnimated:YES completion:^
    {
        [weakProfileVC.profileTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(currentType == PickCountry)?5:4 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

-(void) tablePicker:(TableItemPickerVC *)pickerViewController doneButtonTapped:(UIButton *)sender
{
    
}

#pragma mark Name
-(void) startEditingFirstName
{
    NSIndexPath *telNumberCellPath = [NSIndexPath indexPathForRow:1 inSection:1];
    ProfilePasswordCell *cell = (ProfilePasswordCell *)[self.profileTable cellForRowAtIndexPath:telNumberCellPath];
    cell.passwordTextField.userInteractionEnabled = YES;
    
    
    [cell.passwordTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [cell.passwordTextField setSecureTextEntry:NO];
    
    [cell.passwordTextField becomeFirstResponder];
}

-(void) startEditingLastName
{
    NSIndexPath *telNumberCellPath = [NSIndexPath indexPathForRow:2 inSection:1];
    ProfilePasswordCell *cell = (ProfilePasswordCell *)[self.profileTable cellForRowAtIndexPath:telNumberCellPath];
    cell.passwordTextField.userInteractionEnabled = YES;
    
    
    [cell.passwordTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [cell.passwordTextField setSecureTextEntry:NO];
    
    [cell.passwordTextField becomeFirstResponder];
}


//}

#pragma mark - TableView
#pragma mark  UITableViewDelegate

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //we need square header
    CGFloat height = 0.0;//= tableView.bounds.size.width;
    if (section == 0)
    {
        if (self.view.bounds.size.height < 500.0)
        {
            height = 130.0;
        }
        else
            height = 150.0;
    }
    
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        CGFloat sideDimension = [self tableView:self.profileTable heightForHeaderInSection:0];
        
        CurrentUserHeader *header = [[CurrentUserHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, sideDimension)];
        //header.layer.borderWidth = 2.0;
        header.userPhoto.userInteractionEnabled = self.isEditingProfile;
        
        [header setAutoresizingMask:UIViewAutoresizingNone];
        //header.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        header.userEmailLabel.text = self.currentUser.loginName;
        
        [header layoutIfNeeded];
        if (self.currentUser.photo.length > 10) //not empty data
        {
            header.userPhoto.contentMode = UIViewContentModeScaleAspectFill;
        }
        [header maskAvatarToOctagon];
        
        header.delegate = self; // to upload new image
        
        if (self.currentUser.photo.length > 0)
        {
            header.userPhoto.image = [UIImage imageWithData: self.currentUser.photo];
        }
        
        return header;
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.isEditingProfile)
    {
        
        switch (indexPath.row)
        {
            case 1:
            {
                [self startEditingFirstName];
            }
                break;
            case 2:
            {
                [self startEditingLastName];
            }
                break;
            case 4:
            {
                [self startEditingLanguage];
            }
                break;
            case 5:
            {
                [self startEditingCountry];
            }
                break;
            case 6:
            {
                [self startEditingBirthday];
            }
                break;
            case 7:
            {
                [self startEditingTelNumber];
            }
                break;
            case 8:// button "Change Password"
            {
                
            }
                break;
            case 9:
            {
                
            }
                break;
            case 10:
            {
                
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark UITableViewDataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 8;
    if (section == 0)
    {
        return 0;
    }
    if (self.isEditingProfile)
    {
        if (self.enabledPasswordChange)
            rowCount = 11;
        else
            rowCount = 9;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lvRow = indexPath.row;
    if (self.isEditingProfile)
    {
        if (lvRow == 2 || lvRow == 1)
        {
            ProfilePasswordCell *telNumberCell = (ProfilePasswordCell *)[tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
            telNumberCell.passwordTextField.secureTextEntry = NO;
            telNumberCell.passwordTextField.tag = lvRow;
            telNumberCell.passwordTextField.text = [self textForCellAtIndexPath:indexPath];
            telNumberCell.passwordTextField.delegate = self;
            telNumberCell.passwordTextField.userInteractionEnabled = NO;
            telNumberCell.titleLabel.text = [self titleForCellAtIndexPath:indexPath];
            telNumberCell.backgroundColor = [UIColor clearColor];
            return telNumberCell;
        }
        if (lvRow == 3)
        {
            ProfileSexEditingCell *sexEditCell = (ProfileSexEditingCell *)[tableView dequeueReusableCellWithIdentifier:@"SexEditCell" forIndexPath:indexPath];
            
            sexEditCell.sexChangeDelegate = self;
            NSInteger sexInt = self.currentUser.sex.integerValue;
            sexEditCell.sexSegmentedControl.selectedSegmentIndex = sexInt;
            
            return sexEditCell;
        }
        else if (lvRow == 7)
        {
            ProfilePasswordCell *telNumberCell = (ProfilePasswordCell *)[tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
            telNumberCell.passwordTextField.secureTextEntry = NO;
            telNumberCell.passwordTextField.tag = lvRow;
            
            telNumberCell.passwordTextField.delegate = self;
            telNumberCell.passwordTextField.userInteractionEnabled = NO;
            telNumberCell.titleLabel.text = [self titleForCellAtIndexPath:indexPath];
            telNumberCell.passwordTextField.text = [self textForCellAtIndexPath:indexPath];
            telNumberCell.backgroundColor = [UIColor clearColor];
            return telNumberCell;
        }
        else if (lvRow == 8)
        {
            ProfileButtonCell *buttonCell = (ProfileButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileButtonCell" forIndexPath:indexPath];
            
            buttonCell.buttonCellDelegate = self;
            [buttonCell.button setTitle:(self.enabledPasswordChange)?NSLocalizedString(@"Done",nil):NSLocalizedString(@"ChangePassword",nil) forState:UIControlStateNormal];
            return buttonCell;
        }
        else if (lvRow > 8)
        {
            ProfilePasswordCell *passwordCell = (ProfilePasswordCell *)[tableView dequeueReusableCellWithIdentifier:@"PasswordCell" forIndexPath:indexPath];
            passwordCell.passwordTextField.secureTextEntry = YES;
            passwordCell.passwordTextField.tag = lvRow;
            
            passwordCell.passwordTextField.delegate = self;
            passwordCell.passwordTextField.text = (lvRow == 9)?self.stringNewPassword:self.stringConfirmPassword;
            passwordCell.titleLabel.text = [self titleForCellAtIndexPath:indexPath];
            passwordCell.passwordTextField.userInteractionEnabled = YES;
            return passwordCell;
        }
        
        ProfileEditCell *editCell = (ProfileEditCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileEditCell" forIndexPath:indexPath];
        editCell.selectionStyle = UITableViewCellSelectionStyleNone;
        editCell.titleLabel.text = [self titleForCellAtIndexPath:indexPath];
        editCell.editingTextView.text = [self textForCellAtIndexPath:indexPath];
        editCell.editingTextView.delegate = self;
        editCell.editingTextView.userInteractionEnabled = (lvRow != 4 && lvRow != 5 && lvRow != 6); //disabled will trigger tableView didSelectRoaAtIndexpath
        editCell.editingTextView.tag = lvRow;
//        editCell.editingTextView.userInteractionEnabled = NO;
        
        return editCell;
    }
    else
    {
        ProfileCell *normalCell = (ProfileCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        normalCell.selectionStyle = UITableViewCellSelectionStyleNone;
        normalCell.titleLabel.text = [self titleForCellAtIndexPath:indexPath];
        normalCell.bodyLabel.text = [self textForCellAtIndexPath:indexPath];
        
        return normalCell;
    }
}

-(NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            return NSLocalizedString(@"mood", nil);
        }
            break;
        case 1:
        {
            return NSLocalizedString(@"firstName", nil);
        }
            break;
        case 2:
        {
            return  NSLocalizedString(@"lastName", nil);
        }
            break;
        case 3:
        {
            return  NSLocalizedString(@"sex", nil);
        }
            break;
        case 4:
        {
            return  NSLocalizedString(@"language", nil);
        }
            break;
        case 5:
        {
            return  NSLocalizedString(@"country", nil);
        }
            break;
        case 6:
        {
            return  NSLocalizedString(@"birthDay", nil);
        }
            break;
        case 7:
        {
            return  NSLocalizedString(@"phoneNumber", nil);
        }
            break;
            //case 8 is button to change password
        case 9:
        {
            return  NSLocalizedString(@"newPassword", nil);
        }
            break;
        case 10:
        {
            return  NSLocalizedString(@"confirmPassword", nil);
        }
            break;
        default:
            return @"";
            break;
    }
}

-(NSString *)textForCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditingProfile)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                return self.currentUser.mood;
            }
                break;
            case 1:
            {
                return ([ServerRequester sharedRequester].currentUser.firstName)?[ServerRequester sharedRequester].currentUser.firstName:@"";
            }
                break;
            case 2:
            {
                return ([ServerRequester sharedRequester].currentUser.lastName)?[ServerRequester sharedRequester].currentUser.lastName:@"";
            }
                break;
//            case 3:
//            {
//                
//            }
//                break;
            case 4:
            {
                return ([ServerRequester sharedRequester].currentUser.language)?[ServerRequester sharedRequester].currentUser.language:@"pick country";
            }
                break;
            case 5:
            {
                return ([ServerRequester sharedRequester].currentUser.country)?[ServerRequester sharedRequester].currentUser.country:@"pick language";
            }
                break;
            case 6:
            {
                return ([ServerRequester sharedRequester].currentUser.birthDay)?[[ServerRequester sharedRequester].currentUser.birthDay dateStringFromServerDateString]:@"";
            }
                break;
            case 7:
            {
                NSString *editedPhoneNumber = [self.editedStrings objectForKey:NSLocalizedString(@"phoneNumber", nil)];
                if (editedPhoneNumber)
                    return editedPhoneNumber;
                else
                    return @"";
                //return ([ServerRequester sharedRequester].currentUser.phoneNumber)?[ServerRequester sharedRequester].currentUser.phoneNumber:@"";
            }
                break;
            default:
                return @"";
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
            {
                return self.currentUser.mood;
            }
                break;
            case 1:
            {
                return self.currentUser.firstName;
            }
                break;
            case 2:
            {
                return self.currentUser.lastName;
            }
                break;
            case 3:
            {
                BOOL isWoman = [self.currentUser.sex boolValue];
                return (isWoman)?NSLocalizedString(@"sexWoman", nil):NSLocalizedString(@"sexMan", nil);
            }
                break;
            case 4:
            {
                return self.currentUser.language;
            }
                break;
            case 5:
            {
                return self.currentUser.country;
            }
                break;
            case 6:
            {
                return [self.currentUser.birthDay dateStringFromServerDateString];
            }
                break;
            case 7:
            {
                return self.currentUser.phoneNumber;
            }
                break;
            default:
                return @"test text";
                break;
        }
    }
}

#pragma mark - Cells` delegates
#pragma mark SexCellDelegate
-(void) sexCell:(ProfileSexEditingCell *)cell didChangeCurrentSex:(NSInteger)newValue
{
    if(newValue != self.currentUser.sex.integerValue)
    {
        self.currentUser.sex = @(newValue);
        self.hasUpdatedUser = YES;
    }
}
#pragma mark ButtonCellDelegate
-(void) profileButtonCell:(ProfileButtonCell *)cell didPressButton:(UIButton *)button
{
    self.enabledPasswordChange = !self.enabledPasswordChange;
    self.profileTable.allowsSelection = !self.enabledPasswordChange;
    [self.profileTable reloadData];
    
    
    self.navigationItem.rightBarButtonItem.enabled = !self.enabledPasswordChange;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self.profileTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.enabledPasswordChange)?10:6 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
    
}

#pragma mark - ProfileHeaderImage Photo
-(void) headerChangeImagePressed:(id)sender
{
    [self showAvatarPickerVC];
}

-(void) showAvatarPickerVC
{
    //AvatarPicker
    AvatarPickerController *avatarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AvatarPicker"];
    avatarVC.delegate = self;
    
    [self.navigationController pushViewController:avatarVC animated:YES];
}
#pragma mark ImagePickingDelegate
-(BOOL) avatarPickerShouldAllowEditing
{
    return YES;
}
#pragma mark - ImagePickingDelegate
-(void) userDidSelectImage:(UIImage *)image withName:(NSString *)fileName
{
    __weak typeof(self) weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[[NSOperationQueue alloc ]init] addOperationWithBlock:^
     {
         [[ServerRequester sharedRequester] uploadNewAvatar:image withCompletion:^(NSDictionary *successResponse, NSError *error)
          {
              if (successResponse)
              {
                  //             NSLog(@"Success uploading new user photo: %@", successResponse.description);
                  //             [ServerRequester sharedRequester].currentUser.photo = UIImagePNGRepresentation(image);
                  
                  FileHandler *lvHandler = [[FileHandler alloc] init];
                  NSString *loginName = [ServerRequester sharedRequester].currentUser.loginName;
                  if( [lvHandler saveAvatar:UIImagePNGRepresentation(image) forName:loginName ])
                  {
                      [ServerRequester sharedRequester].currentUser.photo = [lvHandler imageDataForUserAvatarWithUserName:loginName] ;
                      
                      //perform reload data in main queue
                      NSBlockOperation *reloadDataOp = [NSBlockOperation blockOperationWithBlock:^
                                                        {
                                                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                            [weakSelf.profileTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                                                        }];
                      
                      if ([NSOperationQueue currentQueue] != [NSOperationQueue mainQueue])
                      {
                          [[NSOperationQueue mainQueue] addOperation:reloadDataOp];
                      }
                      else
                      {
                          [[NSOperationQueue currentQueue] addOperation:reloadDataOp];
                      }
                      
                  }
              }
//              else if(error)
//              {
//                  NSLog(@"Error uploading new avatar: %@", error.description);
//              }
          }];
     }];
    
    //dismiss avatar picker controller fron parent`s nav controller`s stack
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TEXT field and textView
#pragma mark UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    NSString *lvText = textField.text;
    NSInteger lvTag = textField.tag;
    
    if (lvText.length > 0)
    {
        switch (lvTag)
        {
            case 10: //confirm message
            {
                self.stringConfirmPassword = lvText;
            }
                break;
            case 9://new password
            {
                self.stringNewPassword = lvText;
            }
                break;
            case 1://first name
            {
                if (![lvText isEqualToString:[ServerRequester sharedRequester].currentUser.firstName])
                {
                    [self.editedStrings setObject:lvText forKey:NSLocalizedString(@"firstName", nil)];
                }
            }
                break;
            case 2: //last name
            {
                if (![lvText isEqualToString:[ServerRequester sharedRequester].currentUser.lastName])
                {
                    [self.editedStrings setObject:lvText forKey:NSLocalizedString(@"lastName", nil)];
                }
            }
                break;
            default:
                break;
        }
        if ([self.stringNewPassword isEqualToString:self.stringConfirmPassword])
        {
            [self colorPasswordCellsForMathcing:YES];
        }
        else
        {
            [self colorPasswordCellsForMathcing:NO];
        }
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 9:
            self.stringNewPassword = nil;
            break;
        case 10:
            self.stringConfirmPassword = nil;
            break;
        default:
            break;
    }
    
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField //prepare accessory view in case of editing phone number
{
    if (textField.tag == 7)
    {
        UIView *toolbarForPhoneNumberKeyBoard = [self setupTextFieldAccessoryView];
        textField.inputAccessoryView = toolbarForPhoneNumberKeyBoard;
    }
    textField.tintColor = [UIColor whiteColor];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark UITExtViewDelegate
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    NSString *currentKey = [self titleForCellAtIndexPath:[NSIndexPath indexPathForRow:textView.tag inSection:1]];
    
    NSString *lvNewText = textView.text;
    
    [self.editedStrings setObject:lvNewText forKey:currentKey];
}


#pragma mark - Notifications
-(void)handleKeyboardAppearing:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    CGRect keyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyBoardFrame.size.height;
    
    UIViewAnimationOptions animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval interval = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification])
    {
        self.tableBottomConstraint.constant = keyboardHeight;
        
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
    {
        self.tableBottomConstraint.constant = self.defaultTableBottom;
    }
    
    
    __weak typeof(self) weakProfileVC = self;
    [UIView animateWithDuration:interval
                          delay:0.0
                        options:animationCurve
                     animations:^
    {
        [weakProfileVC.view layoutIfNeeded];
    }
                     completion:^(BOOL finished)
    {
        
    }];
}

-(IBAction)logOutPressed:(UIBarButtonItem *)sender
{
    [self.profileDelegate profileViewController:self logoutButtonPressed:sender];
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
