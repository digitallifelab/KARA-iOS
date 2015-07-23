//
//  AvatarPickerController.m
//  Origami
//
//  Created by CloudCraft on 23.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AvatarPickerController.h"

#import "NSDate+ServerFormat.h"

@interface AvatarPickerController ()



@end

@implementation AvatarPickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    BOOL allows =[self.delegate avatarPickerShouldAllowEditing];
    self.imagePicker.allowsEditing = allows;

    
    //self.imagePicker.showsCameraControls = YES;
    self.imagePicker.delegate = self;
    self.currentImageImageView.image = self.imageToDisplay;
    self.currentImageImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.currentImageImageView.layer.borderWidth = 1.0;
    //[self setupTransparentNavigationBar:YES]; //we are already in NavController which was changed by MyProfileVC, so we don`t need to customize navigationBar
    [self addKaraBackgroundImage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -  appearance
//- (void) setupTransparentNavigationBar:(BOOL)transparent
//{
//    if (transparent)
//    {
//        //self.navigationController.navigationBar.translucent = YES;
//        [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init]; //remove thin line under navigation bar
//        
//        
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    }
//    else
//    {
//        self.navigationController.navigationBar.translucent = NO;
//        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = nil;
//        self.navigationController.navigationBar.backgroundColor = nil;
//        
//        self.navigationController.navigationBar.tintColor = Global_Tint_Color;
//    }
//}

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
#pragma mark - Image Picking
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak AvatarPickerController *weakSelf = self;
    
    //NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    NSString *imageName = [NSDate fileNameDate];
    
    
    if (picker.allowsEditing)
    {
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        self.currentImageImageView.image = editedImage;
        
        UIImage *scaledImage = [self scale:editedImage toSize:CGSizeMake(400, 400)];
        [picker dismissViewControllerAnimated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                           {
                               [weakSelf sendImageToDelegate:scaledImage withName:imageName];
                           });
        }];
    }
    else
    {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        self.currentImageImageView.image = originalImage;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                 [weakSelf sendImageToDelegate:originalImage withName:imageName];
            });
        }];
    }
}

-(UIImage *)scale:(UIImage *)inputImage toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [inputImage drawInRect:CGRectMake(0, 0, size.width, size.height) ];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(void) sendImageToDelegate:(UIImage *)image withName:(NSString *)imageName
{
    [self.delegate userDidSelectImage:image withName:imageName];
}


#pragma mark-
- (IBAction)libraryTapped:(UIBarButtonItem *)sender //from both bar button item buttons
{
    [self showImagePickerWithSelectedType:sender];
}

-(void) showImagePickerWithSelectedType:(UIBarButtonItem *)typeButton
{
    if (typeButton.tag == 1)
    {
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera ]) //give user camera
        {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.showsCameraControls = YES;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
        else //no camera - give user photo library
        {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }
    else
    {
        self.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}



@end
