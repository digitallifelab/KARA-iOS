//
//  AvatarPickerController.h
//  Origami
//
//  Created by CloudCraft on 23.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "Constants.h"

@interface AvatarPickerController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, weak) id<ImagePickingDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *currentImageImageView;
@property (nonatomic, strong) UIImage *imageToDisplay;
@end
